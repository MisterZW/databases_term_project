DROP TABLE IF EXISTS RAIL_LINE CASCADE;

CREATE TABLE RAIL_LINE (
    speed_limit     INT,
    rail_id         SERIAL,

    CONSTRAINT Rail_PK PRIMARY KEY(rail_id)
);
