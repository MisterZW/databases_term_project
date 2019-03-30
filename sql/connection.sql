DROP TABLE IF EXISTS CONNECTION CASCADE;

CREATE TABLE CONNECTION (
    
    station_1       INT,
    station_2       INT,
    rail            INT,
    distance        NUMERIC(6, 2) NOT NULL,
    conn_ID         SERIAL,

    CONSTRAINT S1_FK
        FOREIGN KEY(station_1) REFERENCES STATION(station_id),

    CONSTRAINT S2_FK
        FOREIGN KEY(station_2) REFERENCES STATION(station_id),

    CONSTRAINT rail_FK
        FOREIGN KEY(rail) REFERENCES RAIL_LINE(rail_id),

    CONSTRAINT connection_PK PRIMARY KEY(conn_id),

    CONSTRAINT valid_distance CHECK (distance > 0)
);
