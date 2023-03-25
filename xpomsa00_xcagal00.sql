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


CREATE TABLE Worker (
    worker_id INT GENERATED AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    position VARCHAR(100) NOT NULL,
    PRIMARY KEY (worker_id)
);

CREATE TABLE Reservation (
    reservation_id INT GENERATED AS IDENTITY ,
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
    event_id INT GENERATED AS IDENTITY,
    type VARCHAR(100) NOT NULL,
    start_date DATE ,
    end_date DATE ,
    reservation_id INT NOT NULL,
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id),
    PRIMARY KEY (event_id)
);

CREATE TABLE Service (
    service_id INT GENERATED AS IDENTITY ,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    reservation_id INT NOT NULL,
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id),
    PRIMARY KEY (service_id)
);

CREATE TABLE Room_event (
    room_id INT NOT NULL ,
    description VARCHAR(500) NOT NULL,
    price DECIMAL(10, 2) NOT NULL   ,
    type VARCHAR(20) NOT NULL,          
    max_capacity INT CONSTRAINT max CHECK( max_capacity > 0 ),
    area INT CONSTRAINT area CHECK( area > 0 ),
    personal_identification_number VARCHAR (11) NOT NULL,
    event_id INT NOT NULL,
    PRIMARY KEY (room_id),
    FOREIGN KEY (personal_identification_number) REFERENCES Customer(personal_identification_number),
    FOREIGN KEY (event_id) REFERENCES Event(event_id)
    );

CREATE TABLE Room_accommodation (
    room_id INT NOT NULL,
    description VARCHAR(500),
    price DECIMAL(10, 2) NOT NULL   ,
    single_beds INT ,
    double_beds INT ,
    class_luxury VARCHAR(20) CONSTRAINT luxury_check CHECK( class_luxury IN ('Junior Suite','Deluxe Suite', 'Executive Suite', 'Terrace Suite') ),
    personal_identification_number VARCHAR (11) NOT NULL,
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



-- Insert test values into Customer table
INSERT INTO Customer (personal_identification_number, first_name, surname, email, phone)
VALUES
('123456/1234', 'John', 'Doe', 'johndoe@gmail.com', '1234567890');

INSERT INTO Customer (personal_identification_number, first_name, surname, email, phone)
VALUES
('111111/1111', 'Jane', 'Doe', 'janedoe@gmail.com', '9876543210');

INSERT INTO Customer (personal_identification_number, first_name, surname, email, phone)
VALUES
('222222/2222', 'Alice', 'Smith', 'alicesmith@gmail.com', '5555555555');

-- Insert test values into Worker table
INSERT INTO Worker ( name, email, phone, position)
VALUES
('Bob', 'bobsmith@gmail.com', '1234567890', 'Manager');
INSERT INTO Worker (name, email, phone, position)
VALUES
('Sarah', 'sarahjones@gmail.com', '9876543210', 'Receptionist');

-- Insert test values into Reservation table
INSERT INTO Reservation (reservation_type, room_id, event_id, personal_identification_number, worker_id, start_date, end_date, total_price, payment_status)
VALUES
('Accommodation', 1, NULL, '123456/1234', 1, DATE '2023-04-01', DATE'2023-04-05', 500.00, 'Paid');
INSERT INTO Reservation (reservation_type, room_id, event_id, personal_identification_number, worker_id, start_date, end_date, total_price, payment_status)
VALUES
('Event', NULL, 1, '111111/1111', 2, DATE'2023-05-01', DATE'2023-05-02', 100.00, 'Unpaid');

-- Insert test values into Event table
INSERT INTO Event (type, start_date, end_date, reservation_id)
VALUES
('Conference', DATE'2023-05-01', DATE'2023-05-02', 2);

-- Insert test values into Service table
INSERT INTO Service (name, price, reservation_id)
VALUES
('Room service', 20.00, 1);
INSERT INTO Service (name, price, reservation_id)
VALUES
('Extra towels', 10.00, 1);

-- Insert test values into Room_event table
INSERT INTO Room_event (room_id, description, price, type, max_capacity, area, personal_identification_number, event_id)
VALUES
(1, 'Large meeting room', 200.00, 'Conference', 50, 100, '111111/1111', 1);
INSERT INTO Room_event (room_id, description, price, type, max_capacity, area, personal_identification_number, event_id)
VALUES
(2, 'Small meeting room', 100.00, 'Meeting', 10, 50, '111111/1111', 1);

-- Insert test values into Room_accommodation table
INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_identification_number)
VALUES
(1, 'Luxury suite', 200.00, 1, 1, 'Terrace Suite', '123456/1234');
INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_identification_number)
VALUES
(2, 'Standard room', 100.00, 2, 0, 'Junior Suite', '123456/1234');

-- Insert test values into Reserved_rooms_acc table
INSERT INTO Reserved_rooms_acc (reservation_id, room_id)
VALUES
(1, 1);
INSERT INTO Reserved_rooms_acc (reservation_id, room_id)
VALUES
(1, 2);

-- Insert test values into Reserved_rooms_event table
INSERT INTO Reserved_rooms_event (reservation_id, room_id)
VALUES
(2, 1);
