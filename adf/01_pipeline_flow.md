# ADF Pipeline Flow

## Overview

The ADF pipeline is designed to handle both:

- Initial Full Load
- Incremental CDC Load

The decision is controlled using the table:

- `CDC_Control_Table_TB`

---

## Control Logic

The pipeline checks:

- `IsInitialLoadDone`
- `LastProcessedLSN`

### If `IsInitialLoadDone = 0`
→ Run **Full Load branch**

### If `IsInitialLoadDone = 1`
→ Run **CDC branch**

---

## Full Load Branch

### Flow
1. Read full source data from `Customer_Source_TB`
2. Copy data to Bronze layer:
   - `full_load/`
3. Run Databricks Notebook 1
   - builds Silver table
4. Update control table:
   - `IsInitialLoadDone = 1`
   - `LastProcessedLSN = current max LSN`

---

## CDC Branch

### Flow
1. Read `FromLSN` and `ToLSN`
2. Extract CDC data using SQL CDC function
3. Copy CDC file to Bronze layer:
   - `customer_cdc/`
4. Run Databricks Notebook 2
   - merges changes into Silver
5. Update control table with latest processed LSN

---

## Databricks Integration

### Notebook 1
- Full load to Silver

### Notebook 2
- CDC MERGE into Silver

Notebook 2 receives the current CDC batch file path from ADF as a parameter.

---

## Bronze Layer

Stores raw files:

- `full_load/`
- `customer_cdc/`

---

## Silver Layer

Databricks Delta table that handles:

- INSERT
- UPDATE
- DELETE (Soft delete)

---

## Key Benefit

This design ensures:

- One-time full load
- Incremental CDC processing
- No duplicate processing
- Scalable Medallion architecture
