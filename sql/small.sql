--START TRANSACTION; SET CONSTRAINTS ALL DEFERRED;

INSERT INTO TRAIN VALUES(50, 100, 0.1);
INSERT INTO TRAIN VALUES(60, 100, 0.2);
INSERT INTO TRAIN VALUES(70, 100, 0.3);
INSERT INTO TRAIN VALUES(80, 100, 0.4);
INSERT INTO TRAIN VALUES(90, 100, 0.5);

INSERT INTO STATION VALUES('A Fake Street', 'A', '15217', '07:00:00', '21:00:00');
INSERT INTO STATION VALUES('B Fake Street', 'B', '15218', '07:15:00', '21:30:00');
INSERT INTO STATION VALUES('C Fake Street', 'C', '15219', '07:30:00', '22:00:00');
INSERT INTO STATION VALUES('D Fake Street', 'D', '15220', '07:45:00', '22:30:00');

INSERT INTO AGENT VALUES('agent0', '0');
INSERT INTO AGENT VALUES('agent1', '1');

INSERT INTO PASSENGER VALUES('pass_fname0', 'pass_lname0', 'passenger0@gmail.com', '0734446230', '123 Fake Street', 'Faketown', '15217');
INSERT INTO PASSENGER VALUES('pass_fname1', 'pass_lname1', 'passenger1@gmail.com', '3341477783', '123 Fake Street', 'Faketown', '15217');
INSERT INTO PASSENGER VALUES('pass_fname2', 'pass_lname2', 'passenger2@gmail.com', '4211275601', '123 Fake Street', 'Faketown', '15217');
INSERT INTO PASSENGER VALUES('pass_fname3', 'pass_lname3', 'passenger3@gmail.com', '6296023299', '123 Fake Street', 'Faketown', '15217');
INSERT INTO PASSENGER VALUES('pass_fname4', 'pass_lname4', 'passenger4@gmail.com', '5552298987', '123 Fake Street', 'Faketown', '15217');
INSERT INTO PASSENGER VALUES('pass_fname5', 'pass_lname5', 'passenger5@gmail.com', '5632167823', '123 Fake Street', 'Faketown', '15217');
INSERT INTO PASSENGER VALUES('pass_fname6', 'pass_lname6', 'passenger6@gmail.com', '9128910474', '123 Fake Street', 'Faketown', '15217');
INSERT INTO PASSENGER VALUES('pass_fname7', 'pass_lname7', 'passenger7@gmail.com', '8449786588', '123 Fake Street', 'Faketown', '15217');
INSERT INTO PASSENGER VALUES('pass_fname8', 'pass_lname8', 'passenger8@gmail.com', '8460802790', '123 Fake Street', 'Faketown', '15217');
INSERT INTO PASSENGER VALUES('pass_fname9', 'pass_lname9', 'passenger9@gmail.com', '7008710085', '123 Fake Street', 'Faketown', '15217');

INSERT INTO RAIL_LINE (speed_limit) VALUES(55);
INSERT INTO RAIL_LINE (speed_limit) VALUES(60);
INSERT INTO RAIL_LINE (speed_limit) VALUES(65);

INSERT INTO TRAIN_ROUTE VALUES('A --> B --> D (all stops)');
INSERT INTO TRAIN_ROUTE VALUES('A --> C --> D (all stops)');
INSERT INTO TRAIN_ROUTE VALUES('A --> D');
INSERT INTO TRAIN_ROUTE VALUES('C --> B');
INSERT INTO TRAIN_ROUTE VALUES('A --> B --> D (no stop at B)');
INSERT INTO TRAIN_ROUTE VALUES('B --> D --> A (no stop at D)');

-- RAIL 1
-- A to B -- conn_id1
INSERT INTO CONNECTION (station_1, station_2, rail, distance) VALUES(1, 2, 1, 5.0);

-- A to C -- conn_id2
INSERT INTO CONNECTION (station_1, station_2, rail, distance) VALUES(1, 3, 1, 6.0);

-- B to D -- conn_id3
INSERT INTO CONNECTION (station_1, station_2, rail, distance) VALUES(2, 4, 1, 7.0);

-- C to D -- conn_id4
INSERT INTO CONNECTION (station_1, station_2, rail, distance) VALUES(3, 4, 1, 8.0);

-- RAIL 2
-- B to C -- conn_id5
INSERT INTO CONNECTION (station_1, station_2, rail, distance) VALUES(2, 3, 2, 12.5);

-- RAIL 3
-- A to D -- conn_id6
INSERT INTO CONNECTION (station_1, station_2, rail, distance) VALUES(1, 4, 3, 7.5);


-- ROUTE 1 A --> B --> D (all stops)
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(1, True, 1, 1, null);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(2, True, 2, 1, 1);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(3, True, 4, 1, 3);

-- ROUTE 2 A --> C --> D (all stops)
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(1, True, 1, 2, null);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(2, True, 3, 2, 2);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(3, True, 4, 2, 4);

-- ROUTE 3 A --> D
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(1, True, 1, 3, null);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(2, True, 4, 3, 6);

-- ROUTE 4 C --> B
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(1, True, 3, 4, null);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(2, True, 2, 4, 5);

-- ROUTE 5 A --> B --> D (all stops)
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(1, True, 1, 5, null);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(2, False, 2, 5, 1);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(3, True, 4, 5, 3);

-- ROUTE 6 B --> D --> A (all stops)
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(1, True, 2, 6, null);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(2, False, 4, 6, 3);
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id) 
	VALUES(3, True, 1, 6, 6);


-- DAY 1
INSERT INTO SCHEDULE (sched_day, sched_time, t_route, train_id, is_forward)
	VALUES(1, '09:00:00', 1, 1, True);

INSERT INTO SCHEDULE (sched_day, sched_time, t_route, train_id, is_forward)
	VALUES(1, '09:00:00', 3, 2, True);

INSERT INTO SCHEDULE (sched_day, sched_time, t_route, train_id, is_forward)
	VALUES(1, '09:00:00', 4, 3, False);

INSERT INTO SCHEDULE (sched_day, sched_time, t_route, train_id, is_forward)
	VALUES(1, '13:00:00', 5, 4, True);

INSERT INTO SCHEDULE (sched_day, sched_time, t_route, train_id, is_forward)
	VALUES(1, '17:00:00', 2, 4, False);

-- DAY 2
INSERT INTO SCHEDULE (sched_day, sched_time, t_route, train_id, is_forward)
	VALUES(2, '9:00:00', 6, 1, True);

-- DAY 3
INSERT INTO SCHEDULE (sched_day, sched_time, t_route, train_id, is_forward)
	VALUES(3, '12:00:00', 3, 5, False);

INSERT INTO SCHEDULE (sched_day, sched_time, t_route, train_id, is_forward)
	VALUES(3, '12:00:00', 1, 3, False);

--COMMIT;
