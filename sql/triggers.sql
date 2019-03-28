DROP FUNCTION IF EXISTS update_tickets_sold() CASCADE;

CREATE FUNCTION update_tickets_sold() 
RETURNS TRIGGER
AS $$
DECLARE
	train RECORD;
	trip_rec RECORD;
	sched RECORD;
BEGIN
	SELECT * FROM TRIP WHERE TRIP.sched_id = NEW.trip INTO trip_rec;
	SELECT * FROM SCHEDULE as s WHERE s.sched_id = trip_rec.sched_id INTO sched;
	SELECT * FROM TRAIN as t WHERE sched.train_id = t.train_id INTO train;
	
	IF trip_rec.tickets_sold + NEW.num_tickets > train.seats
	THEN
		RETURN NULL;
	ELSE
		UPDATE TRIP
		SET tickets_sold = tickets_sold + NEW.num_tickets
		WHERE trip_rec.trip_id = TRIP.trip_id;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_sell_tickets
BEFORE INSERT ON BOOKING
FOR EACH ROW
EXECUTE PROCEDURE update_tickets_sold();
