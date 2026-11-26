-- [setup] Очищаем активные поездки машины №1
DELETE FROM trips WHERE car_id = 1 AND end_time IS NULL;

-- [A] Окно A проверило, что машина свободна, и начинает поездку
BEGIN;
INSERT INTO trips (client_id, car_id, start_zone_id, end_zone_id, start_time, cost)
VALUES (1, 1, 1, 1, now(), 0.00);

-- [B] Окно B в тот же момент тоже проверило, что машина свободна, и начинает поездку
BEGIN;
INSERT INTO trips (client_id, car_id, start_zone_id, end_zone_id, start_time, cost)
VALUES (3, 1, 1, 1, now(), 0.00);

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check] Активных поездок на машину №1 не больше одной? (Вернет false, т.к. их стало 2!)
-- expect: false
SELECT count(*) <= 1 FROM trips WHERE car_id = 1 AND end_time IS NULL;

-- [cleanup]
DELETE FROM trips WHERE car_id = 1 AND end_time IS NULL;
