select
    date,
    spend,
    impressions,
    clicks
from {{ source('seeds', 'raw_facebook_spend') }}