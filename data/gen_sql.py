# Builds one .sql file called mock_data.sql from all component .dat files

# Generates all the necessary insert statements and commits each .dat file's data
# one transaction at a time with all constraints deferred (needed for trips to play
# nice with schedules)

filenames = ['trains.dat', 'stations.dat', 'agents.dat', 'passenger.dat', 'rail_lines.dat',
	'routes.dat', 'connections.dat', 'route_stations.dat', 'schedules.dat', 'bookings.dat']

output = open('../sql/mock_data.sql', 'w+')

for filename in filenames:
	with open(filename, 'r') as file:
		output.write('START TRANSACTION; SET CONSTRAINTS ALL DEFERRED;\n')
		table_name = file.readline().strip()
		for line in file:
			output.write('INSERT INTO ' + table_name + ' VALUES' + line.strip() + ';\n')

		output.write('COMMIT;\n')