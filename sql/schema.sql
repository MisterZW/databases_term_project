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