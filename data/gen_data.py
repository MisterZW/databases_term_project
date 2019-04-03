from random import randint
import random
from datetime import datetime, time, date, timedelta

NUM_RAIL_LINES = 40
NUM_STATIONS = 400
NUM_TRAINS = 350
NUM_PASSENGERS = 300
NUM_ROUTES = 500
NUM_TRACKS = 500
NUM_AGENTS = 100

CANDIDATE_SCHEDULES = 5000
TARGET_SCHEDULES = 2000

#dict tracks which connection connects a 2-station tuple
connection_map = {}

# build trains
with open('trains.dat', 'w+') as train_file:
	train_file.write('TRAIN\n')
	for i in range(NUM_TRAINS):
		top_speed = 80 + randint(0, 20) * 5
		seats = randint(150, 301)
		ppm = (randint(1, 10) / 40.0)
		train = (top_speed, seats, ppm)
		train_file.write( str(train) + '\n' )

# build stations
with open('stations.dat', 'w+') as station_file:
	station_file.write('STATION\n')
	for i in range(NUM_STATIONS):
		address = str(i) + ' Fake Street'
		city = 'Faketown'
		zip_code = '15217'
		open_hour_options = [2, 3, 4, 5, 6]
		close_hour_options = [21, 22, 23]
		minute_options = [0, 15, 30, 45]
		o = time(random.choice(open_hour_options), random.choice(minute_options))
		c = time(random.choice(close_hour_options), random.choice(minute_options))
		o_time = o.strftime('%H:%M:%S')
		c_time = c.strftime('%H:%M:%S')
		station = (address, city, zip_code, o_time, c_time)
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
		fname = 'pass_fname' + str(i)
		lname = 'pass_lname' + str(i)
		email = 'passenger' + str(i) + '@gmail.com'
		phone  = ''
		for i in range(10):
			phone += str( randint(0, 9) )
		address = str (i) + ' Fake Avenue'
		city = 'Faketown'
		zip_code = '15217'
		passenger = (fname, lname, email, phone, address, city, zip_code)
		passenger_file.write( str(passenger) + '\n' )

# build rail lines
with open('rail_lines.dat', 'w+') as rail_file:
	rail_file.write('RAIL_LINE\n')
	for i in range(NUM_RAIL_LINES):
		speed_limit = 70 + randint(0, 20) * 5
		rail = (speed_limit)
		rail_file.write( "(" + str(rail) + ')\n' )

# build routes
with open('routes.dat', 'w+') as route_file:
	route_file.write('TRAIN_ROUTE\n')
	for i in range(NUM_ROUTES):
		description = 'This is route ' + str(i)
		route = (description)
		route_file.write( '(\'' + str(route) + "\')\n" )

# build connections
# build as a simple grid layout
with open('connections.dat', 'w+') as conn_file:
	conn_id = 1
	conn_file.write('CONNECTION\n')
	grid_width = (int)(NUM_RAIL_LINES / 2)
	fractions = [.1, .2, .3, .4, .5, .6, .7, .8, .9]
	for i in range(1, NUM_STATIONS):
		#connect right
		station1_id = i
		
		if (i) % grid_width == 0:
			continue  # don't connect @ far right of grid
		else:
			station2_id = i+1

		rail_id = (int)(i / grid_width) + 1
		distance = randint(1, 40)
		distance += random.choice(fractions)
		connection = (station1_id, station2_id, rail_id, distance)

		# store directed for simplicity
		connection_map[ (station1_id, station2_id) ] = conn_id 
		connection_map[ (station2_id, station1_id) ] = conn_id

		conn_file.write( str(connection) + '\n' )
		conn_id += 1

	for i in range(1, NUM_STATIONS):
		#connect down
		station1_id = i

		if(i + grid_width > NUM_STATIONS):
			continue  # don't connect @ bottom of grid
		else:
			station2_id = (i + grid_width)

		rail_id = (int)(i % grid_width) + grid_width + 1
		distance = randint(1, 40)
		distance += random.choice(fractions)
		connection = (station1_id, station2_id, rail_id, distance)

		# store directed for simplicity
		connection_map[ (station1_id, station2_id) ] = conn_id
		connection_map[ (station2_id, station1_id) ] = conn_id

		conn_file.write( str(connection) + '\n' )

		conn_id += 1
	

