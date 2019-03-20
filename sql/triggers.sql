DROP FUNCTION IF EXISTS update_tickets_sold() CASCADE;

CREATE FUNCTION update_tickets_sold() 
RETURNS TRIGGER
AS $$
DECLARE
	sched RECORD;
	train RECORD;
BEGIN
	SELECT * FROM SCHEDULE as s WHERE NEW.schedule = s.sched_ID INTO sched;
	SELECT * FROM TRAIN as t WHERE sched.train = t.train_ID INTO train;
	IF sched.tickets_sold + NEW.num_tickets > train.seats
	THEN
		RETURN NULL;
	ELSE
		UPDATE SCHEDULE
		SET tickets_sold = tickets_sold + NEW.num_tickets
		WHERE NEW.schedule = sched_ID;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_sell_tickets
BEFORE INSERT ON BOOKING
FOR EACH ROW
EXECUTE PROCEDURE update_tickets_sold();
