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
