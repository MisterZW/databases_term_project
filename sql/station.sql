CREATE TABLE STATION (
	station_ID		INTEGER,
	street_address	VARCHAR(50),
	city			VARCHAR(25),
	zip				CHAR(5),
	open_time		TIME,
	close_time		TIME,

	CONSTRAINT Station_PK
		PRIMARY KEY(station_ID)
);
