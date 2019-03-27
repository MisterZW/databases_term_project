DROP TABLE IF EXISTS TRIP CASCADE;

CREATE TABLE TRIP (
	
	sched_id	SERIAL,
	trip_date	date,
	trip_id		SERIAL,

	CONSTRAINT trip_pk PRIMARY KEY (trip_id),

	CONSTRAINT trip_sched_fk 
		FOREIGN KEY(sched_id) REFERENCES SCHEDULE(sched_id)

);
