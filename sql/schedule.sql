DROP TABLE IF EXISTS SCHEDULE CASCADE;

CREATE TABLE SCHEDULE (
    sched_day       INT, -- enum value 1 (MONDAY) through 7 (SUNDAY)
    sched_time      TIME,
    t_route         INT,
    train_id		INT,
    is_forward      BOOLEAN,
    sched_id        SERIAL,

    CONSTRAINT sched_route_FK
        FOREIGN KEY(t_route) REFERENCES TRAIN_ROUTE(route_id),

    CONSTRAINT trip_train_fk 
		FOREIGN KEY(train_id) REFERENCES TRAIN(train_id),

    CONSTRAINT sched_PK PRIMARY KEY(sched_id),

    CONSTRAINT valid_day CHECK (sched_day between 1 and 7)
);
