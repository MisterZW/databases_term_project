DROP TABLE IF EXISTS TRIP CASCADE;

CREATE TABLE TRIP (
	
	sched_id		SERIAL,
	trip_date		date,
	trip_id			SERIAL,
	tickets_sold	INT DEFAULT 0,

	CONSTRAINT trip_pk PRIMARY KEY (trip_id),

	CONSTRAINT trip_sched_fk 
		FOREIGN KEY(sched_id) REFERENCES SCHEDULE(sched_id)

);
