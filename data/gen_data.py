from random import randint
import random
from datetime import datetime, time

NUM_RAIL_LINES = 5
NUM_STATIONS = 50
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
		seats = randint(150, 301)
		ppm = (randint(1, 10) / 4.0)
		top_speed = 60 + randint(0, 15) * 5
		train = (train_ID, seats, ppm, top_speed)
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
