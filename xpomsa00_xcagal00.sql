DROP TABLE Customer;
DROP TABLE Event;
DROP TABLE Service;
DROP TABLE Worker;
DROP TABLE Reservation;
DROP TABLE Room_event;
DROP TABLE Room_accommodation;

CREATE TABLE Customer (
    customer_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (customer_id)
);

CREATE TABLE Event (
    event_id INT NOT NULL AUTO_INCREMENT,
    type VARCHAR(100) NOT NULL,
    -- date DATE NOT NULL,
    -- start_time TIME NOT NULL,
    -- end_time TIME NOT NULL,
    room_id INT ,
    FOREIGN KEY (room_id) REFERENCES Room(room_id),
    location VARCHAR(100) NOT NULL,
    PRIMARY KEY (event_id),
);

CREATE TABLE Service (
    service_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (service_id)
);

CREATE TABLE Worker (
    worker_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    position VARCHAR(100) NOT NULL,
    PRIMARY KEY (worker_id)
);

CREATE TABLE Reservation (
    reservation_id INT NOT NULL AUTO_INCREMENT,
    reservation_type VARCHAR(20) NOT NULL,
    room_id INT,
    event_id INT,
    customer_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    PRIMARY KEY (reservation_id),
    FOREIGN KEY (room_id) REFERENCES Room(room_id),
    FOREIGN KEY (event_id) REFERENCES Event(event_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Room_event (
        room_id INT NOT NULL AUTO_INCREMENT,
        description VARCHAR(500) NOT NULL,
        price DECIMAL(10, 2) NOT NULL   ,
        type VARCHAR(20) NOT NULL,
        max_capacity INT ,
        area INT , 
        -- is_booked BOOLEAN NOT NULL DEFAULT FALSE,
        PRIMARY KEY (room_id)
    );

CREATE TABLE Room_accommodation (
    room_id INT NOT NULL,
    description VARCHAR(500) NOT NULL,
    price DECIMAL(10, 2) NOT NULL   ,
    single_beds INT ,
    double_beds INT ,
    class_luxury VARCHAR(20) NOT NULL,
    -- is_booked BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (room_id)
);
