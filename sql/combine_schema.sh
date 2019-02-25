#!/bin/bash

cat rail_line.sql > schema.sql
cat train.sql >> schema.sql
cat station.sql >> schema.sql
cat train_route.sql >> schema.sql
cat connection.sql >> schema.sql
cat passenger.sql >> schema.sql
cat route_path.sql >> schema.sql
cat schedule.sql >> schema.sql
cat booking.sql >> schema.sql