-- [setup] Фиксируем исходные балансы клиентов №10 и №11
UPDATE clients SET balance = 1500.00 WHERE id = 10;
UPDATE clients SET balance = 500.00 WHERE id = 11;

-- [A] Окно A: блокирует строку клиента №10
BEGIN;
UPDATE clients SET balance = balance - 10 WHERE id = 10;

-- [B] Окно B: блокирует строку клиента №11
BEGIN;
UPDATE clients SET balance = balance - 10 WHERE id = 11;

-- [A] Окно A: пытается обновить клиента №11 и ждёт освобождения от Окна B
-- expect: blocked
UPDATE clients SET balance = balance + 10 WHERE id = 11;

-- [B] Окно B: пытается обновить клиента №10 — возникает цикл, база убивает транзакцию!
-- expect: error deadlock
UPDATE clients SET balance = balance + 10 WHERE id = 10;

-- [A]
COMMIT;

-- [B]
ROLLBACK;

-- [cleanup] Восстанавливаем балансы
UPDATE clients SET balance = 1500.00 WHERE id = 11;
UPDATE clients SET balance = 500.00 WHERE id = 11   ;