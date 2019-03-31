DROP FUNCTION IF EXISTS create_trips() CASCADE;

--BUILD TRACKING OF EACH LEG OF ACTIVE TRIPS DYNAMICALLY FROM SCHEDULE--
CREATE FUNCTION create_trips()
RETURNS TRIGGER
AS $$
DECLARE
	train_rec RECORD;
	rs_cursor REFCURSOR;
	next_rs RECORD;
	conn_rec RECORD;
	rail_rec RECORD;
	t_cost NUMERIC(6, 2);
	temp_time NUMERIC(6, 2);
	hours INT;
	minutes INT;
	t_time INTERVAL;
	arr_time TIME;
	depart_time TIME;
	depart_station INT;
	station_times RECORD;
BEGIN
	SELECT * 
		FROM TRAIN as t 
		WHERE t.train_id = NEW.train_id 
		into train_rec;

	arr_time = NEW.sched_time;
	depart_time = NEW.sched_time;

	IF NEW.is_forward IS TRUE
	THEN
		open rs_cursor FOR
		SELECT * FROM ROUTE_STATIONS AS rs 
		WHERE rs.route_id = NEW.t_route
		ORDER BY ordinal ASC;
	ELSE
		open rs_cursor FOR
		SELECT * FROM ROUTE_STATIONS AS rs 
		WHERE rs.route_id = NEW.t_route
		ORDER BY ordinal DESC;
	END IF;

	LOOP
		FETCH rs_cursor INTO next_rs;

		IF NOT FOUND THEN
			EXIT;
		END IF;

		IF next_rs.conn_id IS NOT NULL
		THEN
			SELECT * FROM CONNECTION AS c WHERE next_rs.conn_id = c.conn_id INTO conn_rec;
			SELECT * FROM RAIL_LINE AS rl WHERE rl.rail_id = conn_rec.rail INTO rail_rec;
			t_cost = (train_rec.ppm * conn_rec.distance);

			temp_time = conn_rec.distance / LEAST(train_rec.top_speed, rail_rec.speed_limit);
			hours = floor(temp_time);
			temp_time = temp_time - floor(temp_time);
			minutes = floor(temp_time * 60);

			t_time = make_interval(hours := hours, mins := minutes);
			arr_time = arr_time + t_time;
			
			-- CONSTRAINT TO ENSURE NOT OVERLAPPING ANOTHER TRAIN'S RAIL USE --
			IF EXISTS (SELECT * FROM SCHEDULE as s, TRIP as t
						WHERE s.sched_day = NEW.sched_day
						AND t.sched_id = s.sched_id
						AND t.rail_id = rail_rec.rail_id
						AND (t.arrival_time BETWEEN depart_time AND arr_time OR
							 (t.arrival_time - t.trip_time) BETWEEN depart_time AND arr_time))
			THEN
				RAISE integrity_constraint_violation 
				USING MESSAGE = 'CONSTRAINT VIOLATION: RAIL ID ' || rail_rec.rail_id ||
					' is already in use at that day/time combination.';
			END IF;


			depart_time = arr_time;

			-- CONSTRAINT TO ENSURE TRAINS DO NOT STOP AT CLOSED STATIONS--
			SELECT s.close_time, s.open_time FROM STATION as s 
				WHERE s.station_id = next_rs.station_id INTO station_times;

			IF next_rs.stops_here AND (arr_time > station_times.close_time OR 
				arr_time < station_times.open_time)
			THEN
				RAISE integrity_constraint_violation 
				USING MESSAGE = 'CONSTRAINT VIOLATION: STATION ID ' || next_rs.station_id ||
					' is closed at ' || arr_time;
			END IF;


			IF next_rs.station_id = conn_rec.station_1
			THEN
				depart_station = conn_rec.station_2;
			ELSE
				depart_station = conn_rec.station_1;
			END IF;

			INSERT INTO TRIP (sched_id, seats_left, rs_id, trip_distance,
				trip_cost, trip_time, arrival_time, depart_station, rail_id)
			VALUES(NEW.sched_id, train_rec.seats, next_rs.rs_id,
				conn_rec.distance, t_cost, t_time, arr_time, depart_station, rail_rec.rail_id);
		END IF;
	END LOOP;

	close rs_cursor;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sched_needs_trips
BEFORE INSERT ON SCHEDULE
FOR EACH ROW
EXECUTE PROCEDURE create_trips();


DROP FUNCTION IF EXISTS update_seats_left() CASCADE;

-- updates TRIP seating totals when bookings are made
CREATE FUNCTION update_seats_left() 
RETURNS TRIGGER
AS $$
DECLARE
	trip_rec RECORD;
BEGIN
	SELECT DISTINCT * FROM TRIP as t WHERE t.trip_id = NEW.trip INTO trip_rec;

--CONSTRAINT PREVENTS OVERBOOKING TRAINS--
	IF NEW.num_tickets > trip_rec.seats_left
	THEN
		RAISE integrity_constraint_violation 
			USING MESSAGE = 'CONSTRAINT VIOLATION: Cannot overbook tripID ' || trip_rec.trip_id  ||
				' -- Tried to book ' || NEW.num_tickets || ' seats but train only has ' || 
				trip_rec.seats_left || ' seats left.';
	ELSE
		UPDATE TRIP
		SET seats_left = seats_left - NEW.num_tickets
		WHERE trip_rec.trip_id = TRIP.trip_id;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_sell_tickets
BEFORE INSERT ON BOOKING
FOR EACH ROW
EXECUTE PROCEDURE update_seats_left();
