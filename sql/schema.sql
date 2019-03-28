DROP TABLE IF EXISTS AGENT CASCADE;

CREATE TABLE AGENT (
	username		VARCHAR(40),
	password		VARCHAR(40),

	CONSTRAINT AGENT_PK PRIMARY KEY(username)
);
DROP TABLE IF EXISTS RAIL_LINE CASCADE;

CREATE TABLE RAIL_LINE (
    speed_limit     SMALLINT,
    rail_id         SERIAL,

    CONSTRAINT Rail_PK PRIMARY KEY(rail_id)
);
DROP TABLE IF EXISTS TRAIN CASCADE;

CREATE TABLE TRAIN (
    top_speed       SMALLINT,
    seats           INT,
    ppm             NUMERIC(4, 2),
    train_id        SERIAL,

    CONSTRAINT Train_PK PRIMARY KEY(train_id)
);
DROP TABLE IF EXISTS STATION CASCADE;

CREATE TABLE STATION (
    street_address  VARCHAR(50),
    city            VARCHAR(25),
    zip             CHAR(5),
    open_time       TIME,
    close_time      TIME,
    station_id      SERIAL,

    CONSTRAINT Station_PK PRIMARY KEY(station_id)
);
DROP TABLE IF EXISTS TRAIN_ROUTE CASCADE;

CREATE TABLE TRAIN_ROUTE (
    description		VARCHAR(200),
    route_ID        SERIAL,
    
    CONSTRAINT r_PK PRIMARY KEY(route_id)
);
DROP TABLE IF EXISTS CONNECTION CASCADE;

CREATE TABLE CONNECTION (
    
    station_1       SERIAL,
    station_2       SERIAL,
    rail            SERIAL,
    distance        DECIMAL(6, 2),
    conn_ID         SERIAL,

    CONSTRAINT S1_FK
        FOREIGN KEY(station_1) REFERENCES STATION(station_id),

    CONSTRAINT S2_FK
        FOREIGN KEY(station_2) REFERENCES STATION(station_id),

    CONSTRAINT rail_FK
        FOREIGN KEY(rail) REFERENCES RAIL_LINE(rail_id),

    CONSTRAINT connection_PK PRIMARY KEY(conn_id)
);
DROP TABLE IF EXISTS PASSENGER CASCADE;

CREATE TABLE PASSENGER (
    first_name      VARCHAR(20),
    last_name       VARCHAR(20),
    email           VARCHAR(35),
    phone           CHAR(10),
    street_address  VARCHAR(50),
    city            VARCHAR(25),
    zip             CHAR(5),
    customer_ID     SERIAL,

    CONSTRAINT Passenger_PK PRIMARY KEY(customer_id)
);
DROP TABLE IF EXISTS ROUTE_STATIONS CASCADE;

CREATE TABLE ROUTE_STATIONS (
    ordinal         	SMALLINT,
    stops_here      	BOOLEAN NOT NULL,
    station_id			SERIAL,
    route_id			SERIAL,
    conn_id				INT REFERENCES CONNECTION(conn_id),

    CONSTRAINT sid_FK
        FOREIGN KEY(station_id) REFERENCES STATION(station_id),
    
    CONSTRAINT rid_FK
        FOREIGN KEY(route_id) REFERENCES TRAIN_ROUTE(route_id)
);
DROP TABLE IF EXISTS SCHEDULE CASCADE;

CREATE TABLE SCHEDULE (
    sched_day       INT, -- enum value 1 - 7
    sched_time      TIME,
    t_route         SERIAL,
    train_id		SERIAL,
    is_forward      BOOLEAN,
    sched_id        SERIAL,

    CONSTRAINT sched_route_FK
        FOREIGN KEY(t_route) REFERENCES TRAIN_ROUTE(route_id),

    CONSTRAINT trip_train_fk 
		FOREIGN KEY(train_id) REFERENCES TRAIN(train_id),

    CONSTRAINT sched_PK PRIMARY KEY(sched_id),

    CONSTRAINT valid_day CHECK (sched_day between 1 and 7)
);
DROP TABLE IF EXISTS TRIP CASCADE;

CREATE TABLE TRIP (
	
	sched_id		SERIAL,
	trip_date		date,
	trip_id			SERIAL,
	tickets_sold	INT DEFAULT 0,

	CONSTRAINT trip_pk PRIMARY KEY (trip_id),

	CONSTRAINT trip_sched_fk 
		FOREIGN KEY(sched_id) REFERENCES SCHEDULE(sched_id)

);
DROP TABLE IF EXISTS BOOKING CASCADE;

CREATE TABLE BOOKING (
	agent			VARCHAR(40),
    passenger       INT,
    trip            INT,
    num_tickets     SMALLINT,

    CONSTRAINT agent_FK
    	FOREIGN KEY(agent) REFERENCES AGENT(username),

    CONSTRAINT pass_book_FK
        FOREIGN KEY(passenger) REFERENCES PASSENGER(customer_id),
    
    CONSTRAINT sched_book_FK
        FOREIGN KEY(trip) REFERENCES TRIP(trip_id)
);
DROP FUNCTION IF EXISTS update_tickets_sold() CASCADE;

CREATE FUNCTION update_tickets_sold() 
RETURNS TRIGGER
AS $$
DECLARE
	train RECORD;
	trip_rec RECORD;
	sched RECORD;
BEGIN
	SELECT * FROM TRIP WHERE TRIP.sched_id = NEW.trip INTO trip_rec;
	SELECT * FROM SCHEDULE as s WHERE s.sched_id = trip_rec.sched_id INTO sched;
	SELECT * FROM TRAIN as t WHERE sched.train_id = t.train_id INTO train;
	
	IF trip_rec.tickets_sold + NEW.num_tickets > train.seats
	THEN
		RETURN NULL;
	ELSE
		UPDATE TRIP
		SET tickets_sold = tickets_sold + NEW.num_tickets
		WHERE trip_rec.trip_id = TRIP.trip_id;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_sell_tickets
BEFORE INSERT ON BOOKING
FOR EACH ROW
EXECUTE PROCEDURE update_tickets_sold();
