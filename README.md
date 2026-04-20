# ✈️ Cloud Data Engineering Pipeline: U.S. Airline Delay Analysis (2009–2020)

## Overview

This project builds a **production-grade, end-to-end cloud data engineering pipeline** on Microsoft Azure to analyze U.S. domestic airline delay patterns from 2009 to 2020. The pipeline ingests over **71.5 million raw flight records** from 12 CSV files (~2GB), transforms and cleans the data using PySpark on Azure Databricks, aggregates it into analytics-ready Gold layer tables, and visualizes insights through an interactive Power BI dashboard.

The architecture follows the industry-standard **Medallion Architecture (Bronze → Silver → Gold)**, ensuring data quality, scalability, and maintainability at every stage. Azure Data Factory orchestrates the entire pipeline end-to-end with a single trigger.

---

## Architecture

**Medallion Architecture — Bronze → Silver → Gold**

| Layer | Tool | Description | Records |
|-------|------|-------------|---------|
| 🥉 **Bronze** | ADLS Gen2 + ADF | Raw CSV ingestion, no transformations | 71.5M+ |
| 🥈 **Silver** | Azure Databricks (PySpark) | Cleaned, type-cast, null-filtered Parquet | 11.4M |
| 🥇 **Gold** | Azure Databricks (PySpark) | Aggregated analytics-ready Parquet | 10,553 |

**Pipeline Flow:**

`Kaggle CSVs` ➜ `ADF Copy Activity` ➜ `Bronze Container (ADLS Gen2)` ➜ `Databricks Notebook` ➜ `Silver Container` ➜ `Gold Container` ➜ `Power BI Dashboard`

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| Cloud Platform | Microsoft Azure |
| Data Storage | Azure Data Lake Storage Gen2 (ADLS Gen2) |
| Pipeline Orchestration | Azure Data Factory (ADF V2) |
| Data Transformation | Azure Databricks (PySpark, Runtime 17.3 LTS) |
| Analytical Queries | Azure Synapse Analytics |
| Visualization | Power BI Desktop |
| Language | Python (PySpark) |
| Data Format | CSV (raw) → Parquet (processed) |
| Dataset | Kaggle Airline Delay and Cancellation Data 2009–2020 |

---

## Dataset

| Property | Details |
|----------|---------|
| Source | Kaggle — Airline Delay and Cancellation Data |
| Files | 12 CSV files (~2 GB total) |
| Records | 71,526,575+ flight records |
| Columns | 28 features (carrier, origin, destination, delays, cancellations, distance) |
| Time Range | 2009–2020 (12 years of U.S. domestic flights) |

---

## Repository Structure

```
airline-delay-data/
│
├── notebooks/
│   └── silver_layer_transformation.py   # PySpark Bronze→Silver→Gold notebook
│
├── adf/
│   └── pipeline/
│       └── airline_pipeline.json        # ADF pipeline ARM export
│
├── synapse/
│   └── queries/                         # 20 OPENROWSET SQL queries
│
└── README.md
```

---

## Pipeline Stages

### 🥉 Bronze Layer — Raw Ingestion
- 12 raw CSV files stored in the `bronze` container of ADLS Gen2
- Azure Data Factory **Copy Data** activity uses wildcard `*.csv` to ingest all files in one activity
- Data preserved as-is with no transformations applied
- **71,526,575+ records** loaded

### 🥈 Silver Layer — Cleaning and Transformation
PySpark notebook performs the following transformations:
- Date parsing using `try_to_date` via Spark SQL to handle malformed dates (e.g., `2015-03-1`)
- Safe numeric casting using a custom `safe_cast` function to handle invalid values such as `-`
- Null filtering on key columns: `FL_DATE`, `OP_CARRIER`, `ORIGIN`, `DEST`
- Output written as **Parquet** to the `silver` container
- **11,398,994 clean records** retained after quality filtering

### 🥇 Gold Layer — Aggregation
PySpark aggregations grouped by `OP_CARRIER` and `FL_DATE`:

