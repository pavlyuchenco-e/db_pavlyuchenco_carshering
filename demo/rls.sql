-- 1. Под суперпользователем видны поездки всех клиентов (больше 1000 строк)
-- expect: rows >= 1000
SELECT id, client_id FROM trips;

-- 2. Переключаемся на роль водителя Ивана (client_id = 1)
SET ROLE driver_ivan;

-- 3. Проверяем, что чужих поездок не видно (вернёт true, т.к. 0 чужих строк)
-- expect: true
SELECT count(*) = 0 FROM trips WHERE client_id <> 1;

-- 4. Возвращаем роль суперпользователя
RESET ROLE;
