-- models/marts/fct_customer_360.sql

with customer_base as (
    select
        cl.customer_id,
        cl.first_name,
        cl.last_name,
        cl.e_mail,
        cl.phone_number,
        cl.city,
        cl.country,
        cl.postal_code,
        cl.preferred_language,
        cl.gender,
        cl.favourite_brand,
        cl.marital_status,
        cl.children_count,
        cl.sign_up_date,
        cl.birthday_date
    from {{ ref('raw_customer_customer_loyalty') }} cl
),

customer_orders as (
    select
        o.customer_id,
        count(distinct o.order_id)                        as total_orders,
        sum(o.order_total)                                as total_revenue_usd,
        min(o.order_date)                                 as first_order_date,
        max(o.order_date)                                 as last_order_date
    from {{ ref('fct_orders') }} o
    where o.customer_id is not null
    group by o.customer_id
),

-- optional: last order channel / primary city / truck brand
last_order as (
    select
        o.customer_id,
        o.order_id,
        o.order_date,
        o.order_channel,
        t.primary_city,
        t.region,
        t.country,
        m.truck_brand_name,
        row_number() over (
            partition by o.customer_id
            order by o.order_date desc, o.order_id desc
        ) as rn
    from {{ ref('fct_orders') }} o
    left join {{ ref('raw_pos_truck') }} t
        on o.truck_id = t.truck_id
    left join {{ ref('raw_pos_menu') }} m
        on o.truck_id = m.menu_type_id  -- adjust if needed; this is illustrative
),

last_order_per_customer as (
    select
        customer_id,
        order_id        as last_order_id,
        order_date      as last_order_date_exact,
        order_channel   as last_order_channel,
        primary_city    as last_order_city,
        region          as last_order_region,
        country         as last_order_country,
        truck_brand_name as last_order_truck_brand
    from last_order
    where rn = 1
)

select
    cb.customer_id,

    -- profile
    cb.first_name,
    cb.last_name,
    cb.e_mail,
    cb.phone_number,
    cb.city,
    cb.country,
    cb.postal_code,
    cb.preferred_language,
    cb.gender,
    cb.favourite_brand,
    cb.marital_status,
    cb.children_count,
    cb.sign_up_date,
    cb.birthday_date,

    -- behavior: orders / revenue
    coalesce(co.total_orders, 0)                as total_orders,
    coalesce(co.total_revenue_usd, 0)          as total_revenue_usd,
    co.first_order_date,
    co.last_order_date,

    -- behavior: last order details
    lo.last_order_id,
    lo.last_order_date_exact,
    lo.last_order_channel,
    lo.last_order_city,
    lo.last_order_region,
    lo.last_order_country,
    lo.last_order_truck_brand

from customer_base cb
left join customer_orders co
    on cb.customer_id = co.customer_id
left join last_order_per_customer lo
    on cb.customer_id = lo.customer_id
