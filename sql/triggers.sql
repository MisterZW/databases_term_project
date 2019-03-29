DROP FUNCTION IF EXISTS create_trips() CASCADE;

CREATE FUNCTION create_trips()
RETURNS TRIGGER
AS $$
DECLARE
	train_rec RECORD;
	rs_cursor CURSOR FOR SELECT rs_id, conn_id
		FROM ROUTE_STATIONS AS rs 
		WHERE rs.route_id = NEW.t_route;
	next_rs RECORD;
	conn_rec RECORD;
	rail_rec RECORD;
	t_cost NUMERIC(6, 2);
	temp_time NUMERIC(6,2);
	hours INT;
	minutes INT;
	t_time INTERVAL;
	arr_time TIME;
BEGIN
	SELECT * 
		FROM TRAIN as t 
		WHERE t.train_id = NEW.train_id 
		into train_rec;

	arr_time = NEW.sched_time;
	open rs_cursor;

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

			INSERT INTO TRIP (sched_id, seats_left, rs_id, trip_distance,
				trip_cost, trip_time, arrival_time)
			VALUES(NEW.sched_id, train_rec.seats, next_rs.rs_id,
				conn_rec.distance, t_cost, t_time, arr_time);
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
	SELECT * FROM TRIP as t WHERE t.trip_id = NEW.trip INTO trip_rec;

	IF NEW.num_tickets > trip_rec.seats_left
	THEN
		RETURN NULL;
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
