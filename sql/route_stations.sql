DROP TABLE IF EXISTS ROUTE_STATIONS CASCADE;

CREATE TABLE ROUTE_STATIONS (
    ordinal         SMALLINT,
    stops_here      BOOLEAN NOT NULL,
    station_id		SERIAL,
    route_id		SERIAL,

    CONSTRAINT sid_FK
         FOREIGN KEY(station_id) REFERENCES STATION(station_id),
    
    CONSTRAINT rid_FK
         FOREIGN KEY(route_id) REFERENCES TRAIN_ROUTE(route_id)
);
