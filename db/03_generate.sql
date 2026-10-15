INSERT INTO clients (full_name, license, balance)
SELECT 
    'Клиент №' || i AS full_name,
    10000000 + i AS license,
    ROUND((random() * 5000)::numeric, 2) AS balance
FROM generate_series(1, 1100) AS i;

INSERT INTO cars (num, model)
SELECT 
    (
        -- 1. Первая буква меняется каждые 100 машин
        substring('АВЕКМНОРСТУХ' from ((i / 100) % 12 + 1)::int for 1) ||
        
        -- 2. Цифры идут по порядку
        to_char((i % 999) + 1, 'FM000') ||
        
        -- 3. Вторая и третья буквы меняются в зависимости от остатка деления
        substring('АВЕКМНОРСТУХ' from (i % 12 + 1)::int for 1) ||
        substring('АВЕКМНОРСТУХ' from ((i / 12) % 12 + 1)::int for 1) ||
        
        -- 4. Код региона
        (ARRAY['25', '125', '77', '177', '777', '797', '78', '98', '178', '23', '93', '123', '54', '154', '66', '196', '16', '116', '716'])[floor(random() * 19 + 1)]
    ) AS num,
    CASE (i % 5)
        WHEN 0 THEN 'Kia Rio'
        WHEN 1 THEN 'Hyundai Solaris'
        WHEN 2 THEN 'Volkswagen Polo'
        WHEN 3 THEN 'Skoda Rapid'
        ELSE 'Tesla Model 3'
    END AS model
FROM generate_series(1, 1050) AS i;

INSERT INTO zones (title)
SELECT 
    'Парковочная зона №' || i AS title
FROM generate_series(1, 1000) AS i;


INSERT INTO fines (client_id, title, type_fine, cost, is_paid)
SELECT 
    1 + floor(random() * 1100)::integer AS client_id,
    'Автоматический штраф №' || i AS title,
    CASE WHEN random() > 0.3 THEN 'administrative' ELSE 'internal' END AS type_fine,
    ROUND((500 + random() * 4500)::numeric, 2) AS cost,
    CASE WHEN random() > 0.5 THEN true ELSE false END AS is_paid
FROM generate_series(1, 1200) AS i;


INSERT INTO trips (client_id, car_id, start_zone_id, end_zone_id, start_time, end_time, duration, cost)
SELECT 
    1 + floor(random() * 1100)::integer AS client_id,
    1 + floor(random() * 1050)::integer AS car_id,
    1 + floor(random() * 1000)::integer AS start_zone_id,
    1 + floor(random() * 1000)::integer AS end_zone_id,
    start_t AS start_time,
    start_t + (floor(5 + random() * 115)::text || ' minutes')::interval AS end_time,
    floor(5 + random() * 115)::integer AS duration,
    ROUND((100 + random() * 2000)::numeric, 2) AS cost
FROM (
    SELECT 
        NOW() - (random() * 30 || ' days')::interval AS start_t,
        i
    FROM generate_series(1, 2000) AS i
) AS sub;


INSERT INTO parking (car_id, zone_id)
SELECT 
    i AS car_id,
    1 + floor(random() * 1000)::integer AS zone_id
FROM generate_series(1, 1050) AS i;
