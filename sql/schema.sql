CREATE TABLE RAIL_LINE (
	rail_ID			INTEGER,
	speed_limit		SMALLINT,

	CONSTRAINT	Rail_PK
		PRIMARY KEY(rail_ID)
);

CREATE TABLE PASSENGER (
	customer_ID		INTEGER,
	first_name		VARCHAR(20),
	last_name		VARCHAR(20),
	email			VARCHAR(35),
	phone			CHAR(10),
	street_address	VARCHAR(50),
	city			VARCHAR(25),
	zip				CHAR(5),

	CONSTRAINT Passenger_PK
		PRIMARY KEY(customer_ID)
);

CREATE TABLE STATION (
	station_ID		INTEGER,
	street_address	VARCHAR(50),
	city			VARCHAR(25),
	zip				CHAR(5),
	open_time		TIME,
	close_time		TIME,

	CONSTRAINT Station_PK
		PRIMARY KEY(station_ID)
);

CREATE TABLE TRAIN (
	train_ID		INTEGER,
	top_speed		SMALLINT,
	seats 			INTEGER,
	ppm				NUMERIC(4, 2),

	CONSTRAINT Train_PK
		PRIMARY KEY(train_ID)
);

CREATE TABLE ROUTE (
	route_ID		INTEGER PRIMARY KEY
);

CREATE TABLE CONNECTION (
	conn_ID			INTEGER,
	station_1		INTEGER,
	station_2		INTEGER,
	rail			INTEGER,
	distance		DECIMAL(6, 2),

	CONSTRAINT S1_FK
		FOREIGN KEY(station_1) REFERENCES STATION(station_ID),

	CONSTRAINT S2_FK
		FOREIGN KEY(station_2) REFERENCES STATION(station_ID),

	CONSTRAINT rail_FK
		FOREIGN KEY(rail) REFERENCES RAIL_LINE(rail_ID),

	CONSTRAINT connection_PK
		PRIMARY KEY(conn_ID)
);

CREATE TABLE SCHEDULE (
	sched_ID		INTEGER,
	date			DATE,
	time			TIME,
	train			INTEGER,
	tickets_sold	INTEGER,
	train_route		INTEGER,

	CONSTRAINT sched_train_FK
		FOREIGN	KEY(train) REFERENCES TRAIN(train_ID),

	CONSTRAINT sched_route_FK
		FOREIGN KEY(train_route) REFERENCES ROUTE(route_ID),

	CONSTRAINT sched_PK
		PRIMARY KEY(sched_ID)
);

CREATE TABLE BOOKINGS (
	passenger		INTEGER,
	schedule		INTEGER,
	num_tickets		SMALLINT,

	CONSTRAINT pass_book_FK
		FOREIGN KEY(passenger) REFERENCES PASSENGER(customer_ID),
	
	CONSTRAINT sched_book_FK
		FOREIGN KEY(schedule) REFERENCES SCHEDULE(sched_ID)
);

CREATE TABLE ROUTE_PATHS (
	ordinal			SMALLINT,
	direction		CHAR(1),
	stops_here		BOOLEAN NOT NULL,
	path_ID			INTEGER,
	conn			INTEGER,

	CONSTRAINT rp_FK
		FOREIGN KEY(path_ID) REFERENCES ROUTE(route_ID),
	
	CONSTRAINT cp_FK
		FOREIGN KEY(conn) REFERENCES CONNECTION(conn_ID)
);