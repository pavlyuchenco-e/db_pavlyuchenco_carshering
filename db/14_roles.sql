\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password' IN ROLE app_reader;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;

-- Разрешаем ролям заходить в схему public
GRANT USAGE ON SCHEMA public TO app_reader, app_writer;

GRANT SELECT ON active_trips, driver_profile, mat_zone_stat TO app_reader;

GRANT EXECUTE ON PROCEDURE start_trip(integer, integer, integer) TO app_writer;
GRANT EXECUTE ON FUNCTION calculate_trip_cost(integer, text) TO app_writer;
GRANT EXECUTE ON FUNCTION get_trips_filtered(text, text, numeric) TO app_writer;

-- Гарантируем, что машина №1 припаркована в зоне №1 для теста writer_call
INSERT INTO parking (car_id, zone_id) VALUES (100, 1) ON CONFLICT DO NOTHING;
INSERT INTO parking (car_id, zone_id) VALUES (2, 1) ON CONFLICT DO NOTHING;
