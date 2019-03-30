DROP TABLE IF EXISTS TRIP CASCADE;

CREATE TABLE TRIP (
	
	sched_id		INT,
	seats_left		INT,
	rs_id			INT,
	trip_distance 	NUMERIC(6, 2),
	trip_cost		NUMERIC(6, 2),
	trip_time		INTERVAL,
	arrival_time	TIME,
	depart_station	INT,
	trip_id			SERIAL,	

	CONSTRAINT trip_pk PRIMARY KEY (trip_id),

	CONSTRAINT rs_id_fk 
		FOREIGN KEY(rs_id) REFERENCES ROUTE_STATIONS(rs_id),

	CONSTRAINT rs_ds_fk 
		FOREIGN KEY(depart_station) REFERENCES STATION(station_id),

	CONSTRAINT trip_sched_fk 
		FOREIGN KEY(sched_id) REFERENCES SCHEDULE(sched_id)
		DEFERRABLE INITIALLY DEFERRED

);
