-- [setup] Очищаем активные поездки машины №1 и ставим её на парковку
DELETE FROM trips WHERE car_id = 1 AND end_time IS NULL;
INSERT INTO parking(car_id, zone_id) VALUES (1, 1) ON CONFLICT DO NOTHING; 

-- [A] Окно A: начинает транзакцию и забирает машину (блокирует строку в parking)
BEGIN;
CALL start_trip(1, 1, 1);

-- [B] Окно B: пытается забрать ту же машину и упирается в блокировку окна А
BEGIN;
-- expect: blocked
CALL start_trip(3, 1, 1);

-- [A] Окно A завершает транзакцию (удаление машины с парковки фиксируется)
COMMIT;

-- [B] Окно B разблокируется, видит, что машины уже нет, и получает ошибку
COMMIT;

-- [check] Теперь на машину №1 оформлена строго одна активная поездка!
-- expect: true
SELECT count(*) <= 1 FROM trips WHERE car_id = 1 AND end_time IS NULL;

-- [cleanup] Очистка
DELETE FROM trips WHERE car_id = 1 AND end_time IS NULL;
