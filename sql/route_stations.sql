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
