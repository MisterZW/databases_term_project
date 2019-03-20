filenames = ['trains.dat', 'stations.dat', 'agents.dat']

output = open('../sql/mock_data.sql', 'w+')

for filename in filenames:
	with open(filename, 'r') as file:
		table_name = file.readline().strip()
		for line in file:
			output.write('INSERT INTO ' + table_name + ' VALUES' + line.strip() + ';\n')