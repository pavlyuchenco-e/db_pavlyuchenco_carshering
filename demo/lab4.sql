-- 1. Фиксируем исходный баланс клиента №1
SELECT balance FROM clients WHERE id = 1;

-- 2. Транзакция падает в середине (у клиента №2 баланс = 0)
-- expect: error raise
BEGIN;
UPDATE clients SET balance = balance + 500 WHERE id = 1;
CALL start_trip(2, 2, 1);
COMMIT;

-- 3. Проверяем, что баланс клиента №1 не изменился (совпадает с шагом 1)
-- expect: same 1
SELECT balance FROM clients WHERE id = 1;

-- 4. Роль app_reader может читать представления
SET ROLE app_reader;
SELECT * FROM active_trips LIMIT 1;
RESET ROLE;

-- 5. Роль app_reader не может читать таблицы напрямую
-- expect: error permission
SET ROLE app_reader;
SELECT * FROM clients LIMIT 1;

-- 6. Роль app_reader не может вызывать процедуры
-- expect: error permission
CALL start_trip(1, 100, 1);
RESET ROLE;

-- 7. Роль app_writer не может менять таблицы напрямую
-- expect: error permission
SET ROLE app_writer;
DELETE FROM fines;
RESET ROLE;
