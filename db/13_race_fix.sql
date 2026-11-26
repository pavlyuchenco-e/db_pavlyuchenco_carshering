CREATE OR REPLACE PROCEDURE start_trip(
    p_client_id integer, 
    p_car_id integer, 
    p_start_zone_id integer
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE 
    v_is_parking boolean;
BEGIN 
    PERFORM 1
    FROM parking
    WHERE car_id = p_car_id AND zone_id = p_start_zone_id
    FOR UPDATE;
    
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
