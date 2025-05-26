#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- STARTING MMM DATA PIPELINE ---"

echo "[1/5] Generating fresh raw data..."
python pipeline_scripts/generate_data.py

echo "[2/5] Loading raw data into warehouse via dbt seed..."
mkdir -p mmm_dbt_project/seeds
mv data/raw/*.csv mmm_dbt_project/seeds/
dbt seed --project-dir mmm_dbt_project --full-refresh

echo "[3/5] Running dbt transformations..."
dbt run --project-dir mmm_dbt_project

echo "[4/5] Running dbt data quality tests (with custom tests)..."
dbt test --project-dir mmm_dbt_project

echo "[5/5] Exporting final MMM table to data/processed/..."
# This command uses a dbt operation to export a model to a CSV
dbt run-operation export_model --args "{'model_name': 'mmm_aggregated_data', 'output_path': 'data/processed/mmm_data.csv'}" --project-dir mmm_dbt_project

echo "--- PIPELINE FINISHED SUCCESSFULLY ---"
echo "Final MMM table is available at: data/processed/mmm_data.csv"