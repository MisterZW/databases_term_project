DROP TABLE IF EXISTS TRAIN CASCADE;

CREATE TABLE TRAIN (
    top_speed       INT NOT NULL,
    seats           INT NOT NULL,
    ppm             NUMERIC(6, 2) NOT NULL,
    train_id        SERIAL,

    CONSTRAINT Train_PK PRIMARY KEY(train_id),

    CONSTRAINT valid_top_speed CHECK (top_speed > 0),

    CONSTRAINT valid_ppm CHECK (ppm > 0),

    CONSTRAINT valid_seats CHECK (seats > 0)
);
