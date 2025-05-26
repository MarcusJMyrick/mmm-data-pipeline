select
    date,
    spend,
    impressions,
    clicks
from {{ source('seeds', 'raw_tiktok_spend') }}