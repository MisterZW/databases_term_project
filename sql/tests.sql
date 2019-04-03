--TESTS FOR THE dml commands on the mock_data.sql dataset
--Some tests may not test behavior correctly on another dataset

\i schema.sql
\i mock_data.sql
\i dml.sql

\echo 'TEST CASE: trains_which_dont_go_here(station 1) between id# 320 and 330'
\echo 'EXPECTED BEHAVIOR: RESULT DOES NOT CONTAIN 321'
SELECT * FROM trains_which_dont_go_here(1) WHERE train_id > 320 AND train_id <330;


\echo 'TEST CASE: stations_all_trains_pass_through()'
\echo 'EXPECTED BEHAVIOR: NO ROWS RETURNED'
SELECT * FROM stations_all_trains_pass_through();


\echo 'TEST CASE: greater_than_percent_stops(90)'
\echo 'EXPECTED BEHAVIOR: A SUBSET OF ROUTES WHICH STOP AT ALL THEIR STATIONS'
SELECT * FROM greater_than_percent_stops(90) LIMIT 10;


\echo 'TEST CASE: single_trip_route_search [day 1, stations 1-20]'
\echo 'EXPECTED BEHAVIOR:RETURNS DATA FOR ROUTE 1 SCHED 1'
SELECT * FROM single_trip_route_search(1, 20, 3);


\echo 'TEST CASE: PARTIAL TRIP CHECK single_trip_route_search [day 1, stations 1-11]'
\echo 'EXPECTED BEHAVIOR:RETURNS DATA FOR ROUTE 1 SCHED 1 for partial trip'
\echo 'Data totals should all be smaller than the full route (price, distance, time, etc)'
SELECT * FROM single_trip_route_search(1, 11, 3);


\echo 'TEST CASE: combo_search'
\echo 'EXPECTED BEHAVIOR: sort by stops'
SELECT * FROM sort_CTRS(1, true, 237, 256, 4);
\echo '\n'

\echo 'TEST CASE: combo_search'
\echo 'EXPECTED BEHAVIOR: sort by stops (descending)'
SELECT * FROM sort_CTRS(1, false, 237, 256, 4);
\echo '\n'


\echo 'TEST CASE: combo_search '
\echo 'EXPECTED BEHAVIOR: sort by num stations passed'
SELECT * FROM sort_CTRS(2, true, 237, 256, 4);
\echo '\n'

\echo 'TEST CASE: combo_search'
\echo 'EXPECTED BEHAVIOR: sort by price'
SELECT * FROM sort_CTRS(3, true, 237, 256, 4);
\echo '\n'


\echo 'TEST CASE: combo_search'
\echo 'EXPECTED BEHAVIOR: sort by time'
SELECT * FROM sort_CTRS(4, true, 237, 256, 4);
\echo '\n'


\echo 'TEST CASE: combo_search'
\echo 'EXPECTED BEHAVIOR: sort by distance'
SELECT * FROM sort_CTRS(5, true, 237, 256, 4);
\echo '\n'



\echo 'TEST CASE: trains_through_this_station(station 1, day 3, 15:00:00) -- this is route 1'
\echo 'EXPECTED BEHAVIOR: AT LEAST ONE OF THESE QUERIES SHOULD FIND TRAIN 321'
SELECT * FROM trains_through_this_station('15:00:00', 3, 1);


\echo 'TEST CASE: more_than_one_rail()'
\echo 'EXPECTED BEHAVIOR: a lot of results, but limited by query detail here'
SELECT * FROM more_than_one_rail() LIMIT 10;


\echo 'TEST CASE: same_stations_diff_stops()'
\echo 'EXPECTED BEHAVIOR: A handful of results easy to verify w/ statements like:'
\echo 'select * from route_stations where route_id = first_result or route_id = second_result;'
SELECT * FROM same_stations_diff_stops();


\echo 'TEST CASE: get_route_schedule(1)'
\echo 'EXPECTED BEHAVIOR: shows schedule for route 1'
SELECT * FROM get_route_schedule(1);


\echo 'TEST CASE: find_route_availability(route 1, day 3, time 15:00:00)'
\echo 'EXPECTED BEHAVIOR: shows availibility for route 1, which has 20 trips from stations 1 to 20'
SELECT * FROM find_route_availability(1, 3, '15:00:00');


\echo 'TEST CASE: make_reservation(50 tickets on schedule id #487 -- same one displayed before)'
\echo 'EXPECTED BEHAVIOR: no errors for make_reservation itself (returns nothing)'
\echo 'Second set of calls to find_route_availability() should show number of seats'
\echo 'is lower by 50 for EACH LEG of the scheduled route'
SELECT make_reservation('agent3', 4, 487, 50, 1, 20);
SELECT * FROM find_route_availability(1, 3, '15:00:00');


\echo 'TEST CASE: create_customer_account() AND view_customer_account()'
\echo 'EXPECTED BEHAVIOR: QUERY RETURNS CUSTOMER DATA WITH INTEGER customer_ID > 300 and first_name "first"'
SELECT * FROM view_customer_account(
	create_customer_account('first', 'last', 'email','1234567890', 'address', 'city', '12345')
	);


\echo 'TEST CASE: update_customer_account()'
\echo 'EXPECTED BEHAVIOR: First query shows stock customer data, then update returns void'
\echo 'Second query shows updated customer information'

SELECT * FROM PASSENGER WHERE customer_ID = 1;
SELECT update_customer_account(1, 'zach', 'whit', 'zdw9@pitt.edu', '1212121212', 'Sennott', 'pgh', '54321');
SELECT * FROM PASSENGER WHERE customer_ID = 1;


\echo 'TEST CASE: attempt INSERTing schedule on a rail already in use at that day/time'
\echo 'EXPECTED BEHAVIOR: raises exception stating the rail is already in use (either once or twice here)'
INSERT INTO SCHEDULE VALUES(3, '15:00:00', 1, 200, true);
INSERT INTO SCHEDULE VALUES(3, '15:00:00', 1, 201, true);
\echo '\n'

\echo 'TEST CASE: attempt INSERTing schedule for a route where destination station(s) will close before route completion'
\echo 'EXPECTED BEHAVIOR: raises exception stating the rail is already in use (either once or twice here)'
INSERT INTO SCHEDULE VALUES(1, '23:00:00', 15, 200, true);
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
