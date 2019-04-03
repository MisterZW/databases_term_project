from random import randint
import random

NUM_AGENTS = 100
NUM_PASSENGERS = 300

good_schedules = []
with open('good_schedules.dat', 'r') as sched_ids:
	for line in sched_ids:
		good_schedules.append( int( line.strip() ) )


# build bookings
with open('bookings.dat', 'w+') as book_file:
	book_file.write('BOOKING\n')
	for sched_id in good_schedules:
		for i in range(5):
			passenger_id = randint(1, NUM_PASSENGERS)
			agent_username = 'agent' + str(randint(0, NUM_AGENTS-1))
			num_tickets = randint(1, 10)

			booking = (agent_username, passenger_id, sched_id, num_tickets)
			book_file.write( str(booking) + '\n' )