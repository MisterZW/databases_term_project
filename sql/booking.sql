DROP TABLE IF EXISTS BOOKING CASCADE;

CREATE TABLE BOOKING (
	agent			VARCHAR(40),
    passenger       INT,
    trip            INT,
    num_tickets     INT,

    CONSTRAINT agent_FK
    	FOREIGN KEY(agent) REFERENCES AGENT(username),

    CONSTRAINT pass_book_FK
        FOREIGN KEY(passenger) REFERENCES PASSENGER(customer_id),
    
    CONSTRAINT sched_book_FK
        FOREIGN KEY(trip) REFERENCES TRIP(trip_id),

    CONSTRAINT valid_num_tickets CHECK (num_tickets > 0)
);
