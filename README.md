# Yelp Climate Data Warehouse for Reporting & OLAP

![SQL](https://img.shields.io/badge/SQL-Data%20Warehouse-blue?logo=sqlite&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-Cloud%20Data%20Platform-29B5E8?logo=snowflake&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-ETL-336791?logo=postgresql&logoColor=white)
![OLAP](https://img.shields.io/badge/OLAP-Analytics-orange)
![Star%20Schema](https://img.shields.io/badge/Star%20Schema-Dimensional%20Modeling-success)
![Status](https://img.shields.io/badge/Project-Completed-brightgreen)
## Overview

This project demonstrates the design and implementation of a complete **Data Warehouse** using Yelp business data and climate datasets. The solution follows a layered architecture:

- Staging Layer
- Operational Data Store (ODS)
- Dimensional Data Warehouse (Star Schema)
- Reporting & OLAP

The goal is to analyze restaurant reviews alongside weather conditions to support business intelligence and analytical reporting.

---

## Architecture

```text
Raw Data
   │
   ▼
Staging Layer
   │
   ▼
Operational Data Store (ODS)
   │
   ▼
Star Schema Data Warehouse
   │
   ▼
Reporting & OLAP
```

## Technologies

- SQL
- PostgreSQL
- ETL
- Data Warehouse
- Star Schema
- OLAP
- Database Design

## Data Model

### Dimension Tables
- Dim_Date
- Dim_Business
- Dim_Customer
- Dim_Temperature
- Dim_Precipitation

### Fact Table
- Fact_Review

## Repository Structure

```
.
├── docs/
├── sql/
├── diagrams/
├── screenshots/
├── assets/
├── README.md
├── LICENSE
└── .gitignore
```

## Workflow

1. Load raw datasets into staging tables.
2. Transform and clean data in the ODS.
3. Create dimension and fact tables.
4. Populate the data warehouse.
5. Execute analytical SQL queries.
6. Generate OLAP reports.

## Features

- End-to-end ETL workflow
- Dimensional modeling
- Star schema implementation
- Analytical SQL queries
- Reporting using integrated Yelp and climate data

## Skills Demonstrated

- Data Engineering
- ETL Development
- SQL
- PostgreSQL
- Data Modeling
- OLAP
- Business Intelligence

## Future Enhancements

- Power BI Dashboard
- Tableau Dashboard
- Automated ETL
- Cloud deployment (AWS/Azure)
- Incremental loading

## Author

**Ashmit Kumar**

If you found this repository useful, consider giving it a ⭐.
