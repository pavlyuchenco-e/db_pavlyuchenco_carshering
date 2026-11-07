CREATE TABLE clients (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text NOT NULL,
    license integer NOT NULL UNIQUE,
    balance numeric(10, 2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0)
);

CREATE TABLE cars (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    num text NOT NULL UNIQUE,
    model text NOT NULL
);

CREATE TABLE zones (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title text NOT NULL UNIQUE
);

CREATE TABLE fines (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id integer NOT NULL,
    title text NOT NULL,
    type_fine text NOT NULL CHECK (type_fine IN ('administrative', 'internal')),
    cost numeric(10, 2) NOT NULL CHECK (cost > 0),
    is_paid boolean NOT NULL DEFAULT false,
    
    CONSTRAINT fk_fines_client_id FOREIGN KEY (client_id) 
        REFERENCES clients (id) ON DELETE CASCADE
);


CREATE TABLE trips (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id integer NOT NULL,
    car_id integer NOT NULL,
    start_zone_id integer NOT NULL,
    end_zone_id integer NOT NULL,
    start_time timestamptz NOT NULL,
    end_time timestamptz,
    duration integer,
    cost numeric(10, 2) CHECK (cost >= 0),
    
    CONSTRAINT fk_trips_client_id FOREIGN KEY (client_id) 
        REFERENCES clients (id) ON DELETE RESTRICT,
    CONSTRAINT fk_trips_car_id FOREIGN KEY (car_id) 
        REFERENCES cars (id) ON DELETE RESTRICT,
    CONSTRAINT fk_trips_start_zone_id FOREIGN KEY (start_zone_id) 
        REFERENCES zones (id) ON DELETE RESTRICT,
    CONSTRAINT fk_trips_end_zone_id FOREIGN KEY (end_zone_id) 
        REFERENCES zones (id) ON DELETE RESTRICT,
    CONSTRAINT chk_trips_time CHECK (end_time > start_time)
);

CREATE TABLE parking (
    car_id integer,
    zone_id integer,
    
    PRIMARY KEY (car_id, zone_id),
    CONSTRAINT fk_parking_car_id FOREIGN KEY (car_id) 
        REFERENCES cars (id) ON DELETE CASCADE,
    CONSTRAINT fk_parking_zone_id FOREIGN KEY (zone_id) 
        REFERENCES zones (id) ON DELETE RESTRICT
);
