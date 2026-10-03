-- =====================================================================
-- Project: Telco Customer Churn & Retention Analysis
-- Author: Anshika Mehta
-- Database: MySQL Workbench
-- Description: SQL script for data schema creation, cleaning, and 
--              business intelligence aggregations for churn insights.
-- =====================================================================

-- 1. Create Database and Table Schema
CREATE DATABASE IF NOT EXISTS telco_churn_db;
USE telco_churn_db;

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customerID VARCHAR(50) PRIMARY KEY,
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    tenure INT,
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(20),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(20),
    OnlineBackup VARCHAR(20),
    DeviceProtection VARCHAR(20),
    TechSupport VARCHAR(20),
    StreamingTV VARCHAR(20),
    StreamingMovies VARCHAR(20),
    Contract VARCHAR(30),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10, 2),
    TotalCharges VARCHAR(20), -- Stored as varchar initially to handle blank spaces
    Churn VARCHAR(5)
);

-- Note: After importing the Kaggle CSV into this table via MySQL Table Data Import Wizard,
-- execute the cleaning and analytical queries below.

-- 2. Data Cleaning: Clean TotalCharges (handle empty strings/blanks)
UPDATE customers 
SET TotalCharges = NULL 
WHERE TotalCharges = '' OR TotalCharges = ' ';

ALTER TABLE customers 
MODIFY COLUMN TotalCharges DECIMAL(10, 2);

-- 3. Business Intelligence & Analytics Queries

-- Query 1: Overall Churn Rate Calculation
SELECT 
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND((SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Churn_Rate_Percentage
FROM customers;

-- Query 2: Churn Rate by Contract Type (Identifies high-risk customer segments)
SELECT 
    Contract,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND((SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Churn_Rate_Percentage
FROM customers
GROUP BY Contract
ORDER BY Churn_Rate_Percentage DESC;

-- Query 3: Average Monthly Charges and Tenure by Churn Status
SELECT 
    Churn,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges,
    ROUND(AVG(COALESCE(TotalCharges, 0)), 2) AS Avg_Total_Charges,
    ROUND(AVG(tenure), 2) AS Avg_Tenure_Months
FROM customers
GROUP BY Churn;

-- Query 4: Churn Rate by Internet Service Type
SELECT 
    InternetService,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND((SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Churn_Rate_Percentage
FROM customers
GROUP BY InternetService
ORDER BY Churn_Rate_Percentage DESC;

-- Query 5: High-Risk Profile Identification (Month-to-Month contracts with high monthly charges)
SELECT 
    customerID,
    gender,
    tenure,
    Contract,
    MonthlyCharges,
    TotalCharges,
    PaymentMethod
FROM customers
WHERE Contract = 'Month-to-month' 
  AND MonthlyCharges > (SELECT AVG(MonthlyCharges) FROM customers)
  AND Churn = 'Yes'
LIMIT 20;
