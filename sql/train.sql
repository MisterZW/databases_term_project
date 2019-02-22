CREATE TABLE TRAIN (
	train_ID		INTEGER,
	top_speed		SMALLINT,
	seats 			INTEGER,
	ppm				NUMERIC(4, 2),

	CONSTRAINT Train_PK
		PRIMARY KEY(train_ID)
);
