# MMM Data Pipeline Prototype

This project is a prototype data pipeline built to address the Media Mix Model (MMM) case study. It demonstrates an end-to-end, production-style process for ingesting data from multiple raw sources, cleaning it, standardizing it, and creating a final, aggregated data table ready for modeling.

The entire pipeline is designed to be run locally, showcasing a modern ELT approach with dbt for transformations and DuckDB as a file-based data warehouse.

---

## 🏛️ Architecture

The pipeline follows a modern **ELT (Extract, Load, Transform)** architecture. The process is orchestrated by a simple shell script that ensures each step runs in the correct sequence.

```
┌─────────────────────────┐     ┌──────────────────────────┐      ┌───────────────────────────┐      ┌──────────────────┐
│  1. Raw Data Sources    ├────►│  2. Load into Warehouse  ├─────►│  3. Transform & Test      ├─────►│  4. Final Table  │
│  (Simulated CSVs)       │     │  (dbt seed)              │      │  (dbt run & dbt test)     │      │  (MMM Ready Data)│
└─────────────────────────┘     └──────────────────────────┘      └───────────────────────────┘      └──────────────────┘
```

1.  **Extract (Simulated):** A Python script (`pipeline_scripts/generate_data.py`) generates realistic, raw time-series data for multiple ad channels, a CRM system, and control variables (like holidays). This simulates pulling from various production APIs.
2.  **Load:** The `dbt seed` command loads the raw CSVs from the `mmm_dbt_project/seeds/` directory into a DuckDB data warehouse, creating a structured, raw data layer.
3.  **Transform:** A series of `dbt` models transform the data.
    * **Staging Models:** Clean, standardize data types, and prepare each raw source independently.
    * **Mart Model:** Joins the staging tables and aggregates the data into the final wide, time-series format required for an MMM.
    * **Data Quality Tests:** `dbt test` validates the integrity of the data throughout the process. This includes checks for nulls, uniqueness, data types, value ranges (e.g., spend is positive and within reasonable bounds), accepted values (e.g., `is_holiday` is 0 or 1), and referential integrity between tables, leveraging both built-in dbt tests and the `dbt-expectations` package.
    
---

## 🛠️ Tech Stack

* **Orchestration:** Bash Script (`run_pipeline.sh`)
* **Transformation & Testing:** [dbt (Data Build Tool)](https://www.getdbt.com/) with the [dbt-expectations](https://github.com/calogica/dbt-expectations) package
* **Data Warehouse:** [DuckDB](https://duckdb.org/) (via `dbt-duckdb`)
* **Core Language & Data Manipulation:** Python 3 & Pandas
* **External Data Libraries:** `holidays` (for generating holiday control variables)

---

## 🚀 Getting Started

### Prerequisites

* Python 3.8+
* Git

### How to Run

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/](https://github.com/)<your-username>/mmm-data-pipeline.git
    cd mmm-data-pipeline
    ```
    *(Remember to replace `MarcusJMyrick` with your actual GitHub username if you're sharing this link.)*

2.  **Set up a virtual environment and install dependencies:**
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip install pandas numpy dbt-core dbt-duckdb holidays dbt-expectations
    ```

3.  **Configure your dbt profile:**
    Create a file at `~/.dbt/profiles.yml` (if it doesn't exist) and add the following profile. This tells dbt how to connect to our DuckDB database file.
    ```yaml
    mmm_dbt_project:
      target: dev
      outputs:
        dev:
          type: duckdb
          path: mmm_dbt.duckdb 
          # Ensure this path is relative to your dbt project, 
          # or an absolute path if you prefer. 
          # If 'mmm_dbt_project' is the root of your dbt project, 
          # dbt will create mmm_dbt.duckdb inside the mmm_dbt_project folder.
    ```

4.  **Install dbt packages:**
    This step installs `dbt-expectations` and `dbt-utils` as defined in `mmm_dbt_project/packages.yml`.
    ```bash
    dbt deps --project-dir mmm_dbt_project
    ```

5.  **Run the entire pipeline:**
    This single command will generate the raw data, load it, transform it, run data quality tests, and export the final table.
    ```bash
    bash run_pipeline.sh
    ```

6.  **Access the Final Data:**
    The final output table is located at `data/processed/mmm_data.csv`.
    
---

## 📂 Project Structure

```
├── data/                 # Ignored by Git, holds generated data
├── mmm_dbt_project/      # The core dbt project for transformations
├── pipeline_scripts/     # Contains the Python script for data generation
├── .gitignore            # Specifies files for Git to ignore
├── README.md             # You are here!
└── run_pipeline.sh       # The main orchestration script
```

---

## 🔮 Future Improvements

This prototype provides a solid foundation. Future enhancements would include:

* **Production Orchestrator:** Replace `run_pipeline.sh` with a production-grade orchestrator like **Airflow** or **Prefect**.
* **Cloud Deployment:** Migrate the pipeline to a cloud environment, using a cloud data warehouse like **BigQuery** or **Snowflake** and storing raw data in **S3** or **GCS**.
* **CI/CD:** Implement a GitHub Actions workflow to automatically run tests and deploy dbt models on every commit.
