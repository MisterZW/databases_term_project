--TESTS FOR THE dml commands on the small_data.sql dataset
--Some tests may not test behavior correctly on another dataset

\i schema.sql
\i small.sql
\i dml.sql


\echo 'TEST CASE: trains_which_dont_go_here(2)'
\echo 'EXPECTED BEHAVIOR: returns train 2, 4, and 5'
\echo 'Train 4 should be included because its route passes through but does not STOP here'
SELECT * FROM trains_which_dont_go_here(2);


\echo 'TEST CASE: stations_all_trains_pass_through()'
\echo 'EXPECTED BEHAVIOR: returns station 1 and 4'
SELECT * FROM stations_all_trains_pass_through();


\echo 'TEST CASE: greater_than_percent_stops(75)'
\echo 'EXPECTED BEHAVIOR: routes 1-4 are returned (5 & 6 omitted)'
SELECT * FROM greater_than_percent_stops(80);


\echo 'TEST CASE: trains_through_this_station(station A @ 9AM Monday)'
\echo 'EXPECTED BEHAVIOR: finds trains 1 and 2'
SELECT * FROM trains_through_this_station('09:00:00', 1, 1);


\echo 'TEST CASE: more_than_one_rail()'
\echo 'EXPECTED BEHAVIOR: returns route 6'
SELECT * FROM more_than_one_rail();


\echo 'TEST CASE: same_stations_diff_stops()'
\echo 'EXPECTED BEHAVIOR: returns pairs (1, 5), (1, 6) and (5, 6) in any order'
SELECT * FROM same_stations_diff_stops();


\echo 'TEST CASE: get_route_schedule(1)'
\echo 'EXPECTED BEHAVIOR: shows schedules for route 1'
SELECT * FROM get_route_schedule(1);


\echo 'TEST CASE: find_route_availability(route 1, day 1, time 9AM)'
\echo 'EXPECTED BEHAVIOR: shows availibility for route 1 along all trips (as 100 seats)'
SELECT * FROM find_route_availability(1, 1, '09:00:00');

\echo 'TEST CASE: make_reservation(50 tickets on schedule id #1)'
\echo 'EXPECTED BEHAVIOR: no errors for make_reservation itself (returns nothing)'
\echo 'Second call to find_route_availability() should show number of seats as 50 for both trips'
--make_reservation(agent_username VARCHAR, passenger_id INT, target_schedule INT, num_tickets INT,
    --arr_station INT, dest_station INT)
SELECT * FROM make_reservation('agent0', 1, 1, 50, 1, 2);
SELECT * FROM find_route_availability(1, 1, '09:00:00');


\echo 'TEST CASE: find_route_availability() for a schedule running route 1 BACKWARD'
\echo 'EXPECTED BEHAVIOR: shows availibility for route 1 appropriately for reversed route'
SELECT * FROM find_route_availability(1, 3, '12:00:00');

\echo 'TEST CASE: create_customer_account() AND view_customer_account()'
\echo 'EXPECTED BEHAVIOR: QUERY RETURNS CUSTOMER DATA WITH INTEGER customer_ID 11 and first_name "first"'
SELECT * FROM view_customer_account(
	create_customer_account('first', 'last', 'email','1234567890', 'address', 'city', '12345')
	);


\echo 'TEST CASE: attempt INSERTing schedule on a rail already in use at that day/time'
\echo 'EXPECTED BEHAVIOR: raises exception stating the rail is already in use'
INSERT INTO SCHEDULE VALUES(1, '09:00:00', 1, 5, true);
\echo '\n'


\echo 'TEST CASE: attempt INSERTing schedule for a route where destination station(s) will close before route completion'
\echo 'EXPECTED BEHAVIOR: raises exception stating the rail is already in use (either once or twice here)'
INSERT INTO SCHEDULE VALUES(1, '22:30:00', 1, 5, true);
\echo '\n'

\echo 'TEST CASE: attempt INSERTing a booking for a trip which will overbook the train'
\echo 'EXPECTED BEHAVIOR: raises exception stating there are not enough seats to accomodate the reservation'
INSERT INTO BOOKING VALUES('agent0', 1, 1, 1000);
\echo '\n'


\echo 'TEST CASE: attempt INSERTing two schedules for invalid days (0 and 8)'
\echo 'EXPECTED BEHAVIOR: triggers a check constraint which prevents both inserts'
INSERT INTO SCHEDULE VALUES(0, '08:00:00', 1, 1, true);
INSERT INTO SCHEDULE VALUES(8, '08:00:00', 1, 1, true);
\echo '\n'


\echo 'TEST CASE: attempt INSERTing two bookings for zero and for a negative number of tickets'
\echo 'EXPECTED BEHAVIOR: triggers a check constraint which prevents both inserts'
INSERT INTO BOOKING VALUES('agent0', 1, 1, 0);
INSERT INTO BOOKING VALUES('agent0', 1, 1, -2);
\echo '\n'


\echo 'TEST CASE: attempt INSERTing two connections with zero and negative distances'
\echo 'EXPECTED BEHAVIOR: triggers a check constraint which prevents both inserts'
INSERT INTO CONNECTION VALUES(1, 2, 1, 0);
INSERT INTO CONNECTION VALUES(1, 2, 1, -2.5);
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

\echo 'TEST CASE: test BACKWARD (D --> A) single_trip_route_search'
\echo 'EXPECTED BEHAVIOR: should find route 2 only'
SELECT * FROM sort_STRS(1, true, 4, 1, 1);
\echo '\n'


