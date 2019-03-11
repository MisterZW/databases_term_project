DROP TABLE IF EXISTS SCHEDULE CASCADE;

CREATE TABLE SCHEDULE (
    sched_ID        INT,
    sched_date      DATE,
    sched_time      TIME,
    train           INT,
    tickets_sold    INT,
    t_route         INT,

    CONSTRAINT sched_train_FK
        FOREIGN KEY(train) REFERENCES TRAIN(train_ID),

    CONSTRAINT sched_route_FK
        FOREIGN KEY(t_route) REFERENCES TRAIN_ROUTE(route_ID),

    CONSTRAINT sched_PK PRIMARY KEY(sched_ID)
);
