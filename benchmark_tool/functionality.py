import numpy as np

def saveInstance(tiles,dir):
	x_size = tiles.shape[1]
	y_size = tiles.shape[0]
	n_nodes = count(tiles,['n','r','s'])
	n_robots = count(tiles,['r'])
	n_shelves = count(tiles,['s'])
	n_products = n_shelves
	n_pruduct_units = n_products
	n_orders = n_products

	#header
	output = ''
	output += '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n'
	output += '% Grid Size X:                      {}\n'.format(x_size)
	output += '% Grid Size Y:                      {}\n'.format(y_size)
	output += '% Number of Nodes:                  {}\n'.format(n_nodes)
	output += '% Number of Highway Nodes:          {}\n'.format(0)
	output += '% Number of Robots:                 {}\n'.format(n_robots)
	output += '% Number of Shelves:                {}\n'.format(n_shelves)
	output += '% Number of Picking Stations:       {}\n'.format(0)
	output += '% Number of Products:               {}\n'.format(n_products)
	output += '% Number of Product Units in Total: {}\n'.format(n_pruduct_units)
	output += '% Number of Orders:                 {}\n'.format(n_orders)
	output += '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n'
	output += '\n'
	output += '#program base.\n'
	output += '\n'
	output += '% init\n'

	robots = []
	shelves = []

	#nodes
	output += '\n% nodes\n'
	node_counter = 1
	for x in range(tiles.shape[0]):
		for y in range(tiles.shape[1]):
			if tiles[x][y][0] in ['n','r','s']:
				output += 'init(object(node,{}),value(at,({},{}))).\n'.format(node_counter,y+1,x+1)
				node_counter += 1
				if tiles[x][y][0] == 'r':
					robots.append([int(tiles[x][y][1:]),y+1,x+1])
				if tiles[x][y][0] == 's':
					shelves.append([int(tiles[x][y][1:]),y+1,x+1])

	#robots
	output += '\n% robots\n'
	for robot in robots:
		output += 'init(object(robot,{}),value(at,({},{}))).\n'.format(robot[0],robot[1],robot[2])

	#shelves
	output += '\n% shelves\n'
	for shelf in shelves:
		output += 'init(object(shelf,{}),value(at,({},{}))).\n'.format(shelf[0],shelf[1],shelf[2])

	#products
	output += '\n% products\n'
	for i in range(len(shelves)):
		output += 'init(object(product,{}),value(on,({},{}))).\n'.format(i+1,i+1,1)

	#orders
	output += '\n% orders\n'
	for i in range(len(shelves)):
		output += 'init(object(order,{}),value(line,({},{}))).\n'.format(i+1,i+1,1)

	#saving
	print('saving instance...')
	name = 'x{}_y{}_n{}_r{}_s{}_ps{}_pr{}_u{}_o{}_N001'.format(x_size,y_size,n_nodes,n_robots,n_shelves,0,n_products,n_pruduct_units,n_orders)
	path = dir+'/'+name+'.lp'
	f = open(path, "w")
	f.write(output)
	f.close()
	print('Successfully saved into: '+path)


def loadInstance():
	print('loading instance...')

def count(tiles,o):
	counter = 0
	for x in range(tiles.shape[0]):
		for y in range(tiles.shape[1]):
			if tiles[x][y][0] in o:
				counter += 1
	return counter

def newTiles(n_cols, n_rows):
	tiles = np.ones(shape=(n_rows,n_cols)).astype(str)
	print('hello')
	print(tiles)
	for x in range(n_rows):
		for y in range(n_cols):
			tiles[x][y] = 'n'
	return tiles