#  CDC Data Pipeline

## 📌 Overview

This project implements an end-to-end **Change Data Capture (CDC) pipeline** using Azure services.

The pipeline ingests data from Azure SQL, processes incremental changes using CDC, builds a curated Silver layer using Delta Lake in Databricks, and creates a business-ready Gold layer for analytics and reporting.

---

## 🏗️ Architecture

4_architecture/architecture.png

---

## ⚙️ ADF Pipeline Flow

2_adf/05_screenshots/cdc_pipeline_flow.png

---

## 🔁 End-to-End Flow

```text
Azure SQL Database (CDC Enabled)
        ↓
Azure Data Factory (ADF)
        ↓
ADLS Bronze Layer
        ↓
Azure Databricks + Delta Lake
        ↓
Silver Layer
        ↓
Gold Layer
