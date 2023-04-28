BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Customer CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Worker CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Reservation CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Event CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Service CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Room_event CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Room_accommodation CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Reserved_rooms_acc CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Reserved_rooms_event CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;

CREATE TABLE Customer
(
    personal_id VARCHAR(10)  NOT NULL
        CONSTRAINT PIN_check_regex
            CHECK (REGEXP_LIKE(personal_id, '^[0-9]{6}[0-9]{4}$') AND NOT REGEXP_LIKE(personal_id, '^[0-9]{6}0000$') and
                   (MOD(personal_id, 11) = 0)),

    first_name  VARCHAR(100) NOT NULL,
    surname     VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL
        CONSTRAINT mail_check_regex
            CHECK (regexp_like(email, '^[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}$')),

    phone       VARCHAR(20)  NOT NULL,

    PRIMARY KEY (personal_id)
);

CREATE TABLE Worker
(
    id         INT GENERATED AS IDENTITY,
    first_name VARCHAR(100) NOT NULL,
    surname    VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL
        CONSTRAINT email_check_regex
            CHECK (regexp_like(email, '^[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}$')),
    phone      VARCHAR(20)  NOT NULL,
    position   VARCHAR(100) NOT NULL,

    PRIMARY KEY (id)
);


CREATE TABLE Reservation
(
    id             INT GENERATED AS IDENTITY,
    type           VARCHAR(20)    NOT NULL,
    room_id        INT,
    event_id       INT,
    personal_id    VARCHAR(10)    NOT NULL,
    worker_id      INT            NOT NULL,
    start_date     DATE           NOT NULL,
    end_date       DATE           NOT NULL,
    num_of_guests  INT            NOT NULL,
    total_price    DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(20)    NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (worker_id) REFERENCES Worker (id),
    FOREIGN KEY (personal_id) REFERENCES Customer (personal_id)
);

