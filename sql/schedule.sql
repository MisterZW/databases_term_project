CREATE TABLE SCHEDULE (
	sched_ID		INTEGER,
	sched_date		DATE,
	sched_time		TIME,
	train			INTEGER,
	tickets_sold	INTEGER,
	t_route			INTEGER,

	CONSTRAINT sched_train_FK
		FOREIGN	KEY(train) REFERENCES TRAIN(train_ID),

	CONSTRAINT sched_route_FK
		FOREIGN KEY(t_route) REFERENCES TRAIN_ROUTE(route_ID),

	CONSTRAINT sched_PK
		PRIMARY KEY(sched_ID)
);
