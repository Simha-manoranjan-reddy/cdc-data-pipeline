# CDC Data Pipeline — Azure End-to-End

> An end-to-end **Change Data Capture (CDC)** pipeline built on Azure, using native SQL Server CDC, Azure Data Factory, ADLS Gen2, and Databricks Delta Lake to deliver a clean Medallion architecture (Bronze → Silver → Gold).

---

## 📌 Overview

This project implements a production-style incremental data pipeline that captures row-level changes (INSERT, UPDATE, DELETE) from an Azure SQL Database and propagates them through a Medallion architecture for analytics and reporting.

Rather than full table loads, the pipeline uses SQL Server's native CDC mechanism to extract only what changed since the last run — making it efficient, auditable, and scalable.

---

## 🏗️ Architecture

![Architecture Diagram](./Architecture/Designer%20(2).png)

---

## ⚙️ ADF Pipeline Flow

![ADF Pipeline](./adf/Designer%20(3).png)

---

## 🔁 End-to-End Flow

```
Azure SQL Database  (CDC Enabled on source tables)
        ↓
Azure Data Factory  (extracts changes via LSN watermark)
        ↓
ADLS Gen2 — Bronze Layer  (raw CDC records as Parquet/JSON)
        ↓
Azure Databricks — Silver Layer  (MERGE INTO Delta tables, deduplication)
        ↓
Azure Databricks — Gold Layer  (aggregated, business-ready tables)
        ↓
Reporting / Analytics consumers
```

---

## 🗂️ Repository Structure

```
cdc-data-pipeline/
│
├── Architecture/          # Architecture diagrams
├── SQL/                   # Source DDL and CDC enable scripts
├── adf/                   # ADF pipeline JSON exports
├── notebooks/             # Databricks notebooks (Silver & Gold logic)
└── README.md
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Source Database | Azure SQL Database (CDC enabled) |
| Orchestration | Azure Data Factory (ADF) |
| Storage | Azure Data Lake Storage Gen2 (ADLS) |
| Processing | Azure Databricks (PySpark) |
| Storage Format | Delta Lake |
| Secrets Management | Azure Key Vault |

---

## 🚀 Setup & Deployment

### Prerequisites

- Azure subscription with Contributor access
- Azure SQL Database (General Purpose tier or above — required for CDC)
- Azure Data Lake Storage Gen2 account
- Azure Databricks workspace (Standard or Premium tier)
- Azure Data Factory instance
- Azure Key Vault (recommended for storing connection strings)

### 1. Enable CDC on Azure SQL

Run the scripts in the `SQL/` folder against your source database:

```sql
-- Enable CDC on the database
EXEC sys.sp_cdc_enable_db;

-- Enable CDC on a specific table (example)
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'YourTableName',
    @role_name     = NULL;
```

### 2. Configure ADLS Gen2

Create the following container structure in your storage account:

```
your-container/
├── bronze/    ← raw CDC output from ADF
├── silver/    ← cleaned Delta tables
└── gold/      ← aggregated business tables
```

### 3. Deploy ADF Pipelines

1. Open Azure Data Factory Studio.
2. Import the pipeline JSON files from the `adf/` folder using **ARM template import** or the ADF Git integration.
3. Update the linked service connection strings to point to your SQL Database and ADLS account (use Key Vault references — do not hard-code credentials).
4. Set the ADF pipeline parameters:
   - `storageAccountName`
   - `containerName`
   - `sqlServerName` / `databaseName`

### 4. Deploy Databricks Notebooks

1. Import notebooks from the `notebooks/` folder into your Databricks workspace.
2. Attach to a cluster running Databricks Runtime 12.x or above (Delta Lake 2.x).
3. Set the following Databricks secrets or widget defaults:
   - `storage_account` — ADLS account name
   - `bronze_path` — path to Bronze container
   - `silver_path` — path to Silver container
   - `gold_path` — path to Gold container

### 5. Schedule the Pipeline

Trigger the ADF pipeline on a schedule (e.g., every 15 minutes or hourly) using an ADF Schedule Trigger. The pipeline will:

1. Read the last processed LSN (Log Sequence Number) from a watermark table.
2. Extract all CDC changes between the last LSN and the current LSN.
3. Land the raw changes in ADLS Bronze.
4. Trigger the Databricks Silver notebook to MERGE changes into Delta tables.
5. Update the watermark with the new LSN.

---

## 🔄 CDC Logic — How Incremental Loads Work

SQL Server CDC writes change records to system tables with an operation flag:

| `__$operation` | Meaning |
|---|---|
| 1 | DELETE |
| 2 | INSERT |
| 3 | UPDATE (before image) |
| 4 | UPDATE (after image) |

The Silver layer notebook uses `MERGE INTO` on the Delta table, applying inserts/updates and hard-deleting or soft-deleting rows based on the operation flag.

---

## 📊 Layer Descriptions

**Bronze** — Raw, unmodified CDC records landed from ADF. Partitioned by ingestion date. Serves as the audit trail and replay source.

**Silver** — Cleaned, deduplicated, and merged Delta tables that reflect the current state of the source. Schema enforced, nulls validated.

**Gold** — Aggregated and business-logic-applied tables ready for reporting tools (e.g., Power BI, Azure Analysis Services, Synapse Analytics).

---

## 🔐 Security Notes

- Never commit connection strings or storage account keys to this repository.
- Use Azure Key Vault linked services in ADF and Databricks secret scopes.
- CDC system tables should be access-controlled; only the ADF managed identity or service principal should have `db_datareader` on `cdc.*` tables.

---