# build route_stations
with open('route_stations.dat', 'w+') as rs_file:
	rs_file.write('ROUTE_STATIONS\n')
	grid_width = (int)(NUM_RAIL_LINES / 2)

	prev_station = None

	# build horizontal routes
	for i in range(0, NUM_STATIONS):
		station_id = i + 1
		route_id = (int)(i / grid_width) + 1
		ordinal = (int)(i % grid_width) + 1

		if ordinal == 1 or ordinal == grid_width:
			stops_here = True
		elif randint(0,1) == 0:
			stops_here = False
		else:
			stops_here = True

		if ordinal == 1:
			conn_id = 'null'
		else:
			conn_id = connection_map[ (prev_station, station_id) ]

		rs_file.write( '(' + str(ordinal) + ', ' + str(stops_here) + ', ' + str(station_id) + 
			', ' + str(route_id) + ', ' +  str(conn_id) + ')\n' )

		prev_station = station_id

	# build vertical routes
	for i in range(0, NUM_STATIONS):
		station_id = i + 1
		prev_station = station_id - grid_width
		route_id = (int)(i % grid_width) + grid_width + 1
		ordinal = (int)(i / grid_width) + 1

		if ordinal == 1 or ordinal == grid_width:
			stops_here = True
		elif randint(0,1) == 0:
			stops_here = False
		else:
			stops_here = True

		if ordinal == 1:
			conn_id = 'null'
		else:
			conn_id = connection_map[ (prev_station, station_id) ]

		rs_file.write( '(' + str(ordinal) + ', ' + str(stops_here) + ', ' + str(station_id) + 
			', ' + str(route_id) + ', ' +  str(conn_id) + ')\n' )


	stations_used = []

	for x in range(NUM_RAIL_LINES, NUM_ROUTES):
		route_id = x
		station_id = randint(1, NUM_STATIONS)
		stops_here = True
		ordinal = 1
		conn_id = 'null'
		while(True):
			rs_file.write( '(' + str(ordinal) + ', ' + str(stops_here) + ', ' + str(station_id) + 
			', ' + str(route_id) + ', ' +  str(conn_id) + ')\n' )

			stations_used.append(station_id)
			
			ordinal += 1
			if ordinal == 4:
				stations_used = []
				break

			if ordinal == 3 or randint(0,1) == 0:
				stops_here = True
			else:
				stops_here = False

			seeking = True
			while(seeking):
				next_station = randint(0, 3)
				if next_station == 0 and (station_id-grid_width) not in stations_used: #case up
					conn_id = connection_map.get((station_id, station_id-grid_width))
					if conn_id == None:
						continue
					station_id -= grid_width
					seeking = False
				elif next_station == 1 and (station_id-1) not in stations_used: #case left
					conn_id = connection_map.get((station_id, station_id-1))
					if conn_id == None:
						continue
					station_id -= 1
					seeking = False		
				elif next_station == 2 and (station_id+1) not in stations_used: #case right
					conn_id = connection_map.get((station_id, station_id+1))
					if conn_id == None:
						continue
					station_id += 1
					seeking = False
				elif next_station == 3 and (station_id+grid_width) not in stations_used: #case down
					conn_id = connection_map.get((station_id, station_id+grid_width))
					if conn_id == None:
						continue
					station_id += grid_width
					seeking = False
			

"""
# build schedules
with open('schedules.dat', 'w+') as sched_file:
	sched_file.write('SCHEDULE\n')

	for day in range(1, 7):
		sched_time = time(hour = randint(8, 10))

		for rail in range(1, NUM_RAIL_LINES):
			train_route = rail
			train_id = rail
			if randint(0, 1) == 0:
				is_forward = True
			else:
				is_forward = False
			sched = (day, str(sched_time), train_route, train_id, is_forward)
			sched_file.write( str(sched) + '\n' )
			sched_id += 1
"""

# throw schedules at the system and see what sticks
with open('stochastic_schedules.dat', 'w+') as kitchen_sink_file:
	kitchen_sink_file.write('SCHEDULE\n')

	train_id = 1

	for sched_no in range(1, CANDIDATE_SCHEDULES):
		sched_time = time(hour = randint(2, 20))
		train_route = randint(1, NUM_ROUTES)
		day = randint(1, 7)
		if randint(0, 1) == 0:
			is_forward = True
		else:
			is_forward = False

		sched = (day, str(sched_time), train_route, train_id, is_forward)
		kitchen_sink_file.write( str(sched) + '\n' )

		train_id = (train_id + 1) % (NUM_TRAINS + 1)



# build bookings
with open('bookings.dat', 'w+') as book_file:
	book_file.write('BOOKING\n')
	for sched_id in range(TARGET_SCHEDULES):
		for i in range(5):
			passenger_id = randint(1, NUM_PASSENGERS)
			agent_username = 'agent' + str(randint(0, NUM_AGENTS-1))
			num_tickets = randint(1, 10)

			booking = (agent_username, passenger_id, sched_id, num_tickets)
			book_file.write( str(booking) + '\n' )
		
