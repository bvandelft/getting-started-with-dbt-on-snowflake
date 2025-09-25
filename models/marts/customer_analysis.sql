SELECT 
    cl.customer_id,
    cl.first_name,
    cl.last_name,
    cl.e_mail,
    cl.phone_number,
    cl.children_count,
    cl.gender,
    cl.marital_status,
    COUNT(oh.order_id) AS total_orders,
    SUM(oh.order_total) AS total_spent,
    AVG(oh.order_total) AS average_order_value
FROM {{ ref('raw_customer_customer_loyalty') }} cl
LEFT JOIN {{ ref('raw_pos_order_header') }} oh
    ON cl.customer_id = oh.customer_id
GROUP BY 
    cl.customer_id,
    cl.first_name,
    cl.last_name,
    cl.e_mail,
    cl.phone_number,
    cl.children_count,
    cl.gender,
    cl.marital_status