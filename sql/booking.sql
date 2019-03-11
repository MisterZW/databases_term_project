DROP TABLE IF EXISTS BOOKINGS CASCADE;

CREATE TABLE BOOKINGS (
    passenger       INT,
    schedule        INT,
    num_tickets     SMALLINT,

    CONSTRAINT pass_book_FK
        FOREIGN KEY(passenger) REFERENCES PASSENGER(customer_ID),
    
    CONSTRAINT sched_book_FK
        FOREIGN KEY(schedule) REFERENCES SCHEDULE(sched_ID)
);
