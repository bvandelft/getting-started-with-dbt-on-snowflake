{{  
    config(materialized='table')
}}

with base_dates as (
    {{
        dbt.date_spine(
            'day',
            "'2000-01-01'",
            "'2030-01-01'"
        )
    }}
)

select
    date_day
from base_dates
