-- mmm_dbt_project/models/marts/mmm_aggregated_data.sql

with marketing_data_unioned as (
    -- Combine all standardized marketing data sources into one table
    select date, 'facebook' as channel, spend, impressions, clicks from {{ ref('stg_facebook_spend') }}
    union all
    select date, 'google' as channel, spend, impressions, clicks from {{ ref('stg_google_spend') }}
    union all
    select date, 'tiktok' as channel, spend, impressions, clicks from {{ ref('stg_tiktok_spend') }}
),

aggregated_marketing_metrics as (
    -- Aggregate spend, impressions, and clicks by day and pivot by channel
    select
        date,
        -- Facebook Metrics
        sum(case when channel = 'facebook' then spend else 0 end) as spend_facebook,
        sum(case when channel = 'facebook' then impressions else 0 end) as impressions_facebook,
        sum(case when channel = 'facebook' then clicks else 0 end) as clicks_facebook,

        -- Google Metrics
        sum(case when channel = 'google' then spend else 0 end) as spend_google,
        sum(case when channel = 'google' then impressions else 0 end) as impressions_google,
        sum(case when channel = 'google' then clicks else 0 end) as clicks_google,

        -- TikTok Metrics
        sum(case when channel = 'tiktok' then spend else 0 end) as spend_tiktok,
        sum(case when channel = 'tiktok' then impressions else 0 end) as impressions_tiktok,
        sum(case when channel = 'tiktok' then clicks else 0 end) as clicks_tiktok
        
    from marketing_data_unioned
    group by 1
),

aggregated_sales as (
    -- Aggregate sales by day
    select
        date,
        sum(revenue) as total_revenue
    from {{ ref('stg_crm_sales') }}
    group by 1
)

-- Final Join to create the wide table for the MMM
select
    agg_marketing.date,

    -- Facebook
    agg_marketing.spend_facebook,
    agg_marketing.impressions_facebook,
    agg_marketing.clicks_facebook,

    -- Google
    agg_marketing.spend_google,
    agg_marketing.impressions_google,
    agg_marketing.clicks_google,

    -- TikTok
    agg_marketing.spend_tiktok,
    agg_marketing.impressions_tiktok,
    agg_marketing.clicks_tiktok,

    -- Sales & Control Variables
    coalesce(agg_sales.total_revenue, 0) as total_revenue,
    ctrl.is_holiday
    
from aggregated_marketing_metrics as agg_marketing
left join aggregated_sales as agg_sales on agg_marketing.date = agg_sales.date
left join {{ ref('stg_control_variables') }} as ctrl on agg_marketing.date = ctrl.date
order by agg_marketing.date