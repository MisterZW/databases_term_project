DROP TABLE IF EXISTS TRAIN CASCADE;

CREATE TABLE TRAIN (
    top_speed       SMALLINT,
    seats           INT,
    ppm             NUMERIC(4, 2),
    train_id        SERIAL,

    CONSTRAINT Train_PK PRIMARY KEY(train_id)
);
