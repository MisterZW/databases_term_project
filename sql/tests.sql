--TESTS FOR THE dml commands on the mock_data.sql dataset
--Some tests may not test behavior correctly on another dataset

\i schema.sql
\i mock_data.sql
\i dml.sql

\echo 'TEST CASE: trains_which_dont_go_here(1)'
\echo 'EXPECTED BEHAVIOR: RESULT DOES NOT CONTAIN 1'
SELECT * FROM trains_which_dont_go_here(1) WHERE train_id < 10;


\echo 'TEST CASE: stations_all_trains_pass_through()'
\echo 'EXPECTED BEHAVIOR: NO RESULTING ROWS'
SELECT * FROM stations_all_trains_pass_through();


\echo 'TEST CASE: greater_than_percent_stops(75)'
\echo 'EXPECTED BEHAVIOR: A SUBSET OF ROUTES IN SYSTEM'
SELECT * FROM greater_than_percent_stops(75);


\echo 'TEST CASE: single_trip_route_search [day 1, stations 1-10 both directions]'
\echo 'EXPECTED BEHAVIOR: ONE OF THESE RETURNS DATA FOR ROUTE 1 SCHED 1'
\echo 'THE OTHER WILL RETURN EMPTY (EXACT RESULT DEPENDS ON DIRECTION OF SCHEDULE)'
SELECT * FROM single_trip_route_search(1, 10, 1);
SELECT * FROM single_trip_route_search(10, 1, 1);


\echo 'TEST CASE: trains_through_this_station(stations 1 and 10)'
\echo 'EXPECTED BEHAVIOR: AT LEAST ONE OF THESE QUERIES SHOULD FIND TRAIN 1'
\echo 'WILL LIKELY RETURN OTHER RESULTS (maybe 11, 20, etc)'
SELECT * FROM trains_through_this_station('08:00:00', 1, 1);
SELECT * FROM trains_through_this_station('09:00:00', 1, 1);
SELECT * FROM trains_through_this_station('10:00:00', 1, 1);
SELECT * FROM trains_through_this_station('08:00:00', 1, 10);
SELECT * FROM trains_through_this_station('09:00:00', 1, 10);
SELECT * FROM trains_through_this_station('10:00:00', 1, 10);


\echo 'TEST CASE: more_than_one_rail()'
\echo 'EXPECTED BEHAVIOR: NO RESULTING ROWS'
SELECT * FROM more_than_one_rail();


\echo 'TEST CASE: same_stations_diff_stops()'
\echo 'EXPECTED BEHAVIOR: NO RESULTING ROWS'
SELECT * FROM same_stations_diff_stops();


\echo 'ADDING A SIMILAR ROUTE TO FIND!'
START TRANSACTION;
INSERT INTO ROUTE_STATIONS VALUES(1, false, 1, 50, null);
INSERT INTO ROUTE_STATIONS VALUES(2, true, 2, 50, 1);
INSERT INTO ROUTE_STATIONS VALUES(3, true, 3, 50, 2);
INSERT INTO ROUTE_STATIONS VALUES(4, true, 4, 50, 3);
INSERT INTO ROUTE_STATIONS VALUES(5, true, 5, 50, 4);
INSERT INTO ROUTE_STATIONS VALUES(6, true, 6, 50, 5);
INSERT INTO ROUTE_STATIONS VALUES(7, true, 7, 50, 6);
INSERT INTO ROUTE_STATIONS VALUES(8, true, 8, 50, 7);
INSERT INTO ROUTE_STATIONS VALUES(9, true, 9, 50, 8);
INSERT INTO ROUTE_STATIONS VALUES(10, false, 10, 50, 9);
COMMIT;
\echo '\n'


\echo 'TEST CASE 2: same_stations_diff_stops()'
\echo 'EXPECTED BEHAVIOR: 1 RESULTING ROW with the new route'
SELECT * FROM same_stations_diff_stops();


\echo 'TEST CASE: get_route_schedule(1)'
\echo 'EXPECTED BEHAVIOR: shows schedule for route 1'
SELECT * FROM get_route_schedule(1);


\echo 'TEST CASE: find_route_availability(route 1, day 1, time 8 9 or 10)'
\echo 'EXPECTED BEHAVIOR: shows availibility for route 1 in one of the 3 queries (other 2 blank)'
SELECT * FROM find_route_availability(1, 1, '08:00:00');
SELECT * FROM find_route_availability(1, 1, '09:00:00');
SELECT * FROM find_route_availability(1, 1, '10:00:00');


\echo 'TEST CASE: make_reservation(5 tickets on schedule id #1)'
\echo 'EXPECTED BEHAVIOR: no errors for make_reservation itself (returns nothing)'
\echo 'Second set of calls to find_route_availability() should show number of seats'
\echo 'is lower by 5 for EACH LEG of the scheduled route'
SELECT make_reservation('agent3', 4, 1, 5, 1, 10);
SELECT * FROM find_route_availability(1, 1, '08:00:00');
SELECT * FROM find_route_availability(1, 1, '09:00:00');
SELECT * FROM find_route_availability(1, 1, '10:00:00');


