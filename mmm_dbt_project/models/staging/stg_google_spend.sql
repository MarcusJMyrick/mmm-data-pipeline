select
    date,
    cost as spend, -- Renaming 'cost' to the standard 'spend'
    impressions,
    clicks
from {{ source('seeds', 'raw_google_spend') }}