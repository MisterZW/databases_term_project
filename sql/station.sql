DROP TABLE IF EXISTS STATION CASCADE;

CREATE TABLE STATION (
    street_address  VARCHAR(50),
    city            VARCHAR(25),
    zip             CHAR(5),
    open_time       TIME NOT NULL,
    close_time      TIME NOT NULL,
    station_id      SERIAL,

    CONSTRAINT Station_PK PRIMARY KEY(station_id)
);
