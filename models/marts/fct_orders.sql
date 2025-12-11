-- models/marts/fct_orders.sql

{{ 
    config(
        materialized = 'view'
    ) 
}}


with order_header as (
    select
        oh.order_id,
        oh.truck_id,
        oh.location_id,
        oh.customer_id,
        oh.order_ts,
        cast(oh.order_ts as date) as order_date,
        oh.order_currency,
        oh.order_amount,
        cast(oh.order_tax_amount as number)       as order_tax_amount,
        cast(oh.order_discount_amount as number)  as order_discount_amount,
        oh.order_total,
        oh.order_channel
    from {{ ref('raw_pos_order_header') }} oh
),

order_detail_agg as (
    select
        od.order_id,
        sum(od.quantity)           as total_item_quantity,
        count(*)                   as line_count
    from {{ ref('raw_pos_order_detail') }} od
    group by od.order_id
),

joined as (
    select
        oh.*,
        od.total_item_quantity,
        od.line_count,
        t.primary_city,
        t.region,
        t.country,
        t.franchise_flag,
        t.franchise_id,
        f.first_name as franchisee_first_name,
        f.last_name  as franchisee_last_name,
        l.location,
        l.city       as location_city,
        l.region     as location_region,
        l.country    as location_country,
        cl.first_name as customer_first_name,
        cl.last_name  as customer_last_name,
        cl.gender,
        cl.marital_status,
        cl.children_count
    from order_header oh
    left join order_detail_agg od
        on oh.order_id = od.order_id
    left join {{ ref('raw_pos_truck') }} t
        on oh.truck_id = t.truck_id
    left join {{ ref('raw_pos_franchise') }} f
        on t.franchise_id = f.franchise_id
    left join {{ ref('raw_pos_location') }} l
        on oh.location_id = l.location_id
    left join {{ ref('raw_customer_customer_loyalty') }} cl
        on oh.customer_id = cl.customer_id
)

select *
from joined
