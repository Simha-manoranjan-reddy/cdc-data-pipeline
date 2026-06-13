# ADF Pipeline Flow — CDC Data Pipeline

> This document explains the design and logic of the Azure Data Factory pipeline that orchestrates both the initial full load and ongoing incremental CDC loads into the Bronze layer.

![ADF Pipeline Diagram](./Designer%20(3).png)

---

## Overview

The pipeline handles two distinct scenarios, controlled by a SQL-based control table:

| Scenario | When it runs |
|---|---|
| **Full Load** | First-ever run — loads all existing source data |
| **Incremental CDC Load** | Every subsequent run — loads only changed rows since last execution |

The branch taken is determined at runtime by reading the `CDC_Control_Table_TB` table in Azure SQL.

---

## Control Table: `CDC_Control_Table_TB`

Two columns drive the pipeline logic:

| Column | Type | Purpose |
|---|---|---|
| `IsInitialLoadDone` | bit | `0` = full load not yet done; `1` = use CDC branch |
| `LastProcessedLSN` | binary(10) | The last Log Sequence Number successfully processed |

This table acts as the pipeline's state store — persisting progress across runs and making the pipeline restartable and idempotent.

---

## Pipeline Decision Flow

```
Start
  │
  ▼
Read CDC_Control_Table_TB
  │
  ├── IsInitialLoadDone = 0 ──► Full Load Branch
  │
  └── IsInitialLoadDone = 1 ──► CDC Incremental Branch
```

---

## Full Load Branch

Runs once, on the very first pipeline execution.

### Steps

**Step 1 — Read full source table**
Reads all rows from `Customer_Source_TB` in Azure SQL Database.

**Step 2 — Copy to Bronze layer**
Writes the full dataset to ADLS at:
```
bronze/full_load/
```

**Step 3 — Trigger Databricks Notebook 1**
Notebook 1 reads the full load file from Bronze and builds the initial Silver Delta table.

**Step 4 — Update control table**
Marks the full load as complete and records the current max LSN so the CDC branch knows where to start:
```sql
UPDATE CDC_Control_Table_TB
SET IsInitialLoadDone = 1,
    LastProcessedLSN  = <current_max_lsn>
```

---

## CDC Incremental Branch

Runs on every pipeline execution after the initial full load.

### Steps

**Step 1 — Read LSN range from control table**
Retrieves `LastProcessedLSN` as `FromLSN` and calls `sys.fn_cdc_get_max_lsn()` as `ToLSN`.

**Step 2 — Extract CDC changes**
Queries the SQL Server CDC system function for all changes in the LSN window:
```sql
SELECT *
FROM cdc.fn_cdc_get_all_changes_dbo_Customer_Source_TB(
    @FromLSN, @ToLSN, 'all update old'
)
```
This returns rows with an `__$operation` flag indicating INSERT (2), UPDATE-after (4), or DELETE (1).

**Step 3 — Copy CDC batch to Bronze layer**
Writes the change batch to ADLS at:
```
bronze/customer_cdc/<run_date>/
```

**Step 4 — Trigger Databricks Notebook 2**
ADF passes the Bronze file path as a parameter to Notebook 2, which merges the CDC batch into the Silver Delta table using `MERGE INTO`.

**Step 5 — Update control table**
Advances the watermark to `ToLSN` so the next run picks up from here:
```sql
UPDATE CDC_Control_Table_TB
SET LastProcessedLSN = @ToLSN
```

---

## Databricks Notebooks

### Notebook 1 — Full Load to Silver

- Reads from `bronze/full_load/`
- Creates (or replaces) the Silver Delta table
- Enforces schema and applies basic data quality rules

### Notebook 2 — CDC MERGE into Silver

- Receives the Bronze CDC file path from ADF as a parameter
- Reads the CDC batch and resolves any duplicate operations within the batch (keeps the latest per key)
- Applies a `MERGE INTO` on the Silver Delta table:
  - `__$operation = 2` → INSERT new rows
  - `__$operation = 4` → UPDATE existing rows
  - `__$operation = 1` → Soft-delete (sets `is_deleted = true`) or hard-delete, depending on config

---

## Bronze Layer Structure

```
bronze/
├── full_load/
│   └── customer_full_<timestamp>.parquet
│
└── customer_cdc/
    └── <run_date>/
        └── customer_cdc_<lsn_range>.parquet
```

---

## Silver Layer

A Databricks-managed Delta table that always reflects the **current state** of the source. The MERGE logic ensures:

- No duplicate rows
- Deletes are handled (soft or hard)
- Re-running the same CDC batch produces the same result (idempotent)

---

## Gold Layer

Triggered by ADF immediately after Notebook 2 completes successfully.

### Flow

**Step 1 — Trigger Databricks Notebook 3**
ADF triggers Notebook 3, passing `silver_path`, `gold_path`, and `run_date` as parameters.

**Step 2 — Read from Silver**
Notebook 3 reads the current Silver Delta table — which at this point already reflects the latest merged changes.

**Step 3 — Build business-ready tables**
Applies aggregations and business logic to produce three Gold tables:

| Table | Write mode | Description |
|---|---|---|
| `gold.dim_customer` | Overwrite | One row per active customer, soft-deletes excluded |
| `gold.customer_change_summary` | Append | Per-run count of inserts, updates, and deletes — historical audit log |
| `gold.customer_growth_monthly` | Overwrite | Monthly new vs churned customers, consumed by Power BI |

**Step 4 — Write to ADLS Gold path**
All tables are written as Delta format to:
```
gold/
├── dim_customer/
├── customer_change_summary/
└── customer_growth_monthly/
```

### Updated End-to-End Flow (with Gold)

```
Azure SQL Database  (CDC Enabled)
        ↓
Azure Data Factory  (LSN watermark, control table)
        ↓
ADLS Bronze Layer   (raw CDC records)
        ↓
Databricks Notebook 2  (MERGE INTO Silver Delta table)
        ↓
Databricks Notebook 3  (build Gold tables from Silver)
        ↓
Gold Layer  (dim_customer, change_summary, growth_monthly)
        ↓
Power BI / Synapse / Reporting consumers
```

---

## Error Handling

| Failure point | Behaviour |
|---|---|
| ADF Copy Activity fails | Pipeline marks run as failed; `LastProcessedLSN` is **not** updated, so the same LSN range is retried next run |
| Databricks notebook fails | Same LSN range is retried; Delta Lake's ACID guarantees no partial writes are committed |
| Control table unreachable | Pipeline fails at the first Lookup activity; no data movement occurs |

---

## Key Design Decisions

**LSN-based watermarking** — More reliable than timestamp-based watermarks because LSNs are monotonically increasing and immune to clock skew or timezone issues.

**Control table in SQL** — Keeps state durable and queryable. You can inspect or manually correct the watermark without touching ADF.

**ADF passes path to Databricks** — Decouples orchestration from transformation. ADF handles scheduling and data movement; Databricks handles all transformation logic.

**Idempotent MERGE** — If the pipeline reruns the same LSN window (e.g., after a failure), the Silver table ends up in the same state — no duplicates, no data loss.
