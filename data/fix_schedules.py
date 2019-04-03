good_schedules = []
with open('good_schedules.dat', 'r') as sched_ids:
	for line in sched_ids:
		good_schedules.append( int( line.strip() ) )

line_number = 0 #will allow skipping table header

with open('stochastic_schedules.dat', 'r') as old_scheds:
	with open('schedules.dat', 'w+') as new_scheds:
		new_scheds.write('SCHEDULE\n')
		for line in old_scheds:
			if line_number in good_schedules:
				new_scheds.write(line)
			line_number += 1
