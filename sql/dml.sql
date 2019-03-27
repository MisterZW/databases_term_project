-- Find all trains that pass through a specific station at a specific
-- day/time combination: Find the trains that pass through a specific
-- station on a specific day and time.

-- Find the routes that travel more than one rail line: Find all
-- routes that travel more than one rail line.

-- Find routes that pass through the same stations but don’t have
-- the same stops: Find seemingly similar routes that differ by at least
-- 1 stop.

-- Find any stations through which all trains pass through: Find
-- any stations that all the trains (that are in the system) pass at any
-- time during an entire week.

-- Find all the trains that do not stop at a specific station: Find all
-- trains that do not stop at a specified station at any time during an
-- entire week.

-- Find routes that stop at least at XX% of the Stations they visit:
	
	-- PARAMETER -- target_percent between 10 and 90

	SELECT DISTINCT route_id
	FROM ROUTE_STATIONS as outside
	WHERE (target_percent <= ((SELECT COUNT(station_id) from ROUTE_STATIONS as inside
							   	WHERE stops_here IS TRUE AND inside.route_id = outside.route_id) * 100 / 
								SELECT COUNT(station_id) from ROUTE_STATIONS as inside2
								WHERE inside2.route_id = outside.route_id);

-- Display the schedule of a route

-- Find the availability of a route at every stop on a specific day
-- and time:
