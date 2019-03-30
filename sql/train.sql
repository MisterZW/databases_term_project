DROP TABLE IF EXISTS TRAIN CASCADE;

CREATE TABLE TRAIN (
    top_speed       INT,
    seats           INT,
    ppm             NUMERIC(6, 2),
    train_id        SERIAL,

    CONSTRAINT Train_PK PRIMARY KEY(train_id)
);
