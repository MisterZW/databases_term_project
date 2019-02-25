\set ON_ERROR_STOP 1
begin;
	\i rail_line.sql
	\i train.sql
	\i station.sql
	\i train_route.sql
	\i connection.sql
	\i passenger.sql
	\i route_path.sql
	\i schedule.sql
	\i booking.sql
commit;