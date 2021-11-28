import numpy as np
import random

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
	writeFile(path,output)


def loadInstance():
	print('loading instance...')


def savePlans(plans,dir):
	print('saving plans...')
	output = ''
	#read plans
	for ID in plans.keys():
		plan = ''
		for t in range(1,len(plans[ID])):
			prev_pos = plans[ID][t-1]
			pos = plans[ID][t]
			#calculate direction
			dx, dy = pos[0]-prev_pos[0], pos[1]-prev_pos[1]
			#occurs_(object(robot,1),action(move,(0,1)),1).
			plan += 'occurs(object(robot,{}),action(move,({},{})),{}).\n'.format(ID,dx,dy,t)
		#saving
		path = dir+'/'+'plan_r'+str(ID)+'.lp'
		writeFile(path,plan)
		output += plan+'\n'

	#saving
	path = dir+'/'+'full_plan.lp'
	writeFile(path,output)

def writeFile(path,content):
	f = open(path, "w")
	f.write(content)
	f.close()
	print('Successfully saved into: '+path)


def count(tiles,o):
	counter = 0
	for x in range(tiles.shape[0]):
		for y in range(tiles.shape[1]):
			if tiles[x][y][0] in o:
				counter += 1
	return counter

def IDisUnique(tiles, ID, mode):
	m = ''
	if mode == 'Robots':
		m = 'r'
	elif mode == 'Shelves':
		m = 's'

	for x in range(tiles.shape[0]):
		for y in range(tiles.shape[1]):
			if tiles[x][y][0] == m:
				other_ID = tiles[x][y][1:]
				other_ID = 0 if other_ID == '' else int(other_ID)
				if int(other_ID) == ID:
					return False
	return True

def newTiles(n_cols, n_rows):
	tiles = np.ones(shape=(n_rows,n_cols)).astype(str)
	#print(tiles)
	for x in range(n_rows):
		for y in range(n_cols):
			tiles[x][y] = 'n'
	return tiles

def lerpColor(col1,col2,val):
	val = val - int(val)
	r1,g1,b1 = hex2dec(col1[1]),hex2dec(col1[2]),hex2dec(col1[3])
	r2,g2,b2 = hex2dec(col2[1]),hex2dec(col2[2]),hex2dec(col2[3])
	r3,g3,b3 = (1-val)*r1+val*r2, (1-val)*g1+val*g2, (1-val)*b1+val*b2
	return '#'+dec2hex(int(r3))+dec2hex(int(g3))+dec2hex(int(b3))

def hex2dec(val):
	try:
		if int(val) <= 9:
			return int(val)
	except:
		if val == 'a':
			return 10
		elif val == 'b':
			return 11
		elif val == 'c':
			return 12
		elif val == 'd':
			return 13
		elif val == 'e':
			return 14
		elif val == 'f':
			return 15

def dec2hex(val):
	if val <= 9:
		return str(val)
	if val == 10:
		return 'a'
	elif val == 11:
		return 'b'
	elif val == 12:
		return 'c'
	elif val == 13:
		return 'd'
	elif val == 14:
		return 'e'
	elif val == 15:
		return 'f'

def randomFloat(low, high):
	return random.random()*(high-low) + low
