CREATE OR REPLACE FUNCTION calculate_trip_cost(p_duration integer, p_car_model text)
RETURNS numeric(10,2)
LANGUAGE plpgsql
IMMUTABLE 
AS $$
    DECLARE v_rate numeric(10, 2);
    BEGIN 
        IF p_duration IS NULL or p_duration <= 0 THEN
            RETURN 0.00;
        END IF;
        v_rate := CASE
            WHEN p_car_model ILIKE '%Tesla%'  OR p_car_model ILIKE '%BMW%' OR p_car_model ILIKE '%Audi%' OR p_car_model ILIKE '%Mercedes%'
                THEN 18.00
            WHEN p_car_model ILIKE '%Kia%' OR p_car_model ILIKE '%Skoda%' OR p_car_model ILIKE '%Hyundai%' OR p_car_model ILIKE '%Nissan%'
                THEN 12.50
            ELSE 8.50
        END;

        RETURN ROUND(p_duration * v_rate, 2);
    END;
$$; 

CREATE OR REPLACE PROCEDURE start_trip(
    p_client_id integer, 
    p_car_id integer, 
    p_start_zone_id integer
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_is_parking boolean;
BEGIN 
    SELECT EXISTS(
        SELECT 1
        FROM parking
        WHERE car_id = p_car_id AND zone_id = p_start_zone_id
    ) INTO v_is_parking;

    IF NOT v_is_parking THEN
        RAISE EXCEPTION 'Машина с ID % недоступна для аренды в зоне %', p_car_id, p_start_zone_id;
    END IF;

    DELETE FROM parking 
    WHERE car_id = p_car_id AND zone_id = p_start_zone_id;

    INSERT INTO trips (client_id, car_id, start_zone_id, end_zone_id, start_time, cost)
    VALUES (p_client_id, p_car_id, p_start_zone_id, p_start_zone_id, now(), 0.00);
END;
$$;

CREATE OR REPLACE FUNCTION get_trips_filtered(
    p_client_name text DEFAULT NULL,
    p_car_model text DEFAULT NULL,
    p_min_cost numeric(10, 2) DEFAULT NULL
)
RETURNS TABLE (
    trip_id integer,
    client_name text,
    car_model text,
    start_zone text,
    end_zone text,
    start_time timestamptz,
    cost numeric(10, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id AS trip_id,
        cl.full_name AS client_name,
        ca.model AS car_model,
        zs.title AS start_zone,
        ze.title AS end_zone,
        t.start_time,
        t.cost
    FROM trips t
    JOIN clients cl ON t.client_id = cl.id
    JOIN cars ca ON t.car_id = ca.id
    JOIN zones zs ON t.start_zone_id = zs.id
    JOIN zones ze ON t.end_zone_id = ze.id
    WHERE 
        (p_client_name IS NULL OR cl.full_name ILIKE '%' || p_client_name || '%')
        AND (p_car_model IS NULL OR ca.model ILIKE '%' || p_car_model || '%')
        AND (p_min_cost IS NULL OR t.cost >= p_min_cost)
    ORDER BY t.start_time DESC;
END;
$$;
