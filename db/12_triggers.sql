CREATE OR REPLACE FUNCTION check_client_balance()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_balance numeric(10, 2);
BEGIN
    IF TG_OP = 'INSERT' OR NEW.client_id IS DISTINCT FROM OLD.client_id THEN
        SELECT balance INTO v_balance 
        FROM clients 
        WHERE id = NEW.client_id;

        IF v_balance <= 0 THEN
            RAISE EXCEPTION 'Клиент % не может начать поездку с нулевым балансом (текущий баланс: %)', NEW.client_id, v_balance;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;
CREATE TRIGGER trips_check_balance
BEFORE INSERT OR UPDATE OF client_id
ON trips
FOR EACH ROW EXECUTE FUNCTION check_client_balance();


ALTER TABLE trips 
ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now();
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;
CREATE TRIGGER trips_updated_at
BEFORE UPDATE ON trips
FOR EACH ROW EXECUTE FUNCTION set_updated_at();


CREATE TABLE IF NOT EXISTS trips_history (
    history_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trip_id integer NOT NULL,
    operation text NOT NULL,
    old_data jsonb,
    new_data jsonb,
    changed_by text NOT NULL,
    changed_at timestamptz NOT NULL
);
CREATE OR REPLACE FUNCTION log_trips_changes()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO trips_history (trip_id, operation, old_data, new_data, changed_by, changed_at)
        VALUES (NEW.id, 'INSERT', NULL, to_jsonb(NEW), session_user, clock_timestamp());
        
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD IS DISTINCT FROM NEW THEN
            INSERT INTO trips_history (trip_id, operation, old_data, new_data, changed_by, changed_at)
            VALUES (NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), session_user, clock_timestamp());
        END IF;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO trips_history (trip_id, operation, old_data, new_data, changed_by, changed_at)
        VALUES (OLD.id, 'DELETE', to_jsonb(OLD), NULL, session_user, clock_timestamp());
    END IF;

    RETURN NULL; 
END;
$$;
CREATE TRIGGER trips_log_changes
AFTER INSERT OR UPDATE OR DELETE ON trips
FOR EACH ROW EXECUTE FUNCTION log_trips_changes();


CREATE OR REPLACE FUNCTION get_trip_state_at(
    p_trip_id integer,
    p_target_time timestamptz
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    v_state jsonb;
BEGIN
    SELECT new_data INTO v_state
    FROM trips_history
    WHERE trip_id = p_trip_id
      AND changed_at <= p_target_time
    ORDER BY changed_at DESC
    LIMIT 1;

    RETURN v_state;
END;
$$;
