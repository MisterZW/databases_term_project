from random import randint
import random
from datetime import datetime, time

NUM_RAIL_LINES = 20
NUM_STATIONS = 100
NUM_TRAINS = 350
NUM_PASSENGERS = 300
NUM_SCHEDULES = 2000
NUM_ROUTES = 500
NUM_TRACKS = 500
NUM_AGENTS = 100

# build trains
with open('trains.dat', 'w+') as train_file:
	train_file.write('TRAIN\n')
	for i in range(NUM_TRAINS):
		train_ID = i
		top_speed = 60 + randint(0, 15) * 5
		seats = randint(150, 301)
		ppm = (randint(1, 10) / 4.0)
		train = (train_ID, top_speed, seats, ppm)
		train_file.write( str(train) + '\n' )

# build stations
with open('stations.dat', 'w+') as station_file:
	station_file.write('STATION\n')
	for i in range(NUM_STATIONS):
		station_id = i
		address = '123 Fake Street'
		city = 'Faketown'
		zip_code = '15217'
		open_hour_options = [5, 6, 7, 8, 9]
		close_hour_options = [20, 21, 22, 23]
		minute_options = [0, 15, 30, 45]
		o = time(random.choice(open_hour_options), random.choice(minute_options))
		c = time(random.choice(close_hour_options), random.choice(minute_options))
		o_time = o.strftime('%H:%M:%S')
		c_time = c.strftime('%H:%M:%S')
		station = (station_id, address, city, zip_code, o_time, c_time)
		station_file.write( str(station) + '\n' )

# build agents
with open('agents.dat', 'w+') as agent_file:
	agent_file.write('AGENT\n')
	for i in range(NUM_AGENTS):
		username = 'agent' + str(i)
		password = str(i)
		agent = (username, password)
		agent_file.write( str(agent) + '\n' )

# build passengers
with open('passenger.dat', 'w+') as passenger_file:
	passenger_file.write('PASSENGER\n')
	for i in range(NUM_PASSENGERS):
		cust_id = str(i)
		fname = 'pass_fname' + str(i)
		lname = 'pass_lname' + str(i)
		email = 'passenger' + str(i) + '@gmail.com'
		phone  = ''
		for i in range(10):
			phone += str( randint(0, 9) )
		address = '123 Fake Street'
		city = 'Faketown'
		zip_code = '15217'
		passenger = (cust_id, fname, lname, email, phone, address, city, zip_code)
		passenger_file.write( str(passenger) + '\n' )

# build rail lines
with open('rail_lines.dat', 'w+') as rail_file:
	rail_file.write('RAIL_LINE\n')
	for i in range(NUM_RAIL_LINES):
		rail_id = str(i)
		speed_limit = 50 + randint(0, 15) * 5
		rail = (rail_id, speed_limit)
		rail_file.write( str(rail) + '\n' )

# build routes
with open('routes.dat', 'w+') as route_file:
	route_file.write('TRAIN_ROUTE\n')
	for i in range(NUM_ROUTES):
		route_id = str(i)
		description = 'This is route ' + str(i)
		route = (route_id, description)
		route_file.write( str(route) + '\n' )

# build connections
# build as a simple grid layout
with open('connections.dat', 'w+') as conn_file:
	conn_file.write('CONNECTION\n')
	grid_width = (int)(NUM_RAIL_LINES / 2)
	fractions = [.1, .2, .3, .4, .5, .6, .7, .8, .9]
	for i in range(NUM_STATIONS):
		#connect right
		station1_id = i
		
		if (i+1) % grid_width == 0:
			continue  # don't connect @ far right of grid
		else:
			station2_id = i+1

		rail_id = (int)(i / grid_width)
		distance = randint(5, 1000)
		distance += random.choice(fractions)
		connection = (i, station1_id, station2_id, rail_id, distance)
		conn_file.write( str(connection) + '\n' )

	for i in range(NUM_STATIONS):
		#connect down
		conn_id = i + NUM_STATIONS
		station1_id = i

		if(i + grid_width >= NUM_STATIONS):
			continue  # don't connect @ bottom of grid
		else:
			station2_id = (i + grid_width)

		rail_id = (int)(i % grid_width) + grid_width
		distance = randint(5, 1000)
		distance += random.choice(fractions)
		connection = (conn_id, station1_id, station2_id, rail_id, distance)
		conn_file.write( str(connection) + '\n' )