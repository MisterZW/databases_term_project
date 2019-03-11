from random import randint

NUM_RAIL_LINES = 5
NUM_STATIONS = 50
NUM_TRAINS = 350
NUM_PASSENGERS = 300
NUM_SCHEDULES = 2000
NUM_ROUTES = 500
NUM_TRACKS = 500

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
