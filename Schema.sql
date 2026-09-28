-- =============================================================================
-- Enterprise Sustainability SQL Database Schema
-- Task: Strategic Sustainability Data Planning
-- =============================================================================

-- Drop existing tables if re-running
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS carbon_emissions CASCADE;
DROP TABLE IF EXISTS waste_management CASCADE;
DROP TABLE IF EXISTS energy_consumption CASCADE;
DROP TABLE IF EXISTS emission_factors CASCADE;
DROP TABLE IF EXISTS facilities CASCADE;

-- 1. FACILITIES TABLE
CREATE TABLE facilities (
    facility_id SERIAL PRIMARY KEY,
    facility_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    area_sqm NUMERIC(10, 2) CHECK (area_sqm > 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. EMISSION FACTORS LOOKUP TABLE
CREATE TABLE emission_factors (
    factor_id SERIAL PRIMARY KEY,
    source_type VARCHAR(50) NOT NULL, -- e.g., 'Electricity_Grid_US', 'Diesel_Fuel'
    scope_category INT CHECK (scope_category IN (1, 2, 3)),
    factor_value NUMERIC(12, 6) NOT NULL CHECK (factor_value >= 0),
    unit VARCHAR(20) NOT NULL, -- e.g., 'kgCO2e/kWh', 'kgCO2e/L'
    effective_year INT NOT NULL,
    CONSTRAINT unique_source_year UNIQUE (source_type, effective_year)
);

-- 3. ENERGY CONSUMPTION TRANSACTIONAL TABLE
CREATE TABLE energy_consumption (
    energy_id SERIAL PRIMARY KEY,
    facility_id INT NOT NULL REFERENCES facilities(facility_id) ON DELETE CASCADE,
    energy_type VARCHAR(30) NOT NULL CHECK (energy_type IN ('Electricity', 'Natural Gas', 'Diesel', 'Solar')),
    consumption_kwh NUMERIC(12, 2) NOT NULL CHECK (consumption_kwh >= 0),
    reading_date DATE NOT NULL,
    data_source VARCHAR(50) DEFAULT 'Automated Meter',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. CARBON EMISSIONS LOG TABLE
CREATE TABLE carbon_emissions (
    emission_id SERIAL PRIMARY KEY,
    energy_id INT REFERENCES energy_consumption(energy_id) ON DELETE CASCADE,
    facility_id INT NOT NULL REFERENCES facilities(facility_id) ON DELETE CASCADE,
    factor_id INT REFERENCES emission_factors(factor_id),
    co2e_emissions_ton NUMERIC(12, 4) NOT NULL CHECK (co2e_emissions_ton >= 0),
    calculation_date DATE NOT NULL
);

-- 5. WASTE MANAGEMENT TABLE
CREATE TABLE waste_management (
    waste_id SERIAL PRIMARY KEY,
    facility_id INT NOT NULL REFERENCES facilities(facility_id) ON DELETE CASCADE,
    waste_category VARCHAR(40) NOT NULL CHECK (waste_category IN ('Hazardous', 'Recyclable', 'Compostable', 'Landfill')),
    weight_kg NUMERIC(10, 2) NOT NULL CHECK (weight_kg >= 0),
    disposal_date DATE NOT NULL,
    is_diverted BOOLEAN NOT NULL
);

-- 6. AUDIT LOGS FOR GOVERNANCE
CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    action_performed VARCHAR(10) NOT NULL,
    record_id INT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    performed_by VARCHAR(50) DEFAULT CURRENT_USER
);

-- =============================================================================
-- INDEXES FOR QUERY OPTIMIZATION
-- =============================================================================

CREATE INDEX idx_energy_facility_date ON energy_consumption(facility_id, reading_date);
CREATE INDEX idx_waste_facility_date ON waste_management(facility_id, disposal_date);
CREATE INDEX idx_emissions_facility ON carbon_emissions(facility_id);

-- =============================================================================
-- REPORTING VIEW: MONTHLY FACILITY SUSTAINABILITY SUMMARY
-- =============================================================================

CREATE OR REPLACE VIEW view_facility_monthly_sustainability AS
SELECT 
    f.facility_id,
    f.facility_name,
    DATE_TRUNC('month', e.reading_date) AS reporting_month,
    SUM(e.consumption_kwh) AS total_energy_kwh,
    ROUND(SUM(e.consumption_kwh) / NULLIF(f.area_sqm, 0), 2) AS energy_intensity_kwh_per_sqm,
    COALESCE(SUM(c.co2e_emissions_ton), 0) AS total_carbon_tonnes
FROM facilities f
JOIN energy_consumption e ON f.facility_id = e.facility_id
LEFT JOIN carbon_emissions c ON e.energy_id = c.energy_id
GROUP BY f.facility_id, f.facility_name, f.area_sqm, DATE_TRUNC('month', e.reading_date);
