DROP TABLE IF EXISTS BOOKING CASCADE;

CREATE TABLE BOOKING (
	agent			VARCHAR(40),
    passenger       INT,
    schedule        INT,
    num_tickets     SMALLINT,

    CONSTRAINT agent_FK
    	FOREIGN KEY(agent) REFERENCES AGENT(username),

    CONSTRAINT pass_book_FK
        FOREIGN KEY(passenger) REFERENCES PASSENGER(customer_ID),
    
    CONSTRAINT sched_book_FK
        FOREIGN KEY(schedule) REFERENCES SCHEDULE(sched_ID)
);
