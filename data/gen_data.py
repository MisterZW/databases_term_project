from random import randint

# build trains
with open('trains.dat', 'w+') as train_file:
	train_file.write('TRAIN\n')
	for i in range(300):
		train_ID = i
		seats = randint(150, 301)
		ppm = (randint(1, 10) / 4.0)
		top_speed = 60 + randint(0, 15) * 5
		train = (train_ID, seats, ppm, top_speed)
		train_file.write( str(train) + '\n' )