CREATE TABLE Event
(
    event_id       INT GENERATED AS IDENTITY,
    type           VARCHAR(100) NOT NULL,
    start_date     DATE,
    end_date       DATE,
    reservation_id INT          NOT NULL,

    PRIMARY KEY (event_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservation (id),
    CONSTRAINT check_date CHECK (end_date > start_date)
);

CREATE TABLE Service
(
    service_id     INT GENERATED AS IDENTITY,
    name           VARCHAR(100)   NOT NULL,
    price          DECIMAL(10, 2) NOT NULL,
    reservation_id INT            NOT NULL,

    PRIMARY KEY (service_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservation (id)
);


-- Our ER diagram had Room for event and Room for accommodation generalized into one 'Room' entity, 
-- since they shared similar attributes, however in our implementation it made more sense 
-- to represent the generalization with distinct tables for each of them, 
-- as they are in relations with different entities
CREATE TABLE Room_event
(
    room_id      INT            NOT NULL,
    description  VARCHAR(500)   NOT NULL,
    price        DECIMAL(10, 2) NOT NULL,
    type         VARCHAR(20)    NOT NULL,
    max_capacity INT
        CONSTRAINT max CHECK ( max_capacity > 0 ),
    area         INT
        CONSTRAINT area CHECK ( area > 0 ),
    personal_id  VARCHAR(11)    NOT NULL,
    event_id     INT            NOT NULL,
    PRIMARY KEY (room_id),
    FOREIGN KEY (personal_id) REFERENCES Customer (personal_id),
    FOREIGN KEY (event_id) REFERENCES Event (event_id)
);

CREATE TABLE Room_accommodation
(
    room_id      INT            NOT NULL,
    description  VARCHAR(500),
    price        DECIMAL(10, 2) NOT NULL,
    single_beds  INT,
    double_beds  INT,
    class_luxury VARCHAR(20)
        CONSTRAINT luxury_check CHECK ( class_luxury IN
                                        ('Junior Suite', 'Deluxe Suite', 'Executive Suite', 'Terrace Suite') ),
    personal_id  VARCHAR(11),
    PRIMARY KEY (room_id),
    FOREIGN KEY (personal_id) REFERENCES Customer (personal_id)
);

CREATE TABLE Reserved_rooms_acc
(
    reservation_id INT NOT NULL,
    room_id        INT NOT NULL,

    PRIMARY KEY (room_id, reservation_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservation (id),
    FOREIGN KEY (room_id) REFERENCES Room_accommodation (room_id)
);

CREATE TABLE Reserved_rooms_event
(
    reservation_id INT NOT NULL,
    room_id        INT NOT NULL,

    PRIMARY KEY (room_id, reservation_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservation (id),
    FOREIGN KEY (room_id) REFERENCES Room_event (room_id)
);



INSERT INTO Customer (personal_id, first_name, surname, email, phone)
VALUES ('3333333333', 'John', 'Doe', 'johndoe@gmail.com', '1234567890');

INSERT INTO Customer (personal_id, first_name, surname, email, phone)
VALUES ('1111111111', 'Jane', 'Doe', 'janedoe@gmail.com', '9876543210');

INSERT INTO Customer (personal_id, first_name, surname, email, phone)
VALUES ('2222222222', 'Julius', 'Pepperwood', 'jpep@yahoo.com', '4205097653');

INSERT INTO Customer (personal_id, first_name, surname, email, phone)
VALUES ('4444444444', 'Todd', 'Chavez', 'tchavez@protonmail.com', '5054204242');

-- Insert test values into Worker table
INSERT INTO Worker (first_name, surname, email, phone, position)
VALUES ('Bob', 'Bobovich', 'bobb@gmail.com', '1234567890', 'Manager');

INSERT INTO Worker (first_name, surname, email, phone, position)
VALUES ('Sarah', 'Connor', 'sarahconnor@gmail.com', '9876543210', 'Receptionist');

-- Insert test values into Reservation table
INSERT INTO Reservation (type, room_id, event_id, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Accommodation', 1, NULL, '3333333333', 1, DATE '2023-04-01', DATE'2023-04-05', 1, 500.00, 'Unpaid');

INSERT INTO Reservation (type, room_id, event_id, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Accommodation', 2, NULL, '2222222222', 2, DATE '2023-01-10', DATE'2023-01-20', 6, 1000.00, 'Paid');

INSERT INTO Reservation (type, room_id, event_id, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Accommodation', NULL, NULL, '4444444444', 1, DATE '2023-02-13', DATE'2023-03-01', 1, 854.00, 'Paid');

INSERT INTO Reservation (type, room_id, event_id, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Event', NULL, 1, '1111111111', 2, DATE'2023-05-01', DATE'2023-05-02', 100.00, 1, 'Unpaid');

INSERT INTO Reservation (type, room_id, event_id, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Event', NULL, 2, '4444444444', 2, DATE'2023-03-15', DATE'2023-03-16', 150.00, 1, 'Paid');

-- Insert test values into Event table
INSERT INTO Event (type, start_date, end_date, reservation_id)
VALUES ('Conference', DATE'2023-05-01', DATE'2023-05-02', 4);

INSERT INTO Event (type, start_date, end_date, reservation_id)
VALUES ('Wedding', DATE'2023-03-15', DATE'2023-03-16', 5);


-- Insert test values into Service table
INSERT INTO Service (name, price, reservation_id)
VALUES ('Room service', 20.00, 2);

INSERT INTO Service (name, price, reservation_id)
VALUES ('Extra towels', 10.00, 1);

-- Insert test values into Room_event table
INSERT INTO Room_event (room_id, description, price, type, max_capacity, area, personal_id, event_id)
VALUES (99, 'Large meeting room', 200.00, 'Conference', 50, 100, '1111111111', 1);

INSERT INTO Room_event (room_id, description, price, type, max_capacity, area, personal_id, event_id)
VALUES (98, 'Small meeting room', 100.00, 'Meeting', 10, 50, '2222222222', 2);


-- Insert test values into Room_accommodation table
INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_id)
VALUES (1, 'Luxury suite', 200.00, 1, 1, 'Executive Suite', '2222222222');

INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_id)
VALUES (2, 'Standard room', 100.00, 2, 0, 'Junior Suite', '3333333333');

INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_id)
VALUES (3, 'Standard room', 100.00, 2, 0, 'Junior Suite', NULL);

INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_id)
VALUES (4, 'Luxury suite 2', 200.00, 1, 2, 'Terrace Suite', '4444444444');

INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_id)
VALUES (5, 'Luxury suite 2', 200.00, 1, 2, 'Terrace Suite', NULL);

INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_id)
VALUES (6, 'Luxury suite 2', 200.00, 2, 2, 'Deluxe Suite', NULL);

INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_id)
VALUES (7, 'Luxury suite 2', 200.00, 2, 2, 'Deluxe Suite', NULL);


-- Insert test values into Reserved_rooms_acc table
INSERT INTO Reserved_rooms_acc (reservation_id, room_id)
VALUES (1, 1);

-- INSERT INTO Reserved_rooms_acc (reservation_id, room_id)
-- VALUES
-- (2, 2);

INSERT INTO Reserved_rooms_acc (reservation_id, room_id)
VALUES (3, 4);


-- Insert test values into Reserved_rooms_event table
INSERT INTO Reserved_rooms_event (reservation_id, room_id)
VALUES (4, 99);

INSERT INTO Reserved_rooms_event (reservation_id, room_id)
VALUES (5, 98);

CREATE OR REPLACE TRIGGER check_availability
    BEFORE UPDATE
    ON Room_accommodation
    FOR EACH ROW
DECLARE
    room_count INT;
    pragma autonomous_transaction;
BEGIN
    SELECT COUNT(*)
    INTO room_count
    FROM Room_accommodation
    WHERE room_id = :new.room_id
    AND :old.personal_id is not null;
    IF :new.personal_id is not null and room_count > 0 then
        raise_application_error(-20100, 'Cannot add customer to already occupied room');
    END IF;
END;

CREATE OR REPLACE TRIGGER max_guests_trigger
    AFTER INSERT
    ON Reserved_rooms_acc
    FOR EACH ROW
DECLARE
    max_guests NUMBER;
    num        NUMBER;
BEGIN
    -- Calculate the maximum number of guests allowed for the room TODO
    SELECT (single_beds + (double_beds * 2))
    INTO max_guests
    FROM Room_accommodation
    WHERE room_id = :new.room_id;

    -- Get the number of guests for the reservation
    SELECT num_of_guests
    INTO num
    FROM Reservation r
    WHERE r.id = :new.reservation_id;

    DBMS_OUTPUT.PUT_LINE('num:' || num || 'MAX:' || max_guests);

    -- Check if the maximum number of guests has been exceeded
    IF num > max_guests THEN
        -- Raise an exception to indicate that the maximum number of guests has been exceeded
        raise_application_error(-20200, 'Maximum number of guests has been exceeded');
    END IF;
END;

------- examples of trigger functionality -------
------- trigger check_availability -------
SELECT room_id, personal_id
from Room_accommodation
where room_id = 1;

BEGIN
    UPDATE Room_accommodation
    SET personal_id = '1111111111'
    WHERE room_id = 1; --room no.1 is already occupied, therefore we cannot assign a new customer to it.
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20100 THEN
            DBMS_OUTPUT.PUT_LINE('EXCEPTION CAUGHT: -20100: room is already occupied');
        END IF;
END;

UPDATE Room_accommodation
SET personal_id = NULL
WHERE room_id = 1; --the old customer must be checked out (set to null) before adding the new one

UPDATE Room_accommodation
SET personal_id = '1111111111'
WHERE room_id = 1;

SELECT room_id, personal_id
from Room_accommodation
where room_id = 1;

------- trigger max_guests_trigger -------
BEGIN
    INSERT INTO Reserved_rooms_acc (reservation_id, room_id)
    VALUES (2, 2);

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20200 THEN
            DBMS_OUTPUT.PUT_LINE('EXCEPTION CAUGHT: -20200: # of customers has been exceeded');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Error ' || SQLCODE || ': ' || SQLERRM);
        END IF;
END;
COMMIT;



