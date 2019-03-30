DROP TABLE IF EXISTS AGENT CASCADE;

CREATE TABLE AGENT (
	username		VARCHAR(40),
	password		VARCHAR(40),

	CONSTRAINT AGENT_PK PRIMARY KEY(username)
);
DROP TABLE IF EXISTS RAIL_LINE CASCADE;

CREATE TABLE RAIL_LINE (
    speed_limit     INT,
    rail_id         SERIAL,

    CONSTRAINT Rail_PK PRIMARY KEY(rail_id)
);
DROP TABLE IF EXISTS TRAIN CASCADE;

CREATE TABLE TRAIN (
    top_speed       INT,
    seats           INT,
    ppm             NUMERIC(6, 2),
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
    
    station_1       INT,
    station_2       INT,
    rail            INT,
    distance        NUMERIC(6, 2),
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
    ordinal         	INT,
    stops_here      	BOOLEAN NOT NULL,
    station_id			INT,
    route_id			INT,
    conn_id				INT REFERENCES CONNECTION(conn_id),
    rs_id				SERIAL,

    CONSTRAINT rs_PK PRIMARY KEY(rs_id),

    CONSTRAINT sid_FK
        FOREIGN KEY(station_id) REFERENCES STATION(station_id),
    
    CONSTRAINT rid_FK
        FOREIGN KEY(route_id) REFERENCES TRAIN_ROUTE(route_id)
);
DROP TABLE IF EXISTS SCHEDULE CASCADE;

CREATE TABLE SCHEDULE (
    sched_day       INT, -- enum value 1 - 7
    sched_time      TIME,
    t_route         INT,
    train_id		INT,
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
	
	sched_id		INT,
	seats_left		INT,
	rs_id			INT,
	trip_distance 	NUMERIC(6, 2),
	trip_cost		NUMERIC(6, 2),
	trip_time		INTERVAL,
	arrival_time	TIME,
	depart_station	INT,
	trip_id			SERIAL,	

	CONSTRAINT trip_pk PRIMARY KEY (trip_id),

	CONSTRAINT rs_id_fk 
		FOREIGN KEY(rs_id) REFERENCES ROUTE_STATIONS(rs_id),

	CONSTRAINT rs_ds_fk 
		FOREIGN KEY(depart_station) REFERENCES STATION(station_id),

	CONSTRAINT trip_sched_fk 
		FOREIGN KEY(sched_id) REFERENCES SCHEDULE(sched_id)
		DEFERRABLE INITIALLY DEFERRED

);
DROP TABLE IF EXISTS BOOKING CASCADE;

CREATE TABLE BOOKING (
	agent			VARCHAR(40),
    passenger       INT,
    trip            INT,
    num_tickets     INT,

    CONSTRAINT agent_FK
    	FOREIGN KEY(agent) REFERENCES AGENT(username),

    CONSTRAINT pass_book_FK
        FOREIGN KEY(passenger) REFERENCES PASSENGER(customer_id),
    
    CONSTRAINT sched_book_FK
        FOREIGN KEY(trip) REFERENCES TRIP(trip_id)
);
DROP FUNCTION IF EXISTS create_trips() CASCADE;

CREATE FUNCTION create_trips()
RETURNS TRIGGER
AS $$
DECLARE
	train_rec RECORD;
	rs_cursor REFCURSOR;
	next_rs RECORD;
	conn_rec RECORD;
	rail_rec RECORD;
	t_cost NUMERIC(6, 2);
	temp_time NUMERIC(6, 2);
	hours INT;
	minutes INT;
	t_time INTERVAL;
	arr_time TIME;
	depart_station INT;
BEGIN
	SELECT * 
		FROM TRAIN as t 
		WHERE t.train_id = NEW.train_id 
		into train_rec;

	arr_time = NEW.sched_time;

	IF NEW.is_forward IS TRUE
	THEN
		open rs_cursor FOR
		SELECT rs_id, conn_id, ordinal, station_id
		FROM ROUTE_STATIONS AS rs 
		WHERE rs.route_id = NEW.t_route
		ORDER BY ordinal ASC;
	ELSE
		open rs_cursor FOR
		SELECT rs_id, conn_id, ordinal, station_id
		FROM ROUTE_STATIONS AS rs 
		WHERE rs.route_id = NEW.t_route
		ORDER BY ordinal DESC;
	END IF;


	LOOP
		FETCH rs_cursor INTO next_rs;

		IF NOT FOUND THEN
			EXIT;
		END IF;

		IF next_rs.conn_id IS NOT NULL
		THEN
			SELECT * FROM CONNECTION AS c WHERE next_rs.conn_id = c.conn_id INTO conn_rec;
			SELECT * FROM RAIL_LINE AS rl WHERE rl.rail_id = conn_rec.rail INTO rail_rec;
			t_cost = (train_rec.ppm * conn_rec.distance);

			temp_time = conn_rec.distance / LEAST(train_rec.top_speed, rail_rec.speed_limit);
			hours = floor(temp_time);
			temp_time = temp_time - floor(temp_time);
			minutes = floor(temp_time * 60);

			t_time = make_interval(hours := hours, mins := minutes);
			arr_time = arr_time + t_time;

			IF next_rs.station_id = conn_rec.station_1
			THEN
				depart_station = conn_rec.station_2;
			ELSE
				depart_station = conn_rec.station_1;
			END IF;

			INSERT INTO TRIP (sched_id, seats_left, rs_id, trip_distance,
				trip_cost, trip_time, arrival_time, depart_station)
			VALUES(NEW.sched_id, train_rec.seats, next_rs.rs_id,
				conn_rec.distance, t_cost, t_time, arr_time, depart_station);
		END IF;
	END LOOP;

	close rs_cursor;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sched_needs_trips
BEFORE INSERT ON SCHEDULE
FOR EACH ROW
EXECUTE PROCEDURE create_trips();


DROP FUNCTION IF EXISTS update_seats_left() CASCADE;

-- updates TRIP seating totals when bookings are made
CREATE FUNCTION update_seats_left() 
RETURNS TRIGGER
AS $$
DECLARE
	trip_rec RECORD;
BEGIN
	SELECT * FROM TRIP as t WHERE t.trip_id = NEW.trip INTO trip_rec;

	IF NEW.num_tickets > trip_rec.seats_left
	THEN
		RETURN NULL;
	ELSE
		UPDATE TRIP
		SET seats_left = seats_left - NEW.num_tickets
		WHERE trip_rec.trip_id = TRIP.trip_id;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_sell_tickets
BEFORE INSERT ON BOOKING
FOR EACH ROW
EXECUTE PROCEDURE update_seats_left();
