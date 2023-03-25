DROP TABLE Customer CASCADE CONSTRAINTS;
DROP TABLE Event CASCADE CONSTRAINTS;
DROP TABLE Service CASCADE CONSTRAINTS;
DROP TABLE Worker CASCADE CONSTRAINTS;
DROP TABLE Reservation CASCADE CONSTRAINTS;
DROP TABLE Room_event CASCADE CONSTRAINTS;
DROP TABLE Room_accommodation CASCADE CONSTRAINTS;
DROP TABLE Reserved_rooms_acc CASCADE CONSTRAINTS;
DROP TABLE Reserved_rooms_event CASCADE CONSTRAINTS;

CREATE TABLE Customer (
    personal_identification_number VARCHAR(11) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (personal_identification_number)
);

ALTER TABLE Customer ADD CONSTRAINT PIN_check_regex
CHECK (regexp_like(personal_identification_number, '^[0-9]{6}/[0-9]{4}$') );

-- ALTER TABLE Customer ADD CONSTRAINT PIN_check_11
-- CHECK(mod(personal_identification_number,11) = 0);

CREATE TABLE Worker (
    worker_id INT NOT NULL ,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    position VARCHAR(100) NOT NULL,
    PRIMARY KEY (worker_id)
);

CREATE TABLE Reservation (
    reservation_id INT NOT NULL ,
    reservation_type VARCHAR(20) NOT NULL,
    room_id INT,
    event_id INT,
    personal_identification_number VARCHAR (11) NOT NULL,
    worker_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    PRIMARY KEY (reservation_id),
    CONSTRAINT worker_id FOREIGN KEY (worker_id) REFERENCES Worker(worker_id),
    FOREIGN KEY (personal_identification_number) REFERENCES Customer(personal_identification_number)
);

CREATE TABLE Event (
    event_id INT NOT NULL,
    type VARCHAR(100) NOT NULL,
    start_date DATE ,
    end_date DATE ,
    reservation_id INT ,
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id),
    PRIMARY KEY (event_id)
);

CREATE TABLE Service (
    service_id INT NOT NULL ,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    reservation_id INT ,
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id),
    PRIMARY KEY (service_id)
);

CREATE TABLE Room_event (
    room_id INT NOT NULL ,
    description VARCHAR(500) NOT NULL,
    price DECIMAL(10, 2) NOT NULL   ,
    type VARCHAR(20) NOT NULL,          
    max_capacity INT ,
    area INT ,
    personal_identification_number VARCHAR (11),
    event_id INT,
    PRIMARY KEY (room_id),
    FOREIGN KEY (personal_identification_number) REFERENCES Customer(personal_identification_number),
    FOREIGN KEY (event_id) REFERENCES Event(event_id)
    );

CREATE TABLE Room_accommodation (
    room_id INT NOT NULL,
    description VARCHAR(500) NOT NULL,
    price DECIMAL(10, 2) NOT NULL   ,
    single_beds INT ,
    double_beds INT ,
    class_luxury VARCHAR(20) NOT NULL,
    personal_identification_number VARCHAR (11),
    PRIMARY KEY (room_id),
    FOREIGN KEY (personal_identification_number) REFERENCES Customer(personal_identification_number)
);

CREATE TABLE Reserved_rooms_acc (
    reservation_id INT NOT NULL,
    room_id INT NOT NULL ,
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id),
    FOREIGN KEY (room_id) REFERENCES Room_accommodation(room_id)
);

CREATE TABLE Reserved_rooms_event (
    reservation_id INT NOT NULL,
    room_id INT NOT NULL ,
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id),
    FOREIGN KEY (room_id) REFERENCES Room_event(room_id)
);
