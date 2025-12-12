select
    t.truck_id,
    t.primary_city,
    t.region,
    t.country,
    t.iso_region,
    t.iso_country_code,
    t.franchise_flag,
    t.franchise_id,
    t.ev_flag,
    t.year          as vehicle_year,
    t.make,
    t.model,
    t.truck_opening_date
from {{ ref('raw_pos_truck') }} t