| Column | Description |
|--------|-------------|
| `total_flights` | Total number of flights |
| `avg_dep_delay` | Average departure delay (minutes) |
| `avg_arr_delay` | Average arrival delay (minutes) |
| `cancellation_rate` | Rate of cancelled flights |
| `avg_distance` | Average flight distance (miles) |

- **10,553 aggregated rows** written to the `gold` container as Parquet

---

## How to Run

### Prerequisites
- Microsoft Azure subscription
- Azure Data Lake Storage Gen2 provisioned
- Azure Data Factory workspace created
- Azure Databricks workspace with running cluster (Runtime 17.3 LTS)
- Power BI Desktop installed

### Steps

**1. Upload raw data**
Place all 12 CSV files into the `bronze` container of your ADLS Gen2 storage account (`airlinedelaylake`).

**2. Configure linked services in ADF**
- `ls_adls_airline` — Azure Data Lake Storage Gen2
- `ls_databricks_airline` — Azure Databricks (Personal Access Token with `clusters` and `jobs` scopes)

**3. Trigger the pipeline**
- Open Azure Data Factory Studio
- Open `airline_pipeline`
- Click **Add Trigger → Trigger Now**
- Two activities run in sequence:
  - `Copy_CSV_to_Bronze` — copies all CSVs ✅
  - `Notebook1` — runs Databricks Silver + Gold transformations ✅

**4. Monitor**
Go to **Monitor → Pipeline Runs** to track progress.

**5. Refresh Power BI**
Open `airline_dashboard.pbix` and click **Refresh** to load the latest Gold data.

---

## Results

- Processed **71.5 million+** flight records end-to-end on Azure cloud infrastructure
- Cleaned and standardized 12 years of real-world airline data with custom data quality handling
- Identified top delay-prone carriers and seasonal patterns across 2009–2020
- Cancellation rate analysis revealed weather-related and carrier-specific trends
- Pipeline fully automated via ADF trigger — zero manual intervention after setup
- Power BI dashboard delivers insights across 4 pages: Overview, Carrier Performance, Trend Analysis, and Route Intelligence

---

## Azure Resources

| Resource Name | Type |
|---------------|------|
| `airlinedelaylake` | Azure Data Lake Storage Gen2 |
| `airline-adf-project` | Azure Data Factory V2 |
| `airline-databricks` | Azure Databricks Service |
| `airline-synapse-project` | Azure Synapse Analytics |
| `airline-delay-project` | Azure Resource Group |

---

## Key Engineering Decisions

- **Medallion Architecture** — clear separation of raw, cleaned, and aggregated layers for maintainability and data lineage
- **Parquet format** — columnar storage for Silver/Gold layers reduces query time vs CSV
- **`safe_cast` pattern** — custom PySpark function handles dirty data (values like `-`, nulls) without pipeline failure
- **`try_to_date` via Spark SQL** — handles inconsistent date formats gracefully by returning NULL instead of crashing
- **Wildcard `*.csv`** in ADF Copy activity — processes all 12 files in a single activity
- **Synapse deployed in West US 2** — East US SQL provisioning restricted under institutional Azure tenant

---

## Team

This project was developed as a group for **DAMG 7370 — Cloud Data Engineering** at Northeastern University.

| Name | Institution |
|------|-------------|
| **Imran Khan Pathan** | Northeastern University |
| **Durga Dhana Sree Chillukuri** | Northeastern University |
| **Robins Ranjan** | Northeastern University |
| **Adithya Anand** | Northeastern University |

📧 Contact: pathan.i@northeastern.edu

---

## Course Context

Developed as the final project for **DAMG 7370 — Cloud Data Engineering** at Northeastern University, demonstrating end-to-end proficiency in cloud-native data pipeline design, big data processing, and business intelligence visualization.

---

## Skills Demonstrated

`Azure Data Factory` `Azure Databricks` `PySpark` `Azure Data Lake Storage Gen2` `Azure Synapse Analytics` `Power BI` `Medallion Architecture` `ETL/ELT Pipeline Design` `Big Data Processing` `Data Quality Engineering` `Cloud Infrastructure` `Parquet` `SQL` `Python`
