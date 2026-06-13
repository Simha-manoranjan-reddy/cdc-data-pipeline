#  CDC Data Pipeline

## 📌 Overview

This project implements an end-to-end **Change Data Capture (CDC) pipeline** using Azure services.

The pipeline ingests data from Azure SQL, processes incremental changes using CDC, builds a curated Silver layer using Delta Lake in Databricks, and creates a business-ready Gold layer for analytics and reporting.

---

## 🏗️ Architecture

<img src="https://github.com/Simha-manoranjan-reddy/cdc-data-pipeline/blob/main/Architecure/Designer%20(2).png" alt="Description of image" width="900">


---

## ⚙️ ADF Pipeline Flow

<img src="https://github.com/Simha-manoranjan-reddy/cdc-data-pipeline/blob/main/Architecure/Designer%20(2).png" alt="Description of image" width="900">

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
