Cloud Data Engineering Pipeline: U.S. Airline Delay Analysis (2009–2020)

Overview
This project builds a production-grade, end-to-end cloud data engineering pipeline on Microsoft Azure to analyze U.S. domestic airline delay patterns from 2009 to 2020. The pipeline ingests over 71.5 million raw flight records from 12 CSV files (~2GB), transforms and cleans the data using PySpark on Azure Databricks, aggregates it into analytics-ready Gold layer tables, and visualizes insights through an interactive Power BI dashboard.
The architecture follows the industry-standard Medallion Architecture (Bronze → Silver → Gold), ensuring data quality, scalability, and maintainability at every stage. Azure Data Factory orchestrates the entire pipeline end-to-end with a single trigger.

Architecture
[Kaggle CSV Files]
        │
        ▼
┌───────────────┐     ┌────────────────┐     ┌──────────────────┐
│    BRONZE     │ ───▶│     SILVER     │ ──▶│      GOLD        │
│  Raw CSV Data │     │ Cleaned Data   │     │ Aggregated Data  │
│  71.5M rows   │     │ Parquet format │     │ Parquet format   │
│  ADLS Gen2    │     │  ADLS Gen2     │     │  ADLS Gen2       │
└───────────────┘     └────────────────┘     └──────────────────┘
        │                     │                       │
  ADF Pipeline           Databricks              Power BI
 (Orchestration)          (PySpark)            (Dashboard)

Tech Stack
ComponentTechnologyCloud PlatformMicrosoft AzureData StorageAzure Data Lake Storage Gen2 (ADLS Gen2)Pipeline OrchestrationAzure Data Factory (ADF V2)Data TransformationAzure Databricks (PySpark, Runtime 17.3 LTS)Analytical QueriesAzure Synapse AnalyticsVisualizationPower BI DesktopLanguagePython (PySpark)Data FormatCSV (raw) → Parquet (processed)DatasetKaggle Airline Delay and Cancellation Data 2009–2020

Dataset

Source: Kaggle — Airline Delay and Cancellation Data
Files: 12 CSV files (~2 GB total)
Records: 71,526,575+ flight records
Columns: 28 features including carrier, origin, destination, departure delay, arrival delay, cancellation status, distance, and more
Time Range: 2009–2020 (12 years of U.S. domestic flights)


Files Included
Notebooks

notebooks/silver_layer_transformation.py — PySpark notebook handling Bronze → Silver → Gold transformations including data cleaning, type casting, null filtering, and aggregation

ADF Pipeline

adf/pipeline/airline_pipeline.json — Azure Data Factory pipeline ARM export (Copy Data + Databricks Notebook activities)
adf/linkedService/ — Linked service definitions for ADLS Gen2 and Databricks

Synapse Queries

synapse/queries/ — 20 OPENROWSET SQL queries covering delay rankings, seasonal trends, carrier scorecards, cancellation analysis, and quarterly breakdowns

Power BI

powerbi/airline_dashboard.pbix — Interactive 4-page Power BI dashboard connected to Gold layer


Pipeline Stages
Bronze Layer — Raw Ingestion

12 raw CSV files stored in the bronze container of ADLS Gen2
Azure Data Factory Copy Data activity uses wildcard (*.csv) to ingest all files
Data preserved as-is with no transformations
71,526,575+ records loaded

Silver Layer — Cleaning & Transformation
PySpark notebook performs the following:

Date parsing using try_to_date via Spark SQL to handle malformed dates (e.g., 2015-03-1)
Safe numeric casting using a custom safe_cast pattern to handle invalid values such as -
Null filtering on key columns: FL_DATE, OP_CARRIER, ORIGIN, DEST
Output written as Parquet to the silver container
11,398,994 clean records after quality filtering

Gold Layer — Aggregation
PySpark aggregations grouped by OP_CARRIER and FL_DATE produce the following metrics:
ColumnDescriptiontotal_flightsTotal number of flightsavg_dep_delayAverage departure delay (minutes)avg_arr_delayAverage arrival delay (minutes)cancellation_rateRate of cancelled flightsavg_distanceAverage flight distance (miles)

10,553 aggregated rows written to the gold container as Parquet


How to Run the Pipeline
Prerequisites

Microsoft Azure subscription
Azure Data Lake Storage Gen2 account provisioned
Azure Data Factory workspace created
Azure Databricks workspace with a running cluster (Runtime 17.3 LTS)
Power BI Desktop installed locally

Steps

Upload raw data — Place all CSV files into the bronze container of your ADLS Gen2 storage account
Configure linked services — In ADF, set up:

ls_adls_airline — Azure Data Lake Storage Gen2 linked service
ls_databricks_airline — Azure Databricks linked service (using Personal Access Token)


Trigger the pipeline — In Azure Data Factory Studio:

Open airline_pipeline
Click Add Trigger → Trigger Now
The pipeline runs two activities in sequence:

Copy_CSV_to_Bronze — copies all CSVs to bronze container ✅
Notebook1 — runs Databricks Silver + Gold transformations ✅




Monitor the run — Go to Monitor → Pipeline Runs to track progress
Refresh Power BI — Open airline_dashboard.pbix and click Refresh to load the latest Gold data


Results & Findings

Processed 71.5 million+ flight records end-to-end on Azure cloud infrastructure
Cleaned and standardized 12 years of messy real-world airline data with custom data quality handling
Identified top delay-prone carriers and seasonal patterns across 12 years (2009–2020)
Cancellation rate analysis revealed weather-related and carrier-specific trends
Pipeline runs fully automated via ADF trigger — zero manual intervention required after setup
Power BI dashboard delivers actionable insights across 4 pages: Overview, Carrier Performance, Trend Analysis, and Route Intelligence


Azure Resources
Resource NameTypeairlinedelaylakeAzure Data Lake Storage Gen2airline-adf-projectAzure Data Factory V2airline-databricksAzure Databricks Serviceairline-synapse-projectAzure Synapse Analytics Workspaceairline-delay-projectAzure Resource Group

Key Engineering Decisions

Medallion Architecture — clear separation of raw, cleaned, and aggregated data for maintainability and data lineage
Parquet format — columnar storage for Silver/Gold layers reduces query time significantly compared to CSV
safe_cast pattern — custom PySpark function handles real-world dirty data (values like -, empty strings, nulls) without crashing
try_to_date via Spark SQL — handles inconsistent date formats like 2015-03-1 gracefully by returning NULL instead of failing
Wildcard file path (*.csv) in ADF source — processes all 12 CSV files in a single Copy Data activity
Synapse deployed in West US 2 — East US SQL provisioning unavailable under institutional Azure tenant


Team
This project was developed collaboratively as a group for DAMG 7370 at Northeastern University.
NameInstitutionImran Khan PathanNortheastern UniversityDurga Dhana Sree ChillukuriNortheastern UniversityRobins RanjanNortheastern UniversityAdithya AnandNortheastern University
Contact: pathan.i@northeastern.edu

Course Context
Developed as the final project for DAMG 7370 — Cloud Data Engineering at Northeastern University, demonstrating end-to-end proficiency in cloud-native data pipeline design, big data processing, and business intelligence visualization.

Skills Demonstrated
Azure Data Factory Azure Databricks PySpark Azure Data Lake Storage Gen2 Azure Synapse Analytics Power BI Medallion Architecture ETL/ELT Pipeline Design Big Data Processing Data Quality Engineering Cloud Infrastructure Parquet SQL Python
