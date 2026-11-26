-- 1. Создаём тестовую роль водителя (Иванов Иван Иванович, id = 1)
CREATE ROLE driver_ivan ;
GRANT USAGE ON SCHEMA public TO driver_ivan;
GRANT SELECT ON trips TO driver_ivan;

-- 2. Включаем Row Level Security на таблице trips
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;

-- 3. Создаём политику: пользователь driver_ivan видит только строки с client_id = 1
CREATE POLICY driver_ivan_trips_policy ON trips
    FOR SELECT
    TO driver_ivan
    USING (client_id = 1);