\echo 'TEST CASE: test FORWARD (A --> D) single_trip_route_search sorting by number of stops ascending, then descending'
\echo 'EXPECTED BEHAVIOR: should find routes options for routes 1, 3, and 5'
\echo 'first result lists route with fewest stops first, second lists it last'
SELECT * FROM sort_STRS(1, true, 1, 4, 1);
SELECT * FROM sort_STRS(1, false, 1, 4, 1);
\echo '\n'


\echo 'TEST CASE: test FORWARD (A --> D) STRS sorting by number of stations passed ascending, then descending'
\echo 'EXPECTED BEHAVIOR: results should be the same as previous STRS besides ordering'
\echo 'first result lists route with fewest stations passed first, second lists it last'
SELECT * FROM sort_STRS(2, true, 1, 4, 1);
SELECT * FROM sort_STRS(2, false, 1, 4, 1);
\echo '\n'


\echo 'TEST CASE: test FORWARD (A --> D) STRS sorting by total price ascending, then descending'
\echo 'EXPECTED BEHAVIOR: results should be the same as previous STRS besides ordering'
\echo 'first result listings by cheapest first, second lists cheapest last'
SELECT * FROM sort_STRS(3, true, 1, 4, 1);
SELECT * FROM sort_STRS(3, false, 1, 4, 1);
\echo '\n'

\echo 'TEST CASE: test FORWARD (A --> D) STRS sorting by total time ascending, then descending'
\echo 'EXPECTED BEHAVIOR: results should be the same as previous STRS besides ordering'
\echo 'first result listings by fastest first, second lists fastest last'
SELECT * FROM sort_STRS(4, true, 1, 4, 1);
SELECT * FROM sort_STRS(4, false, 1, 4, 1);
\echo '\n'


\echo 'TEST CASE: test FORWARD (A --> D) STRS sorting by total distance ascending, then descending'
\echo 'EXPECTED BEHAVIOR: results should be the same as previous STRS besides ordering'
\echo 'first result listings by fastest first, second lists fastest last'
SELECT * FROM sort_STRS(5, true, 1, 4, 1);
SELECT * FROM sort_STRS(5, false, 1, 4, 1);
\echo '\n'



-- sort_CTRS(order_by_option INT, order_asc BOOLEAN, arr_st INT, dest_st INT, target_day INT)
/*
* order_by_option values:
* 1: stops
* 2: stations passed
* 3: total price
* 4: total time
* 5: total distance
* default: distance
*/

\echo 'TEST CASE: test BACKWARD (D --> A) combo_search'
\echo 'EXPECTED BEHAVIOR: '
SELECT * FROM sort_CTRS(1, true, 4, 1, 1);
\echo '\n'


\echo 'TEST CASE: test FORWARD (A --> D) CTRS sorting by number of stops ascending, then descending'
\echo 'EXPECTED BEHAVIOR: finds all combination routes from station 1 to station 4'
\echo 'first result lists route with fewest stops first, second lists it last'
SELECT * FROM sort_CTRS(1, true, 1, 4, 1);
SELECT * FROM sort_CTRS(1, false, 1, 4, 1);
\echo '\n'


\echo 'TEST CASE: test FORWARD (A --> D) CTRS sorting by number of stations passed ascending, then descending'
\echo 'EXPECTED BEHAVIOR: results should be the same as previous STRS besides ordering'
\echo 'first result lists route with fewest stations passed first, second lists it last'
SELECT * FROM sort_CTRS(2, true, 1, 4, 1);
SELECT * FROM sort_CTRS(2, false, 1, 4, 1);
\echo '\n'


\echo 'TEST CASE: test FORWARD (A --> D) CTRS sorting by total price ascending, then descending'
\echo 'EXPECTED BEHAVIOR: results should be the same as previous STRS besides ordering'
\echo 'first result listings by cheapest first, second lists cheapest last'
SELECT * FROM sort_CTRS(3, true, 1, 4, 1);
SELECT * FROM sort_CTRS(3, false, 1, 4, 1);
\echo '\n'

\echo 'TEST CASE: test FORWARD (A --> D) CTRS sorting by total time ascending, then descending'
\echo 'EXPECTED BEHAVIOR: results should be the same as previous STRS besides ordering'
\echo 'first result listings by fastest first, second lists fastest last'
SELECT * FROM sort_CTRS(4, true, 1, 4, 1);
SELECT * FROM sort_CTRS(4, false, 1, 4, 1);
\echo '\n'


\echo 'TEST CASE: test FORWARD (A --> D) CTRS sorting by total distance ascending, then descending'
\echo 'EXPECTED BEHAVIOR: results should be the same as previous STRS besides ordering'
\echo 'first result listings by fastest first, second lists fastest last'
SELECT * FROM sort_CTRS(5, true, 1, 4, 1);
SELECT * FROM sort_CTRS(5, false, 1, 4, 1);
\echo '\n'


-- INCLUDE TESTS TO VERIFY ROUTE SEARCH DOESN'T INCLUDE BOOKED ROUTES

\echo 'FULLY BOOKING SCHEDULE ID 2 ON TRIP ID 3 to see if STRS and CTRS exclude this option'
INSERT INTO BOOKING (agent, passenger, trip, num_tickets)
	VALUES ('agent0', 2, 3, 100);
\echo '\n'


\echo 'TEST CASE: test STRS FORWARD (A --> D) '
\echo 'EXPECTED BEHAVIOR: same results as A --> D forward CTRS BUT excluding all options including sched id 2'
SELECT * FROM sort_STRS(1, true, 1, 4, 1);


\echo '\n'


\echo 'TEST CASE: test CTRS FORWARD (A --> D) '
\echo 'EXPECTED BEHAVIOR: same results as A --> D forward CTRS BUT excluding all options including trip id 3'
SELECT * FROM sort_CTRS(1, true, 1, 4, 1);
