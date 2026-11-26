-- [setup] Устанавливаем клиенту №5 исходный баланс 1500.00
UPDATE clients SET balance = 1500.00 WHERE id = 5;

-- [A] Окно A: начинает транзакцию с уровнем REPEATABLE READ и читает баланс
BEGIN ISOLATION LEVEL REPEATABLE READ;
-- expect: value 1500.00
SELECT balance FROM clients WHERE id = 5;

-- [B] Окно B: меняет баланс клиента №1 на 2000.00 и фиксирует
BEGIN;
UPDATE clients SET balance = 2000.00 WHERE id = 5;
COMMIT;

-- [A] Окно A: читает баланс повторно — видит старый снимок (1500.00)
-- expect: value 1500.00
SELECT balance FROM clients WHERE id = 5;
COMMIT;

-- [cleanup] Возвращаем исходный баланс 1500.00
UPDATE clients SET balance = 1500.00 WHERE id = 1;
