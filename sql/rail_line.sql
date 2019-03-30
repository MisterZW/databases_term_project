DROP TABLE IF EXISTS RAIL_LINE CASCADE;

CREATE TABLE RAIL_LINE (
    speed_limit     INT NOT NULL,
    rail_id         SERIAL,

    CONSTRAINT Rail_PK PRIMARY KEY(rail_id),

    CONSTRAINT valid_speed_limit CHECK (speed_limit > 0)
);
