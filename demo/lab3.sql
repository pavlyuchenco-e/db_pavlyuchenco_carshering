-- 1. Проверка двух представлений
SELECT * FROM active_trips;
SELECT * FROM driver_profile ORDER BY id;

-- 2. Проверка скалярной функции расчета стоимости
SELECT 
    calculate_trip_cost(20, 'Tesla Model 3') AS business_cost,
    calculate_trip_cost(20, 'Kia Rio') AS comfort_cost,
    calculate_trip_cost(20, 'Lada Vesta') AS economy_cost;

-- 3. Проверка функции-фильтра с необязательными параметрами 
-- Вызов без параметров (выводит все поездки)
SELECT * FROM get_trips_filtered();
-- Вызов с фильтром по минимальной стоимости
SELECT * FROM get_trips_filtered(p_min_cost => 250.00);

-- 4. Подготовка тестовых данных: ставим машины 1 и 2 на парковку в зону 1
INSERT INTO parking (car_id, zone_id) VALUES (1, 1), (2, 1) ON CONFLICT DO NOTHING;

-- 5. Успешная бизнес-операция: старт поездки для клиента №1 (баланс 1500.00)
CALL start_trip(1, 1, 1);

-- Проверяем, что машина уехала с парковки, а активная поездка появилась
SELECT * FROM parking WHERE car_id = 1;
SELECT * FROM active_trips;

-- 6. Проверка триггера правила: попытка начать поездку с нулевым балансом (клиент ID = 2)
INSERT INTO parking (car_id, zone_id) 
VALUES (2, 1) 
ON CONFLICT DO NOTHING;

-- expect: error
CALL start_trip(2, 2, 1);

-- Дополнительная проверка правила: попытка подменить клиента в поездке на банкрота через UPDATE
-- expect: error
UPDATE trips 
SET client_id = 2
WHERE id = (SELECT MAX(id) FROM trips);

-- 7. Проверка служебного триггера updated_at при завершении поездки
UPDATE trips
SET end_time = start_time + interval '30 minutes',
    cost = calculate_trip_cost(30, 'Toyota')
WHERE id = (SELECT MAX(id) FROM trips)
RETURNING id, cost, updated_at = now() AS timestamp_updated;

-- 8. Обновление и чтение материализованного представления 
REFRESH MATERIALIZED VIEW mat_zone_stat;
SELECT * FROM mat_zone_stat ORDER BY id;

-- 9. Проверка журнала изменений JSONB и среза состояния на время 
SELECT history_id, trip_id, operation, old_data, new_data, changed_by, changed_at 
FROM trips_history 
ORDER BY history_id DESC 
LIMIT 5;

-- Получаем состояние последней поездки на текущий момент в формате JSONB
SELECT get_trip_state_at(
    (SELECT MAX(id) FROM trips), 
    clock_timestamp()
) AS trip_snapshot;
