with spend_unioned as (
    -- Combine all standardized spend sources into one table
    select date, 'facebook' as channel, spend, impressions, clicks from {{ ref('stg_facebook_spend') }}
    union all
    select date, 'google' as channel, spend, impressions, clicks from {{ ref('stg_google_spend') }}
    union all
    select date, 'tiktok' as channel, spend, impressions, clicks from {{ ref('stg_tiktok_spend') }}
),

aggregated_spend as (
    -- Aggregate spend by day and pivot by channel
    select
        date,
        sum(case when channel = 'facebook' then spend else 0 end) as spend_facebook,
        sum(case when channel = 'google' then spend else 0 end) as spend_google,
        sum(case when channel = 'tiktok' then spend else 0 end) as spend_tiktok
    from spend_unioned
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
    agg_spend.date,
    agg_spend.spend_facebook,
    agg_spend.spend_google,
    agg_spend.spend_tiktok,
    coalesce(agg_sales.total_revenue, 0) as total_revenue,
    ctrl.is_holiday
from aggregated_spend as agg_spend
left join aggregated_sales as agg_sales on agg_spend.date = agg_sales.date
left join {{ ref('stg_control_variables') }} as ctrl on agg_spend.date = ctrl.date
order by agg_spend.date