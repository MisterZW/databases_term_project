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
DROP TABLE IF EXISTS ROUTE_PATHS CASCADE;

CREATE TABLE ROUTE_PATHS (
    ordinal         SMALLINT,
    direction       CHAR(1),
    stops_here      BOOLEAN NOT NULL,
    path_ID         INT,
    conn            INT,

    CONSTRAINT rp_FK
        FOREIGN KEY(path_ID) REFERENCES TRAIN_ROUTE(route_ID),
    
    CONSTRAINT cp_FK
        FOREIGN KEY(conn) REFERENCES CONNECTION(conn_ID)
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
DROP TABLE IF EXISTS BOOKINGS CASCADE;

CREATE TABLE BOOKINGS (
    passenger       INT,
    schedule        INT,
    num_tickets     SMALLINT,

    CONSTRAINT pass_book_FK
        FOREIGN KEY(passenger) REFERENCES PASSENGER(customer_ID),
    
    CONSTRAINT sched_book_FK
        FOREIGN KEY(schedule) REFERENCES SCHEDULE(sched_ID)
);
