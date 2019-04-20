/*
* This file contains most of the interface/functionality for ExpressRailway
*
 */

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


-- Change customer information in the system wholesale (ID# cannot be altered)
CREATE OR REPLACE FUNCTION update_customer_account(id_no INT, fname VARCHAR, lname VARCHAR, em VARCHAR,
    ph CHAR, addr VARCHAR, c VARCHAR, z CHAR)
RETURNS VOID
AS $$
BEGIN
    UPDATE PASSENGER
    SET first_name = fname,
        last_name = lname,
        email = em,
        phone = ph,
        street_address = addr,
        city = c,
        zip = z
    WHERE customer_ID = id_no;
    RETURN;
END;
$$
LANGUAGE 'plpgsql';

  

-- View client data by client id number
CREATE OR REPLACE FUNCTION view_customer_account(id_no INT)
RETURNS TABLE (
    first_name      VARCHAR(20),
    last_name       VARCHAR(20),
    email           VARCHAR(35),
    phone           CHAR(10),
    street_address  VARCHAR(50),
    city            VARCHAR(25),
    zip             CHAR(5),
    customer_ID     INT
)
AS $$
BEGIN
    RETURN QUERY SELECT * FROM PASSENGER as p WHERE p.customer_ID = id_no LIMIT 1;
END;
$$
LANGUAGE 'plpgsql';



-- Make a reservation for all trips between arr_station and dest_station on a schedule
-- Makes reservation as a transaction, so all bookings will fail if any one booking fails
CREATE OR REPLACE FUNCTION make_reservation(agent_username VARCHAR, passenger_id INT, target_schedule INT, num_tickets INT,
    arr_station INT, dest_station INT)
RETURNS VOID
AS $$
DECLARE
    sched_rec RECORD;
    arr_stat_ord INT;
    dest_stat_ord INT;
    trip_cursor REFCURSOR;
    trip_rec RECORD;
BEGIN
    SELECT * from SCHEDULE as s where s.sched_id = target_schedule INTO sched_rec;
    arr_stat_ord = get_station_ordinal(sched_rec.t_route, arr_station);
    dest_stat_ord = get_station_ordinal(sched_rec.t_route, dest_station);

    open trip_cursor FOR SELECT DISTINCT *
        FROM TRIP as t
        WHERE t.sched_id = sched_rec.sched_id
        AND CASE WHEN arr_stat_ord < dest_stat_ord
                THEN    get_station_ordinal(sched_rec.t_route, t.depart_station) BETWEEN arr_stat_ord AND dest_stat_ord
                ELSE    get_station_ordinal(sched_rec.t_route, t.depart_station) BETWEEN dest_stat_ord AND arr_stat_ord
                END;

    LOOP
        FETCH trip_cursor INTO trip_rec;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        INSERT INTO BOOKING VALUES(agent_username, passenger_id, trip_rec.trip_id, num_tickets);
    END LOOP;

END;
$$
LANGUAGE 'plpgsql';



-- Find all trains that do not stop at a specified station at any
-- time during an entire week.
-- @param target_station    the station_id of the station of interest
CREATE OR REPLACE FUNCTION trains_which_dont_go_here(target_station INT)
RETURNS TABLE (
    train_id    INT
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

-- Find any stations that all the trains (that are in the system) pass at any
-- time during an entire week.
CREATE OR REPLACE FUNCTION stations_all_trains_pass_through()
RETURNS TABLE (
    station_id  INT
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
-- @param target_percent:   percentage between 10 and 90
CREATE OR REPLACE FUNCTION greater_than_percent_stops(target_percent INT)
RETURNS TABLE (
    route_id    INT
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

--returns true if target station is a STOP (NOT just a passed station) on target route
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
    departure_station                   INT,
    destination_station                 INT,
    stops_at_depart_station             BOOLEAN,
    stops_at_dest_station               BOOLEAN,
    trip_id                             INT,
    seats_left                          INT
)
AS $$
BEGIN

    RETURN QUERY SELECT DISTINCT
                CASE WHEN s.is_forward IS TRUE THEN t.depart_station ELSE rs.station_id END,
                CASE WHEN s.is_forward IS TRUE THEN rs.station_id ELSE t.depart_station END,
                CASE WHEN s.is_forward IS TRUE THEN stops_here(target_route, t.depart_station)
                    ELSE rs.stops_here END,
                CASE WHEN s.is_forward IS TRUE THEN rs.stops_here
                    ELSE stops_here(target_route, t.depart_station) END,
                t.trip_id, t.seats_left

                 FROM TRIP as t, ROUTE_STATIONS as rs, SCHEDULE as s
                 WHERE s.sched_day = target_day
                 AND s.sched_time = target_time
                 AND s.t_route = target_route
                 AND t.sched_id = s.sched_id
                 AND rs.route_id = target_route
                 AND t.rs_id = rs.rs_id
                 ORDER BY t.trip_id ASC;
END;
$$
LANGUAGE 'plpgsql';


/*******************************************************************************************
* Find all routes that stop at a specified arrival station and then at the specified
* destination station on a specified day of the week
*
* excludes trip results which have no available seats
*******************************************************************************************/

CREATE OR REPLACE FUNCTION single_trip_route_search(arr_st INT, dest_st INT, target_day INT)
RETURNS TABLE (
    route_id                INT,
    sched_id                INT,
    num_stations_passed     INT,
    num_stops               INT,
    total_price             NUMERIC,
    total_distance          NUMERIC,
    total_time              INTERVAL
)
AS $$
DECLARE
BEGIN
    RETURN QUERY SELECT DISTINCT
                    s.t_route AS route_id,
                    s.sched_id AS sched_id,
                    get_num_stations_passed(s.t_route, arr_st, dest_st) AS num_stations_passed,
                    get_num_stops(s.t_route, arr_st, dest_st) AS num_stops,
                    get_route_price(s.t_route, arr_st, dest_st, s.sched_id) AS total_price,
                    get_route_distance(s.t_route, arr_st, dest_st, s.sched_id) AS total_distance,
                    get_route_time(s.t_route, arr_st, dest_st, s.sched_id) AS total_time

                 FROM SCHEDULE AS s, TRIP as t, ROUTE_STATIONS as rs
                 WHERE s.sched_day = target_day
                 AND rs.route_id = s.t_route
                 AND t.sched_id = s.sched_id
                 AND s.t_route IN (SELECT r1.route_id
                            FROM ROUTE_STATIONS AS r1, ROUTE_STATIONS AS r2
                            WHERE r1.route_id = r2.route_id
                            AND r1.station_id = arr_st
                            AND r2.station_id = dest_st
                            AND r1.stops_here IS TRUE
                            AND r2.stops_here IS TRUE
                            AND NOT EXISTS (SELECT * FROM find_route_availability(s.t_route, s.sched_day, s.sched_time)
                                WHERE seats_left <= 0 LIMIT 1)
                            AND CASE WHEN s.is_forward IS TRUE
                                THEN r1.ordinal < r2.ordinal
                                ELSE r1.ordinal > r2.ordinal
                                END)
                 GROUP BY s.t_route, s.sched_id;
END;
$$
LANGUAGE 'plpgsql';


/******************************************************************************************
* Combinatory search function: Find all route combinations that stop
* at the specified Arrival Station and then at the specified Destination
* Station on a specified day of the week.
*
* Returns a table of integer arrays representing possible combinations of trip IDs
* which link source to sink in the graph (taking into account day and seats available)
*
* Also returns desciptive statistics about the route which can be used to sort results
******************************************************************************************/

CREATE OR REPLACE FUNCTION combo_search(first_station INT, last_station INT, target_day INT)
RETURNS TABLE (
    full_path               integer [],
    num_stations_passed     INT,
    num_stops               INT,
    total_price             NUMERIC,
    total_distance          NUMERIC,
    total_time              INTERVAL
)
AS $$
BEGIN
    RETURN QUERY
        WITH RECURSIVE combo(id, source, dest, depth, day, t_time, full_path, num_stops,
                total_price, total_distance, total_time) AS (
            SELECT t.trip_id,
            CASE WHEN s.is_forward IS TRUE THEN t.depart_station ELSE rs.station_id END,
            CASE WHEN s.is_forward IS TRUE THEN rs.station_id ELSE t.depart_station END,
            1, s.sched_day, t.arrival_time,
            ARRAY [ t.trip_id ] as full_path, 1 + (CASE WHEN rs.stops_here IS TRUE THEN 1 ELSE 0 END),
                t.trip_cost, t.trip_distance, t.trip_time
            FROM TRIP as t, SCHEDULE as s, ROUTE_STATIONS as rs
            WHERE
                CASE WHEN s.is_forward IS TRUE
                    THEN t.depart_station = first_station
                    ELSE rs.station_id = first_station END
                AND t.sched_id = s.sched_id
                AND s.sched_day = target_day
                AND rs.rs_id = t.rs_id
                AND t.seats_left > 0

        UNION

            SELECT tr.trip_id, c.source, CASE WHEN s2.is_forward IS TRUE THEN rs2.station_id ELSE tr.depart_station END,
                c.depth + 1, s2.sched_day, tr.arrival_time,
                array_append(c.full_path, tr.trip_id), c.num_stops + (CASE WHEN rs2.stops_here IS TRUE THEN 1 ELSE 0 END),
                CAST( (c.total_price + tr.trip_cost) AS NUMERIC(6,2) ),
                CAST( (c.total_distance + tr.trip_distance) AS NUMERIC(6,2) ),
                (c.total_time + tr.trip_time)
            FROM TRIP as tr, SCHEDULE as s2, ROUTE_STATIONS as rs2, combo as c
            WHERE
                CASE WHEN s2.is_forward IS TRUE
                    THEN tr.depart_station = c.dest
                    ELSE rs2.station_id = c.dest END
                AND s2.sched_day = c.day
                AND tr.sched_id = s2.sched_id
                AND rs2.rs_id = tr.rs_id
                AND tr.seats_left > 0
                AND tr.arrival_time > c.t_time
        )
        SELECT co.full_path, co.depth + 1 as num_stations_passed, co.num_stops, co.total_price,
            co.total_distance, co.total_time
        FROM combo as co
        WHERE co.dest = last_station;
END;
$$
LANGUAGE 'plpgsql';


-- Find all trains that pass through a specific station at a specific
-- day/time combination: Find the trains that pass through a specific
-- station on a specific day and time.
CREATE OR REPLACE FUNCTION trains_through_this_station(target_time TIME, target_day INT, target_station INT)
RETURNS TABLE (
    train_id    INT
)
AS $$
BEGIN

RETURN QUERY (SELECT s.train_id
             FROM SCHEDULE as s, TRIP as t, ROUTE_STATIONS as rs
             WHERE rs.station_id = target_station
             AND rs.route_id = s.t_route
             AND t.sched_id = s.sched_id
             AND s.sched_day = target_day
             AND t.arrival_time = target_time)
            UNION
            (SELECT s.train_id FROM SCHEDULE as s, TRIP as t
            WHERE s.sched_day = target_day
            AND s.sched_time = target_time
            AND t.sched_id = s.sched_id
            AND t.depart_station = target_station);

END;
$$
LANGUAGE 'plpgsql';


-- Find the routes that travel more than one rail line
CREATE OR REPLACE FUNCTION more_than_one_rail()
RETURNS TABLE (
    route_id    INT
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
    route1  INT,
    route2  INT
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
                             WHERE rsa.route_id < rsb.route_id
                             AND rsa.route_id = tr1.route_id
                             AND rsb.route_id = tr2.route_id
                             AND rsa.station_id = rsb.station_id
                             AND rsa.stops_here IS TRUE
                             AND rsb.stops_here IS FALSE )
                 );

END;
$$
LANGUAGE 'plpgsql';


-- get the number of stops on a given route between arr_station and dest_station, inclusive
-- returns 0 if arr_station and dest_station are the same
CREATE OR REPLACE FUNCTION get_num_stops(target_route INT, arr_station INT, dest_station INT)
RETURNS INT
AS $$
DECLARE
    arr_stat_ord INT;
    dest_stat_ord INT;
BEGIN
    IF arr_station = dest_station
    THEN
        RETURN 0;
    ELSE
        arr_stat_ord = get_station_ordinal(target_route, arr_station);
        dest_stat_ord = get_station_ordinal(target_route, dest_station);

        RETURN COUNT(DISTINCT rs.station_id)
            FROM ROUTE_STATIONS as rs
            WHERE rs.route_id = target_route
            AND rs.stops_here IS TRUE
            AND CASE WHEN arr_stat_ord < dest_stat_ord
                THEN    rs.ordinal BETWEEN arr_stat_ord AND dest_stat_ord
                ELSE    rs.ordinal BETWEEN dest_stat_ord AND arr_stat_ord
                END;
    END IF;

END;
$$
LANGUAGE 'plpgsql';


-- get the number of stations passed on a given route between arr_station and dest_station, inclusive
-- returns 0 if arr_station and dest_station are the same
CREATE OR REPLACE FUNCTION get_num_stations_passed(target_route INT, arr_station INT, dest_station INT)
RETURNS INT
AS $$
DECLARE
    arr_stat_ord INT;
    dest_stat_ord INT;
BEGIN
    IF arr_station = dest_station
    THEN
        RETURN 0;
    ELSE
        arr_stat_ord = get_station_ordinal(target_route, arr_station);
        dest_stat_ord = get_station_ordinal(target_route, dest_station);

        RETURN COUNT(DISTINCT rs.station_id)
            FROM ROUTE_STATIONS as rs
            WHERE rs.route_id = target_route
            AND CASE WHEN arr_stat_ord < dest_stat_ord
                THEN    rs.ordinal BETWEEN arr_stat_ord AND dest_stat_ord
                ELSE    rs.ordinal BETWEEN dest_stat_ord AND arr_stat_ord
                END;
    END IF;

END;
$$
LANGUAGE 'plpgsql';


-- get the total distance of a route between arr_station and dest_station
CREATE OR REPLACE FUNCTION get_route_distance(target_route INT, arr_station INT, dest_station INT,
    target_schedule INT)
RETURNS NUMERIC (6,2)
AS $$
DECLARE
    arr_stat_ord INT;
    dest_stat_ord INT;
BEGIN
    IF arr_station = dest_station
    THEN
        RETURN 0;
    ELSE
        arr_stat_ord = get_station_ordinal(target_route, arr_station);
        dest_stat_ord = get_station_ordinal(target_route, dest_station);

        RETURN SUM(t.trip_distance)
            FROM ROUTE_STATIONS as rs, TRIP as t
            WHERE rs.route_id = target_route
            AND t.sched_id = target_schedule
            AND t.rs_id = rs.rs_id
            AND CASE WHEN arr_stat_ord < dest_stat_ord
                THEN    rs.ordinal BETWEEN arr_stat_ord AND dest_stat_ord
                ELSE    rs.ordinal BETWEEN dest_stat_ord AND arr_stat_ord
                END
            AND CASE WHEN arr_stat_ord < dest_stat_ord
                THEN    get_station_ordinal(rs.route_id, t.depart_station)
                    BETWEEN arr_stat_ord AND dest_stat_ord
                ELSE    get_station_ordinal(rs.route_id, t.depart_station)
                    BETWEEN dest_stat_ord AND arr_stat_ord
                END;
    END IF;

END;
$$
LANGUAGE 'plpgsql';


-- get the total price of a route between arr_station and dest_station
CREATE OR REPLACE FUNCTION get_route_price(target_route INT, arr_station INT, dest_station INT,
    target_schedule INT)
RETURNS NUMERIC
AS $$
DECLARE
    arr_stat_ord INT;
    dest_stat_ord INT;
BEGIN
    IF arr_station = dest_station
    THEN
        RETURN 0;
    ELSE
        arr_stat_ord = get_station_ordinal(target_route, arr_station);
        dest_stat_ord = get_station_ordinal(target_route, dest_station);

        RETURN SUM(t.trip_cost)
            FROM ROUTE_STATIONS as rs, TRIP as t
            WHERE rs.route_id = target_route
            AND t.sched_id = target_schedule
            AND t.rs_id = rs.rs_id
            AND CASE WHEN arr_stat_ord < dest_stat_ord
                THEN    rs.ordinal BETWEEN arr_stat_ord AND dest_stat_ord
                ELSE    rs.ordinal BETWEEN dest_stat_ord AND arr_stat_ord
                END
            AND CASE WHEN arr_stat_ord < dest_stat_ord
                THEN    get_station_ordinal(rs.route_id, t.depart_station)
                    BETWEEN arr_stat_ord AND dest_stat_ord
                ELSE    get_station_ordinal(rs.route_id, t.depart_station)
                    BETWEEN dest_stat_ord AND arr_stat_ord
                END;
    END IF;

END;
$$
LANGUAGE 'plpgsql';



-- get the total time of a route between arr_station and dest_station
CREATE OR REPLACE FUNCTION get_route_time(target_route INT, arr_station INT, dest_station INT,
    target_schedule INT)
RETURNS INTERVAL
AS $$
DECLARE
    arr_stat_ord INT;
    dest_stat_ord INT;
BEGIN
    IF arr_station = dest_station
    THEN
        RETURN 0;
    ELSE
        arr_stat_ord = get_station_ordinal(target_route, arr_station);
        dest_stat_ord = get_station_ordinal(target_route, dest_station);

        RETURN SUM(t.trip_time)
            FROM ROUTE_STATIONS as rs, TRIP as t
            WHERE rs.route_id = target_route
            AND t.sched_id = target_schedule
            AND t.rs_id = rs.rs_id
            AND CASE WHEN arr_stat_ord < dest_stat_ord
                THEN    rs.ordinal BETWEEN arr_stat_ord AND dest_stat_ord
                ELSE    rs.ordinal BETWEEN dest_stat_ord AND arr_stat_ord
                END
            AND CASE WHEN arr_stat_ord < dest_stat_ord
                THEN    get_station_ordinal(rs.route_id, t.depart_station)
                    BETWEEN arr_stat_ord AND dest_stat_ord
                ELSE    get_station_ordinal(rs.route_id, t.depart_station)
                    BETWEEN dest_stat_ord AND arr_stat_ord
                END;
    END IF;

END;
$$
LANGUAGE 'plpgsql';



-- Display all schedules of a route for the week
CREATE OR REPLACE FUNCTION get_route_schedule(target_route INT)
RETURNS TABLE (
    departure_day       INT,
    departure_time      time,
    train_id            INT
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



/****************************************************************************
* Wrapper for single trip route search to order results by specified criteria
* order_by_option values:
*
* 1: stops
* 2: stations passed
* 3: total price
* 4: total time
* 5: total distance
*
*
* TO PRODUCE PAGINATED RESULTS:
*
* SELECT * FROM sort_STRS([parameters])
* FETCH FIRST 10 ROWS ONLY;
*
* SELECT * FROM sort_STRS([parameters])
* OFFSET [num_rows_already_retured]
* FETCH NEXT 10 ROWS;
*
****************************************************************************/

CREATE OR REPLACE FUNCTION sort_STRS(order_by_option INT, order_asc BOOLEAN,
    arr_st INT, dest_st INT, target_day INT)
RETURNS TABLE (
    route_id                INT,
    sched_id                INT,
    num_stations_passed     INT,
    num_stops               INT,
    total_price             NUMERIC,
    total_distance          NUMERIC,
    total_time              INTERVAL
)
AS $$
BEGIN
    IF order_asc
    THEN
        RETURN QUERY SELECT * FROM
        single_trip_route_search(arr_st, dest_st, target_day) as res
             ORDER BY CASE
             WHEN order_by_option = 1
                THEN res.num_stops
             WHEN order_by_option = 2
                THEN res.num_stations_passed
             WHEN order_by_option = 3
                THEN res.total_price
             WHEN order_by_option = 4
                THEN (EXTRACT(HOUR from res.total_time) * 60) + EXTRACT(MINUTE FROM res.total_time)
             ELSE
                res.total_distance
             END ASC;
    ELSE
        RETURN QUERY SELECT * FROM
        single_trip_route_search(arr_st, dest_st, target_day) as res
             ORDER BY CASE
             WHEN order_by_option = 1
                THEN res.num_stops
             WHEN order_by_option = 2
                THEN res.num_stations_passed
             WHEN order_by_option = 3
                THEN res.total_price
             WHEN order_by_option = 4
                THEN (EXTRACT(HOUR from res.total_time) * 60) + EXTRACT(MINUTE FROM res.total_time)
             ELSE
                res.total_distance
             END DESC;
    END IF;
END;
$$
LANGUAGE 'plpgsql';

/****************************************************************************
* Wrapper for combo_search to order results by specified criteria
* order_by_option values:
*
* 1: stops
* 2: stations passed
* 3: total price
* 4: total time
* 5: total distance
*
* TO PRODUCE PAGINATED RESULTS:
*
* SELECT * FROM sort_CTRS([parameters])
* FETCH FIRST 10 ROWS ONLY;
*
* SELECT * FROM sort_CTRS([parameters])
* OFFSET [num_rows_already_retured]
* FETCH NEXT 10 ROWS;
*
****************************************************************************/
CREATE OR REPLACE FUNCTION sort_CTRS(order_by_option INT, order_asc BOOLEAN,
    arr_st INT, dest_st INT, target_day INT)
RETURNS TABLE (
    full_path               integer [],
    num_stations_passed     INT,
    num_stops               INT,
    total_price             NUMERIC,
    total_distance          NUMERIC,
    total_time              INTERVAL
)
AS $$
BEGIN
    IF order_asc
    THEN
        RETURN QUERY SELECT * FROM
        combo_search(arr_st, dest_st, target_day) as res
             ORDER BY CASE
             WHEN order_by_option = 1
                THEN res.num_stops
             WHEN order_by_option = 2
                THEN res.num_stations_passed
             WHEN order_by_option = 3
                THEN res.total_price
             WHEN order_by_option = 4
                THEN (EXTRACT(HOUR from res.total_time) * 60) + EXTRACT(MINUTE FROM res.total_time)
             ELSE
                res.total_distance
             END ASC;
    ELSE
        RETURN QUERY SELECT * FROM
        combo_search(arr_st, dest_st, target_day) as res
             ORDER BY CASE
             WHEN order_by_option = 1
                THEN res.num_stops
             WHEN order_by_option = 2
                THEN res.num_stations_passed
             WHEN order_by_option = 3
                THEN res.total_price
             WHEN order_by_option = 4
                THEN (EXTRACT(HOUR from res.total_time) * 60) + EXTRACT(MINUTE FROM res.total_time)
             ELSE
                res.total_distance
             END DESC;
    END IF;
END;
$$
LANGUAGE 'plpgsql';


/* Drops all data from all tables, but retains the database schema */
CREATE OR REPLACE FUNCTION drop_database()
RETURNS VOID
AS $$
BEGIN
    DELETE FROM BOOKING CASCADE;
    DELETE FROM TRIP CASCADE;
    DELETE FROM SCHEDULE CASCADE;
    DELETE FROM ROUTE_STATIONS CASCADE;
    DELETE FROM CONNECTION CASCADE;
    DELETE FROM TRAIN_ROUTE CASCADE;
    DELETE FROM STATION CASCADE;
    DELETE FROM TRAIN CASCADE;
    DELETE FROM PASSENGER CASCADE;
    DELETE FROM RAIL_LINE CASCADE;
    DELETE FROM AGENT CASCADE;

    -- resetting serials to 1 avoids breaking test data insert scripts --
    ALTER SEQUENCE connection_conn_id_seq RESTART WITH 1;
    ALTER SEQUENCE passenger_customer_id_seq RESTART WITH 1;
    ALTER SEQUENCE rail_line_rail_id_seq RESTART WITH 1;
    ALTER SEQUENCE route_stations_rs_id_seq RESTART WITH 1;
    ALTER SEQUENCE schedule_sched_id_seq RESTART WITH 1;
    ALTER SEQUENCE station_station_id_seq RESTART WITH 1;
    ALTER SEQUENCE train_route_route_id_seq RESTART WITH 1;
    ALTER SEQUENCE train_train_id_seq RESTART WITH 1;
    ALTER SEQUENCE trip_trip_id_seq RESTART WITH 1;
END;
$$
LANGUAGE 'plpgsql';


--adjust serials to proper place in sequence after importing a custom database
CREATE OR REPLACE FUNCTION fix_serials()
RETURNS VOID
AS $$
BEGIN
    PERFORM setval(pg_get_serial_sequence('CONNECTION', 'conn_id'), coalesce(max(conn_id),0) + 1, false) FROM CONNECTION;
    PERFORM setval(pg_get_serial_sequence('PASSENGER', 'customer_id'), coalesce(max(customer_id),0) + 1, false) FROM PASSENGER;
    PERFORM setval(pg_get_serial_sequence('RAIL_LINE', 'rail_id'), coalesce(max(rail_id),0) + 1, false) FROM RAIL_LINE;
    PERFORM setval(pg_get_serial_sequence('ROUTE_STATIONS', 'rs_id'), coalesce(max(rs_id),0) + 1, false) FROM ROUTE_STATIONS;
    PERFORM setval(pg_get_serial_sequence('SCHEDULE', 'sched_id'), coalesce(max(sched_id),0) + 1, false) FROM SCHEDULE;
    PERFORM setval(pg_get_serial_sequence('STATION', 'station_id'), coalesce(max(station_id),0) + 1, false) FROM STATION;
    PERFORM setval(pg_get_serial_sequence('TRAIN_ROUTE', 'route_id'), coalesce(max(route_id),0) + 1, false) FROM TRAIN_ROUTE;
    PERFORM setval(pg_get_serial_sequence('TRAIN', 'train_id'), coalesce(max(train_id),0) + 1, false) FROM TRAIN;
    PERFORM setval(pg_get_serial_sequence('TRIP', 'trip_id'), coalesce(max(trip_id),0) + 1, false) FROM TRIP;
END;
$$ 
LANGUAGE 'plpgsql';


/* 
* use this to temporarily disable and reenable triggers
* needed to avoid duplicating trips when importing datasets which were
* previously exported from the database
*
* If setting is true, turn triggers on
* If setting if false, turn the triggers off
 */
CREATE OR REPLACE FUNCTION set_triggers(setting BOOLEAN)
RETURNS VOID
AS $$
BEGIN
    IF setting THEN
        ALTER TABLE BOOKING ENABLE TRIGGER trig_sell_tickets;
        ALTER TABLE SCHEDULE ENABLE TRIGGER sched_needs_trips;
    ELSE
        ALTER TABLE SCHEDULE DISABLE TRIGGER sched_needs_trips;
        ALTER TABLE BOOKING DISABLE TRIGGER trig_sell_tickets;
    END IF;
END;
$$
LANGUAGE 'plpgsql';
