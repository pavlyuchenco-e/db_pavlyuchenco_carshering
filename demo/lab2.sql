-- 1. Какие штрафы выписаны конкретным клиентам?
SELECT cl.full_name, f.title, f.cost
FROM clients cl
JOIN fines f ON f.client_id = cl.id;

-- 2. Какую модель машины брал в поездку каждый клиент?
SELECT cl.full_name as client, c.model as car_model
FROM clients cl
LEFT JOIN trips t ON cl.id = t.client_id
LEFT JOIN cars c ON t.car_id = c.id;

-- 3. Какие поездки завершились в зоне 'Арбат'?
SELECT t.id as trip 
FROM trips t
JOIN zones z ON t.end_zone_id = z.id
WHERE z.title = 'Арбат' ;

-- 4. Сколько поездок было совершено на каждой из моделей машин?
SELECT c.model as car_model, count(t.id) as trips
FROM cars c
LEFT JOIN trips t ON c.id = t.car_id
GROUP BY c.model;

-- 5. Какие клиенты совершили более 5 поездок?
SELECT c.full_name as client, count(t.id) as trips
FROM trips t
JOIN clients c ON t.client_id = c.id
GROUP BY c.id 
HAVING count(*) > 5;


-- 6. Какие клиенты еще не совершили ни одной поездки?
SELECT c.full_name
FROM clients c
LEFT JOIN trips t ON t.client_id = c.id
WHERE t.id IS NULL;

-- 7. Кто из клиентов имеет неоплаченные административные штрафы?
SELECT full_name
FROM clients 
WHERE id IN (
    SELECT client_id 
    FROM fines
    WHERE is_paid = false
);

-- 8. Кто из клиентов еще ни разу не получал штраф?
SELECT c.full_name
FROM clients c
WHERE NOT EXISTS(
    SELECT 1 
    FROM fines f
    WHERE f.client_id = c.id
);

-- 9. Вывести уникальные модели машин, на которых совершались поездки, и показать 5 самых дорогих поездок
SELECT DISTINCT c.model as car_model, t.cost as trip_cost
FROM cars c
JOIN trips t ON t.car_id = c.id
ORDER BY t.cost DESC
LIMIT 5;

-- 10. Зарегистрировать нового клиента с балансом 500 рублей
BEGIN;
SELECT id, full_name, license, balance FROM clients;
INSERT INTO clients (full_name, license, balance)
VALUES ('Пермяков Данил Денисович', 23564656, 500.00);
SELECT id, full_name, license, balance FROM clients;
ROLLBACK;

-- 11. Списать 100 рублей со счета 1 клиента за оплату штрафа
BEGIN;
SELECT id, full_name, balance FROM clients 
WHERE id = 1;
UPDATE clients 
SET balance = balance - 100.00 
WHERE id = 1;         
SELECT id, full_name, balance FROM clients 
WHERE id = 1;
ROLLBACK;

-- 12. Удалить из базы штрафы, которые были успешно оплачены
BEGIN;
SELECT * FROM fines;
DELETE FROM fines
WHERE is_paid = true;
SELECT * FROM fines;
ROLLBACK;

-- 13. Вывести топ-3 самых дорогих поездок для каждого клиента
WITH ranked AS (
    SELECT 
        id AS trip_id, 
        client_id, 
        cost,
        row_number() OVER (
            PARTITION BY client_id          
            ORDER BY cost DESC NULLS LAST, id  
        ) AS place 
    FROM trips
)
SELECT 
    c.full_name AS client, 
    r.place, 
    r.trip_id AS trip, 
    r.cost
FROM ranked r
JOIN clients c ON c.id = r.client_id 
WHERE r.place <= 3                  
ORDER BY c.full_name, r.place;

-- 14. Посчитать накопительную сумму трат на поездки для каждого клиента по хронологии
SELECT c.full_name AS client,
        t.id AS trip_id, 
        t.start_time as trip_date, 
        t.cost as trip_cost, 
        sum(t.cost) OVER (
            PARTITION BY t.client_id ORDER BY t.start_time
        ) AS waste
FROM trips t
JOIN clients c ON t.client_id = c.id 
ORDER BY c.full_name, t.start_time;

-- 15. Каков процент неоплаченных штрафов от общего числа штрафов по каждому клиенту?
SELECT 
    c.full_name AS client,
    COUNT(f.id) AS total_fines, 
    COUNT(f.id) FILTER (WHERE f.is_paid = false) AS unpaid_fines,
    ROUND(
        COUNT(f.id) FILTER (WHERE f.is_paid = false) * 100.0 / COUNT(f.id), 2
    ) AS unpaid_percentage
FROM clients c
JOIN fines f ON c.id = f.client_id 
GROUP BY c.id, c.full_name 
ORDER BY unpaid_percentage DESC; 
