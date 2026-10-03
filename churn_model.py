"""
Project: Telco Customer Churn Prediction Pipeline
Author: Anshika Mehta
Description: End-to-end data preprocessing, feature engineering, and Machine Learning 
             model training using Random Forest to predict and analyze customer churn risk.
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
from sklearn.preprocessing import LabelEncoder, StandardScaler

def load_and_preprocess_data(file_path):
    print("-> Loading dataset...")
    df = pd.read_csv(file_path)
    
    # Drop customerID as it is a unique identifier, not a predictive feature
    if 'customerID' in df.columns:
        df = df.drop('customerID', axis=1)

    # Handle blank spaces in 'TotalCharges' column by converting to numeric and filling NaNs with median
    df['TotalCharges'] = pd.to_numeric(df['TotalCharges'], errors='coerce')
    df['TotalCharges'] = df['TotalCharges'].fillna(df['TotalCharges'].median())

    print("-> Encoding categorical variables...")
    le = LabelEncoder()
    for col in df.select_dtypes(include=['object']).columns:
        df[col] = le.fit_transform(df[col])
        
    return df

def train_evaluation_pipeline(df):
    # Define Features (X) and Target (y)
    X = df.drop('Churn', axis=1)
    y = df['Churn']

    # Split data into training (80%) and testing (20%) sets with stratification
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    # Feature Scaling
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    print("-> Training Random Forest Classifier...")
    rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
    rf_model.fit(X_train_scaled, y_train)

    # Predictions & Evaluation
    y_pred = rf_model.predict(X_test_scaled)
    
    print("\n" + "="*40)
    print("MODEL PERFORMANCE METRICS")
    print("="*40)
    print(f"Accuracy Score: {accuracy_score(y_test, y_pred):.4f}\n")
    print("Classification Report:")
    print(classification_report(y_test, y_pred))

    # Feature Importance Analysis
    feature_importances = pd.Series(rf_model.feature_importances_, index=X.columns).sort_values(ascending=False)
    print("\n" + "="*40)
    print("TOP 5 CHURN PREDICTION FEATURES")
    print("="*40)
    print(feature_importances.head(5))

if __name__ == "__main__":
    # Replace with your local dataset file name if different
    dataset_path = 'Telco-Customer-Churn.csv'
    
    try:
        clean_df = load_and_preprocess_data(dataset_path)
        train_evaluation_pipeline(clean_df)
    except FileNotFoundError:
        print(f"Error: Could not find '{dataset_path}'. Please ensure the Kaggle CSV file is in the same directory.")
