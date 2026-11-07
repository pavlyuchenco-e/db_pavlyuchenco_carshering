-- Лаба 1. Сценарий для показа. Формат описан в docs/scenarios.md.
-- Запуск: dbcheck run demo/lab1.sql, или в psql: \i /demo/lab1.sql

-- 1. Повтор уникального значения: ошибка UNIQUE
-- expect: error unique
-- Описание: Пытаемся добавить машину с уже существующим в базе госномером (из db/02_seed.sql)
INSERT INTO cars (num, model) VALUES ('А123АА25', 'Porsche Cayenne');


-- 2. Нарушение CHECK ограничения: ошибка check
-- expect: error check
-- Описание: Пытаемся добавить клиента с отрицательм балансом (balance < 0)
INSERT INTO clients (full_name, license, balance) 
VALUES ('Новикова Екатерина Владимировна', 99990001, -20.00);


-- 3. Ссылка на несуществующую строку: ошибка fk
-- expect: error fk
-- Описание: Пытаемся выписать штраф на клиента с id = 9999, которого нет в таблице clients
INSERT INTO fines (client_id, title, type_fine, cost, is_paid) 
VALUES (9999, 'Езда без номеров', 'administrative', 5000.00, false);