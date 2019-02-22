CREATE TABLE BOOKINGS (
	passenger		INTEGER,
	schedule		INTEGER,
	num_tickets		SMALLINT,

	CONSTRAINT pass_book_FK
		FOREIGN KEY(passenger) REFERENCES PASSENGER(customer_ID),
	
	CONSTRAINT sched_book_FK
		FOREIGN KEY(schedule) REFERENCES SCHEDULE(sched_ID)
);
