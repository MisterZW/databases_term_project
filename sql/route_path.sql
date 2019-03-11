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
