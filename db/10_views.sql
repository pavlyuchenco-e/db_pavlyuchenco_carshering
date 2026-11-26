CREATE OR REPLACE VIEW active_trips AS 
SELECT 
    cl.full_name as full_name,
    ca.model as car_model,
    z.title as start_zone,
    t.start_time as start_time
FROM trips t
JOIN cars ca ON t.car_id = ca.id
JOIN clients cl ON t.client_id = cl.id
JOIN zones z ON t.start_zone_id = z.id
WHERE t.end_time IS NULL;

CREATE OR REPLACE VIEW driver_profile AS 
WITH trip_stats AS (
    SELECT client_id, count(id) AS trips_count
    FROM trips
    GROUP BY client_id 
),
fine_stats AS (
    SELECT client_id, SUM(cost) AS total_fines
    FROM fines
    GROUP BY client_id
)
SELECT 
    c.id,
    c.full_name,
    c.balance,
    COALESCE(ts.trips_count, 0) AS trips,
    COALESCE(fs.total_fines, 0.00) AS fines
FROM clients c
LEFT JOIN trip_stats ts ON c.id = ts.client_id
LEFT JOIN fine_stats fs ON c.id = fs.client_id;

CREATE  MATERIALIZED VIEW mat_zone_stat AS 
WITH start_stats AS (
    SELECT start_zone_id as zone_id, count(id) AS cnt
    FROM trips
    GROUP BY start_zone_id
),
end_stats AS (
    SELECT end_zone_id as zone_id, count(id) AS cnt
    FROM trips
    GROUP BY end_zone_id
)
SELECT 
    z.id,
    z.title,
    COALESCE(s.cnt, 0) AS starts_count, 
    COALESCE(e.cnt, 0) AS ends_count   
FROM zones z
LEFT JOIN start_stats s ON z.id = s.zone_id
LEFT JOIN end_stats e ON z.id = e.zone_id;




