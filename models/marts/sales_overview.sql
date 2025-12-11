SELECT 
    t.truck_id,
    t.primary_city,
    t.year,
    SUM(oh.order_total) AS total_sales,
    SUM(oh.order_amount) AS total_amount,
    SUM(oh.order_tax_amount) AS total_tax
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