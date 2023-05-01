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
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW current_hotel_state';
    Execute Immediate 'DROP INDEX index_res';
    EXECUTE IMMEDIATE 'DROP INDEX index_ser';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 AND SQLCODE != -12003 AND SQLCODE != -1418 THEN
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
INSERT INTO Reservation (type, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Accommodation', '3333333333', 1, DATE '2023-05-01', DATE'2023-05-05', 1, 500.00, 'Unpaid');

INSERT INTO Reservation (type, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Accommodation', '2222222222', 2, DATE '2023-01-10', DATE'2023-01-20', 6, 1000.00, 'Unpaid');

INSERT INTO Reservation (type, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Accommodation', '4444444444', 1, DATE '2023-02-13', DATE'2023-03-01', 1, 854.00, 'Unpaid');

INSERT INTO Reservation (type, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Event', '1111111111', 2, DATE'2023-05-01', DATE'2023-05-02', 100.00, 1, 'Unpaid');

INSERT INTO Reservation (type, personal_id, worker_id, start_date, end_date, num_of_guests,
                         total_price, payment_status)
VALUES ('Event', '4444444444', 2, DATE'2023-03-15', DATE'2023-03-16', 150.00, 1, 'Unpaid');

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

INSERT INTO Reserved_rooms_acc (reservation_id, room_id)
VALUES (2, 2);

INSERT INTO Reserved_rooms_acc (reservation_id, room_id)
VALUES (3, 4);


-- Insert test values into Reserved_rooms_event table
INSERT INTO Reserved_rooms_event (reservation_id, room_id)
VALUES (4, 99);

INSERT INTO Reserved_rooms_event (reservation_id, room_id)
VALUES (5, 98);



-------------- TRIGGER - check if room is available --------------
------------------------------------------------------------------


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

-- SELECT room_id, personal_id
-- from Room_accommodation
-- where room_id = 1;
--
-- BEGIN
--     UPDATE Room_accommodation
--     SET personal_id = '1111111111'
--     WHERE room_id = 1; --room no.1 is already occupied, therefore we cannot assign a new customer to it.
-- EXCEPTION
--     WHEN OTHERS THEN
--         IF SQLCODE = -20100 THEN
--             DBMS_OUTPUT.PUT_LINE('EXCEPTION CAUGHT: -20100: room is already occupied');
--         END IF;
-- END;
--
-- UPDATE Room_accommodation
-- SET personal_id = NULL
-- WHERE room_id = 1; --the old customer must be checked out (set to null) before adding the new one
--
-- UPDATE Room_accommodation
-- SET personal_id = '1111111111'
-- WHERE room_id = 1;


-------------- TRIGGER - reservation paid  --------------
---------------------------------------------------------

CREATE OR REPLACE TRIGGER reservation_paid_trigger
    AFTER UPDATE
    ON Reservation
    FOR EACH ROW
DECLARE
    v_reservation_status VARCHAR2(20);
    pragma autonomous_transaction;

BEGIN
    -- Get the updated reservation status
    SELECT payment_status INTO v_reservation_status FROM Reservation WHERE Reservation.id = :NEW.id;

    -- Check if the reservation has been paid
    IF v_reservation_status = 'Paid' THEN
        -- Set the customer assigned to the room to null

        UPDATE Room_accommodation
        SET personal_id = null
        WHERE room_id = (SELECT room_id FROM Reserved_rooms_acc WHERE reservation_id = :NEW.id);

        -- Remove the row from the reserved_room table
        DELETE FROM Reserved_rooms_acc WHERE reservation_id = :new.id;
        COMMIT;
    END IF;

END;

-- before update
-- select res.id, payment_status, room.personal_id
-- from Reservation res
--          join Reserved_rooms_acc res_room on res.id = res_room.reservation_id
--          join Room_accommodation room on res_room.room_id = room.room_id
-- where id = 1;

-- UPDATE Reservation
-- set payment_status = 'Paid'
-- where id = 1;

-- after update
-- select res.id, payment_status, room.personal_id
-- from Reservation res
--          join Reserved_rooms_acc res_room on res.id = res_room.reservation_id
--          join Room_accommodation room on res_room.room_id = room.room_id
-- where id = 1;
--


-------------- Procedure - calculate the price of a stay --------------
-----------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE calculate_total_price(
    in_reservation_id IN INT
)
AS
    l_start_date    Reservation.start_date%TYPE;
    l_end_date      Reservation.end_date%TYPE;
    l_num_of_nights INT     := 0; -- initialize to 0
    l_room_price    DECIMAL := 0; -- initialize to 0
    l_event_price   DECIMAL := 0; -- initialize to 0
    l_event_start   Event.start_date%TYPE;
    l_event_end     Event.start_date%TYPE;
    l_event_length  INT     := 0; -- initialize to 0
    l_service_price DECIMAL := 0; -- initialize to 0
    l_total_price   DECIMAL := 0; -- initialize to 0
BEGIN

    -- get the length of the stay
    SELECT start_date, end_date
    INTO l_start_date, l_end_date
    FROM Reservation
    WHERE id = in_reservation_id;

    l_num_of_nights := COALESCE(l_end_date - l_start_date, 0);

    BEGIN
        SELECT Room_accommodation.price
        INTO l_room_price
        FROM Reservation
                 JOIN Reserved_rooms_acc ON Reservation.id = Reserved_rooms_acc.reservation_id
                 JOIN Room_accommodation ON Reserved_rooms_acc.room_id = Room_accommodation.room_id
        WHERE Reservation.id = in_reservation_id;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -01403 THEN
                l_room_price := 0;
            END IF;
    END;


    BEGIN
        SELECT Room_event.price
        INTO l_event_price
        FROM Reservation
                 JOIN Event ON Reservation.id = Event.reservation_id
                 JOIN Room_event ON Event.event_id = Room_event.event_id
        WHERE Reservation.id = in_reservation_id;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -01403 THEN
                l_event_price := 0;
            END IF;
    END;


    BEGIN
        SELECT Event.start_date, Event.end_date
        INTO l_event_start, l_event_end
        FROM Reservation
                 JOIN Event ON Reservation.id = Event.reservation_id
        WHERE Reservation.id = in_reservation_id;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -01403 THEN
                l_event_length := 0;
            end if;
    END;

    l_event_length := COALESCE(l_event_end - l_event_start, 0);


    BEGIN
        SELECT Service.price
        INTO l_service_price
        FROM Reservation
                 JOIN Service ON Reservation.id = Service.reservation_id
        WHERE Reservation.id = in_reservation_id;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -01403 THEN
                l_service_price := 0;
            end if;
    END;

    l_total_price := COALESCE((l_room_price * l_num_of_nights) + (l_event_price * l_event_length) + l_service_price, 0);


    UPDATE Reservation
    SET total_price = l_total_price
    WHERE id = in_reservation_id;


    DBMS_OUTPUT.PUT_LINE('--- PAYMENT FOR RESERVATION: ' || in_reservation_id || '---');
    DBMS_OUTPUT.PUT_LINE('  Room: ' || l_room_price || '/ day');
    DBMS_OUTPUT.PUT_LINE('  Events: ' || l_event_price || '/ day');
    DBMS_OUTPUT.PUT_LINE('  Services: ' || l_service_price);
    DBMS_OUTPUT.PUT_LINE('  # of days: ' || l_num_of_nights);
    DBMS_OUTPUT.PUT_LINE('  TOTAL: ' || l_total_price);
END;

DECLARE
    reservation_id Reservation.id%TYPE;
    CURSOR reservation_cur IS
        SELECT id
        FROM Reservation;
BEGIN
    FOR res IN reservation_cur
        LOOP
            reservation_id := res.id;
            calculate_total_price(reservation_id);
        END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -01403 THEN
            BEGIN
                DBMS_OUTPUT.PUT_LINE('invalid reservation id');
            END;
        END IF;
END;



-------------- Procedure - check if num of customers is less then max capacity --------------
---------------------------------------------------------------------------------------------


INSERT INTO Room_accommodation (room_id, description, price, single_beds, double_beds, class_luxury, personal_id)
VALUES (8, 'Luxury suite', 200.00, 1, 1, 'Executive Suite', '2222222222');

INSERT INTO Reserved_rooms_acc (reservation_id, room_id)
VALUES (1, 8);



CREATE OR REPLACE PROCEDURE check_num_of_customers(
    in_reservation_id IN INT
)
AS
    l_num_of_guests  INT;
    l_available_beds INT;


BEGIN
    BEGIN
        SELECT num_of_guests
        INTO l_num_of_guests
        FROM Reservation
        WHERE id = in_reservation_id;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -01403 THEN
                DBMS_OUTPUT.PUT_LINE('Invalid reservation id');
            end if;
    END;


    SELECT SUM(total_num_of_beds)
    INTO l_available_beds
    FROM (SELECT ((double_beds * 2) + single_beds)
                     AS total_num_of_beds
          FROM Reserved_rooms_acc
                   JOIN Room_accommodation ON Reserved_rooms_acc.room_id = Room_accommodation.room_id
          WHERE Reserved_rooms_acc.reservation_id = in_reservation_id);

    DBMS_OUTPUT.PUT_LINE('guest num ' || l_num_of_guests);
    DBMS_OUTPUT.PUT_LINE('available beds ' || l_available_beds);

    IF l_num_of_guests > l_available_beds THEN
        RAISE_APPLICATION_ERROR(-20200, 'Number of guests exceeded the available beds for this reservation');
    end if;

END;

BEGIN
    check_num_of_customers(2);
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20200 THEN
            DBMS_OUTPUT.PUT_LINE('EXCEPTION CAUGHT: -20200 : Number of guests exceeded the available beds for this reservation');
        end if;
END;



-------------- Granting privileges --------------
-------------------------------------------------


GRANT ALL PRIVILEGES ON Customer TO XCAGAL00;
GRANT ALL PRIVILEGES ON Worker TO XCAGAL00;
GRANT ALL PRIVILEGES ON Reservation TO XCAGAL00;
GRANT ALL PRIVILEGES ON Event TO XCAGAL00;
GRANT ALL PRIVILEGES ON Service TO XCAGAL00;
GRANT ALL PRIVILEGES ON Room_event TO XCAGAL00;
GRANT ALL PRIVILEGES ON Room_accommodation TO XCAGAL00;
GRANT ALL PRIVILEGES ON Reserved_rooms_event TO XCAGAL00;
GRANT ALL PRIVILEGES ON Reserved_rooms_acc TO XCAGAL00;

GRANT EXECUTE ON calculate_total_price TO XCAGAL00;
GRANT EXECUTE ON check_num_of_customers TO XCAGAL00;



-------------- EXPLAIN PLAN, INDEX --------------
-------------------------------------------------


SELECT index_name, table_name
FROM user_indexes;
-- In PL/SQL, EXPLAIN PLAN generates a query execution plan that shows how Oracle will execute a SQL statement
EXPLAIN PLAN FOR
    SELECT TO_CHAR(start_date,'MM') AS month, COUNT(*) as number_of_reservations,COUNT(service_id) as number_of_services,
       COALESCE( SUM(S.price) , 0) as service_price , SUM(total_price)  as total_price
    FROM Reservation
    LEFT JOIN Service S on Reservation.id = S.reservation_id
    GROUP BY(TO_CHAR(start_date,'MM'))
    ORDER BY(TO_CHAR(start_date, 'MM'));

-- before index
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- An index can optimize a SELECT statement by storing a copy of frequently used columns
-- in a separate structure, allowing to retrieve data faster.
CREATE INDEX index_res ON Reservation(start_date);
CREATE INDEX index_ser ON Service(reservation_id);

SELECT index_name, table_name
FROM user_indexes;

-- After creating an index, EXPLAIN PLAN can generate a new query execution plan
-- that shows how Oracle will execute the SQL statement with the new index
EXPLAIN PLAN FOR
    SELECT TO_CHAR(start_date,'MM') AS month, COUNT(*) as number_of_reservations,COUNT(service_id) as number_of_services,
       COALESCE( SUM(S.price) , 0) as service_price , SUM(total_price)  as total_price
    FROM Reservation
    LEFT JOIN Service S on Reservation.id = S.reservation_id
    GROUP BY(TO_CHAR(start_date,'MM'))
    ORDER BY(TO_CHAR(start_date, 'MM'));

-- After index
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());


-------------- MATERIALIZED VIEW current_hotel_state --------------
-------------------------------------------------------------------


CREATE MATERIALIZED VIEW current_hotel_state
AS
SELECT Res.id           AS Reservation,
       Cust.first_name  AS Name,
       Cust.surname     AS Surname,
       Cust.personal_id AS pid,
       W.id             AS Worker,
       W.surname        AS Worker_surname,
       RA.room_id       AS Room_acc,
       E.type           AS Event,
       RE.room_id       AS Room_event,
       SE.name          AS Service,
       Res.total_price
FROM Customer Cust
         JOIN Reservation Res ON Cust.personal_id = Res.personal_id
         JOIN Worker W ON Res.worker_id = W.id
         LEFT JOIN Reserved_rooms_acc RRA ON Res.id = RRA.reservation_id
         LEFT JOIN Room_accommodation RA ON RRA.room_id = RA.room_id
         LEFT JOIN Event E ON Res.id = E.reservation_id
         LEFT JOIN Room_event RE ON E.event_id = RE.event_id
         LEFT JOIN Service SE ON Res.id = SE.reservation_id
ORDER BY Res.id;

GRANT ALL PRIVILEGES ON current_hotel_state TO XCAGAL00;

-- current state
SELECT *
FROM current_hotel_state;

-- select display all workers and which reservations they are currently managing
SELECT DISTINCT Worker, Worker_surname, Reservation
From CURRENT_HOTEL_STATE
ORDER BY Worker;

-- select display all reservations, surname and total price
SELECT Distinct Reservation, Surname, total_price
From CURRENT_HOTEL_STATE
ORDER BY Reservation;

-- every event, location of event and price
SELECT Event, Room_event, total_price
From CURRENT_HOTEL_STATE
Where Event is not null;

-- every accomodation, location and price
SELECT Distinct Reservation, Room_acc, total_price
From CURRENT_HOTEL_STATE
Where Room_acc is not null
ORDER BY Reservation;



-------------- SELECT WITH, CASE --------------
-----------------------------------------------


WITH room_acc_stats AS (SELECT Room_accommodation.room_id,
                               CASE
                                   WHEN class_luxury = 'Junior Suite' THEN 100
                                   WHEN class_luxury = 'Deluxe Suite' THEN 150
                                   WHEN class_luxury = 'Executive Suite' THEN 250
                                   WHEN class_luxury = 'Terrace Suite' THEN 350
                                   ELSE 0
                                   END AS room_rate,
                               CASE
                                   WHEN payment_status = 'Unpaid' THEN 'Occupied'
                                   ELSE 'Available'
                                   END AS room_status
                        FROM Room_accommodation
                                 LEFT OUTER JOIN Reserved_rooms_acc
                                                 on Room_accommodation.room_id = Reserved_rooms_acc.room_id
                                 LEFT OUTER JOIN Reservation ON Reserved_rooms_acc.reservation_id = Reservation.id)
SELECT room_id, room_rate, room_status
FROM room_acc_stats
WHERE room_rate > 0
ORDER BY room_id
        ASC;

COMMIT;
