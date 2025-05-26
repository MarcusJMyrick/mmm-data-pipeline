select
    date,
    is_holiday
from {{ source('seeds', 'raw_control_variables') }}