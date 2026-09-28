# Strategic Sustainability Data Planning & SQL Architecture

## 📌 Project Overview
This repository contains the Week 1 submission for the **Virtual Sustainability SQL Development Internship**. It presents a complete strategy and relational database design for managing environmental metrics such as energy consumption, GHG carbon emissions (Scope 1 & 2), and waste diversion rates.

---

## 🎯 Key Performance Indicators (KPIs)
* **Energy Intensity:** Consumption per square meter ($\text{kWh}/\text{m}^2$).
* **Carbon Footprint:** Direct and indirect emissions ($\text{tCO}_2\text{e}$).
* **Waste Diversion Rate:** Percentage of recycled/composted waste vs total generated waste.

---

## 🛠️ Database Schema Structure

The database is built on a 3NF relational model in PostgreSQL:
* `facilities`: Master facility metadata.
* `emission_factors`: Standardized GHG conversion rates.
* `energy_consumption`: Utility and fuel usage logs.
* `carbon_emissions`: Calculated carbon equivalent outputs.
* `waste_management`: Waste disposal and recycling tracking.
* `audit_logs`: Audit system for ESG regulatory compliance.

---

## 🚀 How to Run the SQL Script

1. Open your PostgreSQL / MySQL database client (e.g., pgAdmin, DBeaver, or psql CLI).
2. Create a new database:
   ```sql
   CREATE DATABASE sustainability_db;
   
