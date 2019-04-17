
CREATE INDEX schedule_routes_index on SCHEDULE(t_route);

CREATE INDEX rs_routes_index on ROUTE_STATIONS(route_id);
CREATE INDEX rs_stations_index on ROUTE_STATIONS(station_id);

CREATE INDEX trip_schedules_index on TRIP(sched_id);
