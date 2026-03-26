# ⚙️ Industrial Maintenance Management System (PCM 4.0)

This repository features a complete SQL ecosystem for **Industrial Maintenance Management (PCM)**, focused on scalability, data integrity, and strategic KPI generation for decision-making.

## 🚀 About the Project
Developed with a focus on the **Paper and Cellulose industry** standards, this database manages everything from asset registration and cost centers to sensor telemetry (IoT) for predictive maintenance. It simulates a high-availability production environment where equipment reliability is mission-critical.

## 🏗️ Database Architecture
The system covers all 5 SQL sublanguages:
- **DDL**: Robust structure with interconnected tables.
- **DML**: Data seeding simulating months of real industrial operation.
- **DQL**: High-impact queries (MTBF, MTTR, Downtime Costs).
- **DCL**: Permissions model (Roles) for Managers and Technicians (Commented Example).
- **TCL**: Transaction control to ensure inventory integrity (Commented Example).

## 📊 Data Modeling (ERD)
The relationship between entities follows industrial logic:

```mermaid
erDiagram
    COST-CENTERS ||--o{ TECHNICAL-LOCATION : allocates
    TECHNICAL-LOCATION ||--o{ ASSETS : contains
    ASSETS ||--o{ WORK-ORDERS : generates
    ASSETS ||--o{ SENSORS-TELEMETRY : monitors
    TECHNICIANS ||--o{ WORK-ORDERS : executes
    WORK-ORDERS ||--o{ WO-ITEMS-MATERIALS : consumes
    COMPONENTS ||--o{ WO-ITEMS-MATERIALS : provides
