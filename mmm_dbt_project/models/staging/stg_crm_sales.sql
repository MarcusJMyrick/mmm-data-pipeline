select
    transaction_date as date, -- Renaming to a standard date column
    revenue
from {{ source('seeds', 'raw_crm_sales') }}