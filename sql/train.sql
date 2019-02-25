CREATE TABLE TRAIN (
    train_ID        INT,
    top_speed       SMALLINT,
    seats           INT,
    ppm             NUMERIC(4, 2),

    CONSTRAINT Train_PK PRIMARY KEY(train_ID)
);
