# pipeline_scripts/generate_data.py
import pandas as pd
import numpy as np
import os
import holidays # type: ignore

print("--- Generating Synthetic Raw Data ---")

# Create directories if they don't exist
os.makedirs("data/raw", exist_ok=True)

# Configuration
START_DATE = "2022-01-01"
END_DATE = "2024-05-26"
DATES = pd.to_datetime(pd.date_range(start=START_DATE, end=END_DATE))

# Generate Marketing Spend Data
def generate_spend_data(channel_name, spend_multiplier, spend_col_name='spend'):
    df = pd.DataFrame({'date': DATES})
    # Create seasonality + noise
    spend = (
        (np.sin(np.arange(len(DATES)) / (365 / (2 * np.pi))) + 1.5) * spend_multiplier +
        np.random.rand(len(DATES)) * (spend_multiplier / 2)
    )
    impressions = spend * (20 + np.random.rand(len(DATES)) * 10)
    clicks = impressions * (0.02 + np.random.rand(len(DATES)) * 0.01)

    df[spend_col_name] = spend.astype(int)
    df['impressions'] = impressions.astype(int)
    df['clicks'] = clicks.astype(int)
    df['campaign_id'] = f"{channel_name}_" + (df.index % 5 + 1).astype(str)

    # Save to the correct relative path
    df.to_csv(f"data/raw/raw_{channel_name}_spend.csv", index=False)
    print(f"Generated data/raw/raw_{channel_name}_spend.csv")

# Generate data for different channels, note the different spend column for Google
generate_spend_data('facebook', 500, 'spend')
generate_spend_data('google', 800, 'cost') 
generate_spend_data('tiktok', 300, 'spend')

# Generate CRM Sales Data
sales_df = pd.DataFrame({'transaction_date': DATES})
total_spend_factor = (
    (np.sin(np.arange(len(DATES)) / (365 / (2 * np.pi))) + 1.5) * (500 + 800 + 300)
)
organic_growth = np.linspace(10000, 25000, len(DATES))
sales_df['revenue'] = (total_spend_factor * 0.1 + organic_growth + np.random.rand(len(DATES)) * 5000).astype(int)

sales_df.to_csv("data/raw/raw_crm_sales.csv", index=False)
print("Generated data/raw/raw_crm_sales.csv")

# Generate Control Variables
control_df = pd.DataFrame({'date': DATES})
us_holidays = holidays.US(years=range(2022, 2026))
control_df['is_holiday'] = control_df['date'].isin(us_holidays).astype(int)

control_df.to_csv("data/raw/raw_control_variables.csv", index=False)
print("Generated data/raw/raw_control_variables.csv")

print("--- Synthetic Data Generation Complete ---")