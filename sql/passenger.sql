CREATE TABLE PASSENGER (
    customer_ID     INT,
    first_name      VARCHAR(20),
    last_name       VARCHAR(20),
    email           VARCHAR(35),
    phone           CHAR(10),
    street_address  VARCHAR(50),
    city            VARCHAR(25),
    zip             CHAR(5),

    CONSTRAINT Passenger_PK PRIMARY KEY(customer_ID)
);
