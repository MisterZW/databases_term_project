-- Find all the trains that do not stop at a specific station: Find all
-- trains that do not stop at a specified station at any time during an
-- entire week.
-- @param target_station	the station_id of the station of interest
CREATE OR REPLACE FUNCTION trains_which_dont_go_here(target_station INT)
RETURNS TABLE (
	train_id	INT
)
AS $$
BEGIN
	RETURN QUERY SELECT t.train_id FROM TRAIN as t
							WHERE NOT EXISTS (SELECT DISTINCT s.train_id
							FROM SCHEDULE AS s, ROUTE_STATIONS AS rs
							WHERE s.train_id = t.train_id AND
							s.t_route = rs.route_id AND
							rs.station_id = target_station AND
							rs.stops_here IS TRUE);
END;
$$
LANGUAGE 'plpgsql';

-- Find any stations through which all trains pass through: Find
-- any stations that all the trains (that are in the system) pass at any
-- time during an entire week.

CREATE OR REPLACE FUNCTION stations_all_trains_pass_through()
RETURNS TABLE (
	station_id	INT
)
AS $$
BEGIN
	RETURN QUERY SELECT st.station_id FROM STATION as st
				 WHERE NOT EXISTS ( SELECT t.train_id FROM TRAIN as t
									WHERE NOT EXISTS (SELECT DISTINCT s.train_id
									FROM SCHEDULE AS s, ROUTE_STATIONS AS rs
									WHERE s.train_id = t.train_id AND
									s.t_route = rs.route_id AND
									rs.station_id = st.station_id ) );
END;
$$
LANGUAGE 'plpgsql';

-- Find routes that stop at least at XX% of the Stations they visit:	
-- @param target_percent:	percentage between 10 and 90

CREATE OR REPLACE FUNCTION greater_than_percent_stops(target_percent INT)
RETURNS TABLE (
	route_id	INT
)
AS $$
BEGIN

	RETURN QUERY SELECT DISTINCT outside.route_id
	FROM ROUTE_STATIONS outside
	WHERE target_percent <= ((SELECT COUNT(station_id) from ROUTE_STATIONS inside
							   	WHERE stops_here IS TRUE AND inside.route_id = outside.route_id) * 100 / 
								(SELECT COUNT(station_id) from ROUTE_STATIONS inside2
								WHERE inside2.route_id = outside.route_id));

END;
$$
LANGUAGE 'plpgsql';


-- Make a reservation for a trip
CREATE OR REPLACE FUNCTION make_reservation(agent_username VARCHAR, passenger_id INT, trip_id INT, num_tickets INT)
RETURNS VOID
AS $$
BEGIN
	INSERT INTO BOOKING VALUES(agent_username, passenger_id, trip_id, num_tickets);
END;
$$
LANGUAGE 'plpgsql';


-- Insert a new customer in to the system
CREATE OR REPLACE FUNCTION create_customer_account(fname VARCHAR, lname VARCHAR, email VARCHAR,
	phone CHAR, street_addr VARCHAR, city VARCHAR, zip CHAR)
RETURNS INT
AS $$
BEGIN
	INSERT INTO PASSENGER VALUES(fname, lname, email, phone, street_addr, city, zip);
	RETURN max(customer_id) FROM PASSENGER LIMIT 1;
END;
$$
LANGUAGE 'plpgsql';


-- View client data by client id number
CREATE OR REPLACE FUNCTION view_customer_account(id_no INT)
RETURNS RECORD
AS $$
DECLARE
	return_value RECORD;
BEGIN
	SELECT * FROM PASSENGER WHERE customer_id = id_no LIMIT 1 INTO return_value;
	RETURN return_value;
END;
$$
LANGUAGE 'plpgsql';


-- Update client data
--	UPDATE PASSENGER
--	SET $$old_field = $$new_value
--	WHERE customer_id = $$id;


-- Find all routes that stop at a specified arrival station and then at the specified
-- destination station on a specified day of the week
CREATE OR REPLACE FUNCTION single_trip_route_search(arr_st INT, dest_st INT, target_day INT) 
RETURNS TABLE (
	route_id	INT
)
AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT s.t_route FROM SCHEDULE AS s
				 WHERE s.sched_day = target_day AND
				 s.t_route IN 	(SELECT r1.route_id
				 				FROM ROUTE_STATIONS AS r1, ROUTE_STATIONS AS r2
				 				WHERE r1.route_id = r2.route_id
				 				AND r1.station_id = arr_st
				 				AND r2.station_id = dest_st
				 				AND r1.stops_here IS TRUE
				 				AND r2.stops_here IS TRUE
				 				AND CASE WHEN s.is_forward IS TRUE
				 					THEN r1.ordinal < r2.ordinal
				 					ELSE r1.ordinal > r2.ordinal
				 					END );
END;
$$
LANGUAGE 'plpgsql';


-- Find all trains that pass through a specific station at a specific
-- day/time combination: Find the trains that pass through a specific
-- station on a specific day and time.

/*

CREATE OR REPLACE FUNCTION trains_through_this_station()
RETURNS TABLE (
	train_id	INT
)
AS $$
BEGIN

END;
$$
LANGUAGE 'plpgsql';

*/

-- Find the routes that travel more than one rail line: Find all
-- routes that travel more than one rail line.

/*

CREATE OR REPLACE FUNCTION more_than_one_rail()
RETURNS TABLE (
	route_id	INT
)
AS $$
BEGIN

END;
$$
LANGUAGE 'plpgsql';

*/

-- Find routes that pass through the same stations but don’t have
-- the same stops: Find seemingly similar routes that differ by at least
-- 1 stop.

/*

CREATE OR REPLACE FUNCTION same_stations_diff_stops()
RETURNS TABLE (
	route1	INT
	route2	INT
)
AS $$
BEGIN

END;
$$
LANGUAGE 'plpgsql';

*/

-- Display the schedule of a route

-- Find the availability of a route at every stop on a specific day
-- and time:
