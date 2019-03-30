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
	route_id 	INT
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
				 					END);
END;
$$
LANGUAGE 'plpgsql';


-- Find all trains that pass through a specific station at a specific
-- day/time combination: Find the trains that pass through a specific
-- station on a specific day and time.
CREATE OR REPLACE FUNCTION trains_through_this_station(target_time TIME, target_day INT, target_station INT)
RETURNS TABLE (
	train_id	INT
)
AS $$
BEGIN

RETURN QUERY SELECT s.train_id
			 FROM SCHEDULE as s, TRIP as t, ROUTE_STATIONS as rs
			 WHERE rs.station_id = target_station
			 AND rs.route_id = s.t_route
			 AND t.sched_id = s.sched_id
			 AND s.sched_day = target_day
			 AND t.arrival_time = target_time;

END;
$$
LANGUAGE 'plpgsql';


-- Find the routes that travel more than one rail line
CREATE OR REPLACE FUNCTION more_than_one_rail()
RETURNS TABLE (
	route_id	INT
)
AS $$
BEGIN
	RETURN QUERY (SELECT DISTINCT rs1.route_id
				 FROM ROUTE_STATIONS as rs1, ROUTE_STATIONS as rs2,
				 	  CONNECTION as c1, CONNECTION as c2
				 WHERE rs1.conn_id = c1.conn_id
				 AND rs2.conn_id = c2.conn_id
				 AND rs1.route_id = rs2.route_id
				 AND c1.rail <> c2.rail);
END;
$$
LANGUAGE 'plpgsql';


-- Find routes that pass through the same stations but don’t have
-- the same stops: Find seemingly similar routes that differ by at least
-- 1 stop.

-- This is a monstrosity, but it works!
CREATE OR REPLACE FUNCTION same_stations_diff_stops()
RETURNS TABLE (
	route1	INT,
	route2	INT
)
AS $$
BEGIN

RETURN QUERY (SELECT DISTINCT tr1.route_id, tr2.route_id
				 FROM TRAIN_ROUTE as tr1, TRAIN_ROUTE as tr2
		
				 WHERE tr1.route_id < tr2.route_id

				 AND tr1.route_id IN (SELECT DISTINCT rs.route_id FROM ROUTE_STATIONS as rs)
				 AND tr2.route_id IN (SELECT DISTINCT rs.route_id FROM ROUTE_STATIONS as rs)

				 AND NOT EXISTS (SELECT outside.station_id FROM ROUTE_STATIONS as outside
				 	  			WHERE outside.route_id = tr1.route_id
				 	  			AND outside.station_id NOT IN (
				 	  				SELECT inside.station_id FROM ROUTE_STATIONS as inside
				 	  				WHERE inside.route_id = tr2.route_id
				 	  				AND inside.station_id = outside.station_id
				 	  				)
				 	  			)

				 AND NOT EXISTS (SELECT outside2.station_id FROM ROUTE_STATIONS as outside2
				 	  			WHERE outside2.route_id = tr2.route_id
				 	  			AND outside2.station_id NOT IN (
				 	  				SELECT inside2.station_id FROM ROUTE_STATIONS as inside2
				 	  				WHERE inside2.route_id = tr1.route_id
				 	  				AND inside2.station_id = outside2.station_id
				 	  				)
				 	  			)

				 AND EXISTS( SELECT rsa.station_id FROM ROUTE_STATIONS as rsa, ROUTE_STATIONS as rsb
				 			 WHERE rsa.route_id <> rsb.route_id
				 			 AND rsa.station_id = rsb.station_id
				 			 AND rsa.stops_here IS TRUE
				 			 AND rsb.stops_here IS FALSE )
				 );

END;
$$
LANGUAGE 'plpgsql';


--get the station ordinal
CREATE OR REPLACE FUNCTION get_station_ordinal(target_route INT, target_station INT)
RETURNS INT
AS $$
BEGIN

	RETURN rs.ordinal FROM ROUTE_STATIONS as rs 
	WHERE rs.station_id = target_station
	AND rs.route_id = target_route;

END;
$$
LANGUAGE 'plpgsql';

-- get the distance the train travels to an individual station
-- returns 0 if arr_station and dest_station are the same
-- returns nothing if stations/route combo is invalid
-- returns the distance otherwise (regardless of which station is listed first) 
CREATE OR REPLACE FUNCTION get_travel_distance(target_route INT, arr_station INT, dest_station INT)
RETURNS NUMERIC(6,2)
AS $$
BEGIN
	IF arr_station = dest_station
	THEN 
		RETURN 0;
	ELSE
		RETURN SUM(DISTINCT c.distance) 
			FROM ROUTE_STATIONS AS rs, CONNECTION as c
		    WHERE rs.route_id = target_route
		    AND rs.conn_id IS NOT NULL
		    AND rs.conn_id = c.conn_id
		    AND CASE WHEN arr_station < dest_station
		    	THEN	rs.ordinal BETWEEN get_station_ordinal(target_route, arr_station)
		    		   AND get_station_ordinal(target_route, dest_station)
		    	ELSE	rs.ordinal BETWEEN get_station_ordinal(target_route, dest_station)
		    		   AND get_station_ordinal(target_route, arr_station)
		    	END;
	END IF;
END;
$$
LANGUAGE 'plpgsql';

-- get the number of stops on a given route between arr_station and dest_station, inclusive
-- returns 0 if arr_station and dest_station are the same
CREATE OR REPLACE FUNCTION get_num_stops(target_route INT, arr_station INT, dest_station INT)
RETURNS INT
AS $$
BEGIN
	IF arr_station = dest_station
	THEN 
		RETURN 0;
	ELSE
		RETURN COUNT(DISTINCT rs.station_id) 
			FROM ROUTE_STATIONS as rs
			WHERE rs.route_id = target_route
			AND rs.stops_here IS TRUE
			AND CASE WHEN arr_station < dest_station
		    	THEN	rs.ordinal BETWEEN get_station_ordinal(target_route, arr_station)
		    		   AND get_station_ordinal(target_route, dest_station)
		    	ELSE	rs.ordinal BETWEEN get_station_ordinal(target_route, dest_station)
		    		   AND get_station_ordinal(target_route, arr_station)
		    	END;
	END IF;

END;
$$
LANGUAGE 'plpgsql';


-- get the number of stops on a given route between arr_station and dest_station, inclusive
-- returns 0 if arr_station and dest_station are the same
CREATE OR REPLACE FUNCTION get_num_stations_passed(target_route INT, arr_station INT, dest_station INT)
RETURNS INT
AS $$
BEGIN
	IF arr_station = dest_station
	THEN 
		RETURN 0;
	ELSE
		RETURN COUNT(DISTINCT rs.station_id) 
			FROM ROUTE_STATIONS as rs
			WHERE rs.route_id = target_route
			AND CASE WHEN arr_station < dest_station
		    	THEN	rs.ordinal BETWEEN get_station_ordinal(target_route, arr_station)
		    		   AND get_station_ordinal(target_route, dest_station)
		    	ELSE	rs.ordinal BETWEEN get_station_ordinal(target_route, dest_station)
		    		   AND get_station_ordinal(target_route, arr_station)
		    	END;
	END IF;

END;
$$
LANGUAGE 'plpgsql';


-- Display the schedule of a route
CREATE OR REPLACE FUNCTION get_route_schedule(target_route INT)
RETURNS TABLE (
	departure_day		INT,
	departure_time		time,
	train_id 			INT
)
AS $$
BEGIN
	RETURN QUERY SELECT s.sched_day AS departure_day, s.sched_time AS departure_time,
						s.train_id AS train_id
			  	FROM SCHEDULE AS s
				WHERE s.t_route = target_route
				ORDER BY departure_day DESC, departure_time DESC;

END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION stops_here(target_route INT, target_station INT)
RETURNS BOOLEAN
AS $$
BEGIN
	RETURN rs.stops_here FROM ROUTE_STATIONS as rs
	WHERE rs.route_id = target_route AND rs.station_id = target_station;
END;
$$
LANGUAGE 'plpgsql';


-- Find the availability of a route at every stop on a specific day and time
-- Will only return trips which stop either at the depart or destination stations
CREATE OR REPLACE FUNCTION find_route_availability(target_route INT, target_day INT, target_time TIME)
RETURNS TABLE (
	departure_station					INT,
	destination_station					INT,
	stops_at_depart_station 			BOOLEAN,
	stops_at_dest_station 				BOOLEAN,
	ordinal 							INT,
	seats_left							INT
)
AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT t.depart_station, rs.station_id, stops_here(target_route, t.depart_station), 
				rs.stops_here, rs.ordinal, t.seats_left
				 FROM TRIP as t, ROUTE_STATIONS as rs, SCHEDULE as s
				 WHERE s.sched_day = target_day
				 AND s.sched_time = target_time
				 AND s.t_route = target_route
				 AND t.sched_id = s.sched_id
				 AND (stops_here(target_route, t.depart_station) IS TRUE OR rs.stops_here IS TRUE)
				 AND rs.route_id = target_route
				 AND t.rs_id = rs.rs_id;
END;
$$
LANGUAGE 'plpgsql';