\echo 'TEST CASE: create_customer_account() AND view_customer_account()'
\echo 'EXPECTED BEHAVIOR: QUERY RETURNS CUSTOMER DATA WITH INTEGER customer_ID > 300 and first_name "first"'
SELECT * FROM view_customer_account(
	create_customer_account('first', 'last', 'email','1234567890', 'address', 'city', '12345')
	);


\echo 'TEST CASE: attempt INSERTing schedule on a rail already in use at that day/time'
\echo 'EXPECTED BEHAVIOR: raises exception stating the rail is already in use (either once or twice here)'
INSERT INTO SCHEDULE VALUES(1, '08:00:00', 14, 200, true);
INSERT INTO SCHEDULE VALUES(1, '09:00:00', 14, 201, true);
\echo '\n'

\echo 'TEST CASE: attempt INSERTing schedule for a route where destination station(s) will close before route completion'
\echo 'EXPECTED BEHAVIOR: raises exception stating the rail is already in use (either once or twice here)'
INSERT INTO SCHEDULE VALUES(1, '22:00:00', 15, 200, true);
\echo '\n'

\echo 'TEST CASE: attempt INSERTing a booking for a trip which will overbook the train'
\echo 'EXPECTED BEHAVIOR: raises exception stating there are not enough seats to accomodate the reservation'
INSERT INTO BOOKING VALUES('agent1', 1, 1, 1000);
\echo '\n'

\echo 'TEST CASE: attempt INSERTing two schedules for invalid days (0 and 8)'
\echo 'EXPECTED BEHAVIOR: triggers a check constraint which prevents both inserts'
INSERT INTO SCHEDULE VALUES(0, '08:00:00', 12, 150, true);
INSERT INTO SCHEDULE VALUES(8, '08:00:00', 13, 151, true);
\echo '\n'

\echo 'TEST CASE: attempt INSERTing two bookings for zero and for a negative number of tickets'
\echo 'EXPECTED BEHAVIOR: triggers a check constraint which prevents both inserts'
INSERT INTO BOOKING VALUES('agent1', 1, 1, 0);
INSERT INTO BOOKING VALUES('agent1', 1, 1, -2);
\echo '\n'

\echo 'TEST CASE: attempt INSERTing two connections with zero and negative distances'
\echo 'EXPECTED BEHAVIOR: triggers a check constraint which prevents both inserts'
INSERT INTO CONNECTION VALUES(1, 2, 31, 0);
INSERT INTO CONNECTION VALUES(1, 2, 31, -2.5);
\echo '\n'

\echo 'TEST CASE: attempt INSERTing two rail lines with zero and negative speed limits'
\echo 'EXPECTED BEHAVIOR: triggers a check constraint which prevents both inserts'
INSERT INTO RAIL_LINE VALUES(0);
INSERT INTO RAIL_LINE VALUES(-2);
\echo '\n'

\echo 'TEST CASE: attempt INSERTing two trains with zero and negative parameters'
\echo 'EXPECTED BEHAVIOR: triggers 3 different check constraint (twice each) which prevents all inserts'
INSERT INTO TRAIN (top_speed, seats, ppm) VALUES(50, 100, 0);
INSERT INTO TRAIN (top_speed, seats, ppm) VALUES(50, 100, -2.5);
INSERT INTO TRAIN (top_speed, seats, ppm) VALUES(0, 100, 1.5);
INSERT INTO TRAIN (top_speed, seats, ppm) VALUES(-2, 100, 1.5);
INSERT INTO TRAIN (top_speed, seats, ppm) VALUES(50, 0, 1.5);
INSERT INTO TRAIN (top_speed, seats, ppm) VALUES(50, -1, 1.5);
\echo '\n'

\echo 'TEST SUITE: verify sorting of single_trip_route_search works for all parameters'
\echo '----SETTING UP NEEDED DATA TO PERFORM THE TESTS----'
-- create new data for this to make the test more dynamic/less brittle --
-- new route will be created to mirror the direction of schedule 1
INSERT INTO RAIL_LINE (speed_limit) 
	VALUES(100);
INSERT INTO CONNECTION (station_1, station_2, rail, distance)
	VALUES(1, 10, (SELECT MAX(rail_id) FROM RAIL_LINE), 10.0);
INSERT INTO TRAIN (top_speed, seats, ppm)
	VALUES(120, 200, 1);
INSERT INTO TRAIN_ROUTE (description) 
	VALUES('test route from station 1 to station 10');
INSERT INTO ROUTE_STATIONS (ordinal, stops_here, station_id, route_id, conn_id)
	VALUES(1, true, 1, (SELECT MAX(route_id) FROM TRAIN_ROUTE), null),
	(2, true, 10, (SELECT MAX(route_id) FROM TRAIN_ROUTE), (SELECT MAX(conn_id) FROM CONNECTION));
