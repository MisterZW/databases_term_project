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
