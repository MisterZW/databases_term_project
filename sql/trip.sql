DROP TABLE IF EXISTS TRIP CASCADE;

CREATE TABLE TRIP (
	
	sched_id		INT,
	seats_left		INT NOT NULL,
	rs_id			INT,
	trip_distance 	NUMERIC(6, 2) NOT NULL,
	trip_cost		NUMERIC(6, 2) NOT NULL,
	trip_time		INTERVAL NOT NULL,
	arrival_time	TIME NOT NULL,
	depart_station	INT NOT NULL,
	rail_id			INT,
	trip_id			SERIAL,	

	CONSTRAINT trip_pk PRIMARY KEY (trip_id),

	CONSTRAINT rs_id_fk 
		FOREIGN KEY(rs_id) REFERENCES ROUTE_STATIONS(rs_id),

	CONSTRAINT rs_ds_fk 
		FOREIGN KEY(depart_station) REFERENCES STATION(station_id),

	CONSTRAINT rid_FK
		FOREIGN KEY(rail_id) REFERENCES RAIL_LINE(rail_id),

	CONSTRAINT trip_sched_fk 
		FOREIGN KEY(sched_id) REFERENCES SCHEDULE(sched_id)
		DEFERRABLE INITIALLY DEFERRED

);
