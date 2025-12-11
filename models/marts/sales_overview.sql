SELECT 
    t.truck_id,
    t.primary_city,
    t.year,
    COUNT(oh.order_id) AS total_orders,
    SUM(oh.order_total) AS total_sales,
    AVG(oh.order_total) AS average_order_value
FROM 
    {{ ref('raw_pos_order_header') }} oh
JOIN 
    {{ ref('raw_pos_truck') }} t ON oh.truck_id = t.truck_id
WHERE 
    oh.order_ts >= DATEADD(year, -5, CURRENT_DATE)
GROUP BY 
    t.truck_id, 
    t.primary_city, 
    t.year
ORDER BY 
    t.truck_id, 
    t.year