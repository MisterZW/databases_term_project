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
\echo 'EXPECTED BEHAVIOR: ONE OF THESE QUERIES SHOULD FIND TRAIN 1'
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
