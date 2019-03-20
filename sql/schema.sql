DROP TABLE IF EXISTS AGENT CASCADE;

CREATE TABLE AGENT (
	username		VARCHAR(40),
	password		VARCHAR(40),

	CONSTRAINT AGENT_PK PRIMARY KEY(username)
);
DROP TABLE IF EXISTS RAIL_LINE CASCADE;

CREATE TABLE RAIL_LINE (
    rail_ID         INT,
    speed_limit     SMALLINT,

    CONSTRAINT Rail_PK PRIMARY KEY(rail_ID)
);
DROP TABLE IF EXISTS TRAIN CASCADE;

CREATE TABLE TRAIN (
    train_ID        INT,
    top_speed       SMALLINT,
    seats           INT,
    ppm             NUMERIC(4, 2),

    CONSTRAINT Train_PK PRIMARY KEY(train_ID)
);
DROP TABLE IF EXISTS STATION CASCADE;

CREATE TABLE STATION (
    station_ID      INT,
    street_address  VARCHAR(50),
    city            VARCHAR(25),
    zip             CHAR(5),
    open_time       TIME,
    close_time      TIME,

    CONSTRAINT Station_PK PRIMARY KEY(station_ID)
);
DROP TABLE IF EXISTS TRAIN_ROUTE CASCADE;

CREATE TABLE TRAIN_ROUTE (
    route_ID        INT,
    description		VARCHAR(200),
    
    CONSTRAINT r_PK PRIMARY KEY(route_ID)
);
DROP TABLE IF EXISTS CONNECTION CASCADE;

CREATE TABLE CONNECTION (
    conn_ID         INT,
    station_1       INT,
    station_2       INT,
    rail            INT,
    distance        DECIMAL(6, 2),

    CONSTRAINT S1_FK
        FOREIGN KEY(station_1) REFERENCES STATION(station_ID),

    CONSTRAINT S2_FK
        FOREIGN KEY(station_2) REFERENCES STATION(station_ID),

    CONSTRAINT rail_FK
        FOREIGN KEY(rail) REFERENCES RAIL_LINE(rail_ID),

    CONSTRAINT connection_PK PRIMARY KEY(conn_ID)
);
DROP TABLE IF EXISTS PASSENGER CASCADE;

CREATE TABLE PASSENGER (
    customer_ID     INT,
    first_name      VARCHAR(20),
    last_name       VARCHAR(20),
    email           VARCHAR(35),
    phone           CHAR(10),
    street_address  VARCHAR(50),
    city            VARCHAR(25),
    zip             CHAR(5),

    CONSTRAINT Passenger_PK PRIMARY KEY(customer_ID)
);
DROP TABLE IF EXISTS ROUTE_STATIONS CASCADE;

CREATE TABLE ROUTE_STATIONS (
    ordinal         SMALLINT,
    stops_here      BOOLEAN NOT NULL,
    station_id		INT,
    route_ID		INT,

    CONSTRAINT sid_FK
         FOREIGN KEY(station_id) REFERENCES STATION(station_id),
    
    CONSTRAINT rid_FK
         FOREIGN KEY(route_ID) REFERENCES TRAIN_ROUTE(route_ID)
);
DROP TABLE IF EXISTS SCHEDULE CASCADE;

CREATE TABLE SCHEDULE (
    sched_ID        INT,
    sched_date      DATE,
    sched_time      TIME,
    train           INT,
    tickets_sold    INT,
    t_route         INT,

    CONSTRAINT sched_train_FK
        FOREIGN KEY(train) REFERENCES TRAIN(train_ID),

    CONSTRAINT sched_route_FK
        FOREIGN KEY(t_route) REFERENCES TRAIN_ROUTE(route_ID),

    CONSTRAINT sched_PK PRIMARY KEY(sched_ID)
);
DROP TABLE IF EXISTS BOOKING CASCADE;

CREATE TABLE BOOKING (
	agent			VARCHAR(40),
    passenger       INT,
    schedule        INT,
    num_tickets     SMALLINT,

    CONSTRAINT agent_FK
    	FOREIGN KEY(agent) REFERENCES AGENT(username),

    CONSTRAINT pass_book_FK
        FOREIGN KEY(passenger) REFERENCES PASSENGER(customer_ID),
    
    CONSTRAINT sched_book_FK
        FOREIGN KEY(schedule) REFERENCES SCHEDULE(sched_ID)
);