INSERT INTO SCHEDULE (sched_day, sched_time, t_route, train_id, is_forward)
	VALUES(1, '10:00:00', (SELECT MAX(route_id) FROM TRAIN_ROUTE), (SELECT MAX(train_id) FROM TRAIN),
	(SELECT is_forward FROM SCHEDULE as s WHERE s.sched_id = 1));

\echo '\n'


\echo 'TEST CASE: test single_trip_route_search sorting by number of stops ascending, then descending'
\echo 'EXPECTED BEHAVIOR: first result lists route with fewest stops (2) first, second lists it last'
\echo 'should have two queries with blank results also (only one direction should work here)'
-- sort_STRS(order_by_option INT, order_asc BOOLEAN, arr_st INT, dest_st INT, target_day INT)
/*
* order_by_option values:
* 1: stops
* 2: stations passed
* 3: total price
* 4: total time
* 5: total distance
* default: distance
*/
SELECT * FROM sort_STRS(1, true, 1, 10, 1);
SELECT * FROM sort_STRS(1, false, 1, 10, 1);

SELECT * FROM sort_STRS(1, true, 10, 1, 1);
SELECT * FROM sort_STRS(1, false, 10, 1, 1);
\echo '\n'



\echo 'TEST CASE: test single_trip_route_search sorting by number stations passed ascending, then descending'
\echo 'EXPECTED BEHAVIOR: first result lists route with smallest # of stations first, second lists it last'
\echo 'should have two queries with blank results also (only one direction should work here)'
-- sort_STRS(order_by_option INT, order_asc BOOLEAN, arr_st INT, dest_st INT, target_day INT)
/*
* order_by_option values:
* 1: stops
* 2: stations passed
* 3: total price
* 4: total time
* 5: total distance
* default: distance
*/
SELECT * FROM sort_STRS(2, true, 1, 10, 1);
SELECT * FROM sort_STRS(2, false, 1, 10, 1);

SELECT * FROM sort_STRS(2, true, 10, 1, 1);
SELECT * FROM sort_STRS(2, false, 10, 1, 1);
\echo '\n'



\echo 'TEST CASE: test single_trip_route_search sorting by total price ascending, then descending'
\echo 'EXPECTED BEHAVIOR: first result lists cheapest route first, second lists it last'
\echo 'should have two queries with blank results also (only one direction should work here)'
-- sort_STRS(order_by_option INT, order_asc BOOLEAN, arr_st INT, dest_st INT, target_day INT)
/*
* order_by_option values:
* 1: stops
* 2: stations passed
* 3: total price
* 4: total time
* 5: total distance
* default: distance
*/
SELECT * FROM sort_STRS(3, true, 1, 10, 1);
SELECT * FROM sort_STRS(3, false, 1, 10, 1);

SELECT * FROM sort_STRS(3, true, 10, 1, 1);
SELECT * FROM sort_STRS(3, false, 10, 1, 1);
\echo '\n'



\echo 'TEST CASE: test single_trip_route_search sorting by total time ascending, then descending'
\echo 'EXPECTED BEHAVIOR: first result lists fastest (least elapsed time) route first, second lists it last'
\echo 'should have two queries with blank results also (only one direction should work here)'
-- sort_STRS(order_by_option INT, order_asc BOOLEAN, arr_st INT, dest_st INT, target_day INT)
/*
* order_by_option values:
* 1: stops
* 2: stations passed
* 3: total price
* 4: total time
* 5: total distance
* default: distance
*/
SELECT * FROM sort_STRS(4, true, 1, 10, 1);
SELECT * FROM sort_STRS(4, false, 1, 10, 1);

SELECT * FROM sort_STRS(4, true, 10, 1, 1);
SELECT * FROM sort_STRS(4, false, 10, 1, 1);
\echo '\n'



\echo 'TEST CASE: test single_trip_route_search sorting by total distance ascending, then descending'
\echo 'EXPECTED BEHAVIOR: first result lists shortest (distance) route first, second lists it last'
\echo 'should have two queries with blank results also (only one direction should work here)'
-- sort_STRS(order_by_option INT, order_asc BOOLEAN, arr_st INT, dest_st INT, target_day INT)
/*
* order_by_option values:
* 1: stops
* 2: stations passed
* 3: total price
* 4: total time
* 5: total distance
* default: distance
*/
SELECT * FROM sort_STRS(5, true, 1, 10, 1);
SELECT * FROM sort_STRS(5, false, 1, 10, 1);

SELECT * FROM sort_STRS(5, true, 10, 1, 1);
SELECT * FROM sort_STRS(5, false, 10, 1, 1);
\echo '\n'



\echo 'TEST CASE: test that single_trip_route_search excludes full trips from its results'
\echo 'EXPECTED BEHAVIOR: after booking test route to full, searches only find route 1'
\echo 'should have one query with a blank result also (only one direction should work here)'
INSERT INTO BOOKING VALUES('agent5', 50, (SELECT MAX(trip_id) FROM TRIP), 200);
SELECT * FROM sort_STRS(1, true, 1, 10, 1);
SELECT * FROM sort_STRS(1, true, 10, 1, 1);
\echo '\n'
