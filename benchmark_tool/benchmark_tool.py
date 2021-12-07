#import
from tkinter import *
from functionality import *
import numpy as np
import os, platform
from tkinter import filedialog as fd

#functions
def displayGrid(canvas, tiles):
	print('create new grid')
	display.delete('all')
	global plans
	global selected_robot_ID
	plans.clear()
	selected_robot_ID = 0

	n_rows, n_cols = tiles.shape

	#fill grid only into full screen size for maximum dimension of grid to maintain perfect squares
	global grid_size
	global margin
	global width
	grid_size = canvas_width/n_cols if n_rows < n_cols else canvas_height/n_rows
	grid_size -= 2*width
	margin = grid_size/10

	for col in range(n_cols):
		for row in range(n_rows):
			tag = '{},{},'.format(col,row)
			x0, y0, x1, y1 = col*grid_size+2*width,row*grid_size+2*width, (col+1)*grid_size+2*width,(row+1)*grid_size+2*width
			o = tiles[row][col][0]
			if o in ['n','r','s']:
				#Nodes
				canvas.create_rectangle(x0,y0,x1,y1, fill='#ccc', tags=tag+'n', width=width)
			if o == 'e':
				#Nodes
				canvas.create_rectangle(x0,y0,x1,y1, fill='#333', tags=tag+'e', width=width)
			if o == 'r':
				#Robots
				ID = int(tiles[row][col][1:])
				display.create_rectangle(x0+margin,y0+margin,x1-margin,y1-margin, fill = lerpColor('#d00','#ee0',float(ID)/5), tags=tag+'r', width=width)
				name = 'R({})'.format(ID)
				display.create_text(x0+grid_size/2,y0+grid_size/2, text=name, fill='#000', tags=tag+'r')
			if o == 's':
				#Shelves
				ID = int(tiles[row][col][1:])
				display.create_oval(x0+margin,y0+margin,x1-margin,y1-margin, fill = lerpColor('#d0d','#0fd',float(ID)/5), tags=tag, width=width)
				name = 'S({})'.format(ID)
				display.create_text(x0+grid_size/2,y0+grid_size/2, text=name, fill='#000', tags=tag)

def newGrid():
	global tiles
	tiles = newTiles(int(n_col_entry.get()),int(n_row_entry.get()),'n')
	displayGrid(display,tiles)

def clickOnGrid(event,add,select):
	if display.find_withtag(CURRENT):
		#display.itemconfig(CURRENT, fill=color)
		tag = display.gettags(CURRENT)[0]
		tag_components = tag.split(',')
		x = int(tag_components[0])
		y = int(tag_components[1])
		o = tag_components[2]
		cell = '{},{},'.format(x,y)

		global tiles
		global plans
		global grid_size
		global margin
		global selected_cell
		global selected_robot_ID
		x0, y0, x1, y1 = x*grid_size,y*grid_size, (x+1)*grid_size,(y+1)*grid_size

		#if robot is selected
		if select:
			if mode.get() == 'Plans' and tiles[y][x][0] == 'r':
				selected_robot_ID = int(tiles[y][x][1:])
				print('select R(%s)' % selected_robot_ID)
				#print('loading plan for R(%s)' % selected_robot_ID)
				unloadPlan(display)
				loadPlan(display,selected_robot_ID)
				display.itemconfig(cell+'n', fill='#dd0')
				global hint
				hint = Label(menu, text='IMPORTANT:\nStart the plan with T=1\nat the robots position!')
				hint.grid(row=1,column=3)
			else:
				unloadPlan(display)
				selected_robot_ID = 0
			return 0

		#is adding an object
		if add:
			if mode.get() == 'Nodes':
				#Nodes
				print('add node')
				tiles[y][x] = 'n'
				display.itemconfig(cell+'n', fill='#ccc')
			elif mode.get() in ['Robots', 'Shelves']:
				#Robots or Shelves
				selected_cell = cell
				global popup
				try:
					popup.destroy()
				except:
					pass
				open_popup()
			elif mode.get() == 'Plans':
				if selected_robot_ID == 0:
					print('You must first select a robot with middle mouse click.')
					global warning
					try:
						warning.destroy()
					except:
						pass
					open_warning()
					return 0
				#store plan tile in dict
				if not (selected_robot_ID in plans):
					plans[selected_robot_ID] = []
				if len(plans[selected_robot_ID]) != 0:
					if [x,y] in plans[selected_robot_ID]:
						return 0
				plans[selected_robot_ID].append([x,y])
				#add Plan Tile
				display.delete(cell+'p')
				display.create_rectangle(x0+margin,y0+margin,x1-margin,y1-margin, fill = lerpColor('#d88','#ee8',float(selected_robot_ID)/5), tags=cell+'p', width=width)
				text = 'T={}'.format(len(plans[selected_robot_ID])-1)
				display.create_text(x0+grid_size/2,y0+grid_size/2, text=text, fill='#000', tags=cell+'p')
				print('add plan node')
		else:
			if mode.get() == 'Plans':
				if o == 'p':
					#remove plan node from dict
					index = plans[selected_robot_ID].index([x,y])
					blacklist = plans[selected_robot_ID][index:]
					plans[selected_robot_ID] = plans[selected_robot_ID][:index]
					#remove plan tiles
					for b in blacklist:
						c = '{},{},'.format(b[0],b[1])
						display.delete(c+'p')
				return 0
			if o == 'n':
				#Nodes
				print('delete node')
				tiles[y][x] = 'e'
				deleteCell(display,cell)
				display.itemconfig(cell+'n', fill='#333')
			else:
				#Robots or Shelves
				print('delete object')
				tiles[y][x] = 'n'
				deleteCell(display,cell)

		#unload plans if other mode and clicked
		if mode.get() != 'Plans':
			unloadPlan(display)
			selected_robot_ID = 0
                
def clickAdd(event):
	clickOnGrid(event,True,False)

def clickRemove(event):
	clickOnGrid(event,False,False)

def clickSelectRobot(event):
	clickOnGrid(event,True,True)

def quit():
	master.destroy()

def choose_dir():
	output_dir = fd.askdirectory()
	print('Selected Directory: %s' % str(output_dir))
	return output_dir

def choose_file():
	return fd.askopenfilename()

def save_instance():
	global tiles
	saveInstance(tiles, choose_dir())

def save_plans():
	global plans
	savePlans(plans, choose_dir())

def save_all():
	output_dir = str(choose_dir())

	instance_dir = '%s/instance' % output_dir
	if not os.path.exists(instance_dir):
		os.makedirs(instance_dir)
	global tiles
	saveInstance(tiles, instance_dir)

	plans_dir = '%s/plans' % output_dir
	if not os.path.exists(plans_dir):
		os.makedirs(plans_dir)
	global plans
	savePlans(plans, plans_dir)

def open_instance():
	file_path = choose_file()
	global tiles
	tiles = loadInstance(file_path)
	displayGrid(display,tiles)

def load_plans():
	file_path = choose_file()
	global plans
	global tiles
	plans = loadPlans(file_path,tiles)

def open_benchmark():
	file_path = choose_file()
	global plans
	global tiles
	tiles = loadInstance(file_path)
	displayGrid(display,tiles)
	plans = loadPlans(file_path,tiles)

popup = 0
def open_popup():
	#pop up
	########################################
	def exit_popup(event=None):
		addObject(int(robot_id_entry.get()),mode.get())
		popup.destroy()
		
	global popup
	popup = Tk()
	popup.title('Object ID')
	popup.geometry('230x60')
	#popup.resizable(width=0, height=0)
	if platform.system() == 'Windows':
		popup.iconbitmap('icons/id.ico')

	text = 'Robot ID: ' if mode.get() == 'Robots' else 'Shelf ID: '
	robot_id_label = Label(popup, text=text)
	robot_id_entry = Entry(popup)
	robot_id_button = Button(popup, text='Confirm', command=exit_popup)
	robot_id_label.grid(row=0,column=0)
	robot_id_entry.grid(row=0,column=1)
	robot_id_button.grid(row=1,column=0)
	popup.bind("<Return>", exit_popup)
	########################################

hint = 0
warning = 0
def open_warning():
	#warning
	########################################
	global warning
	warning = Tk()
	warning.title('Warning')
	warning.geometry('400x50')
	warning_label = Label(warning,text='You must first select a robot with MMB or double RMB')
	#warning.resizable(width=0, height=0)
	if platform.system() == 'Windows':
		warning.iconbitmap('icons/warning.ico')
	warning_label.pack()
	########################################


def addObject(ID, m):
	global tiles
	global grid_size
	global margin
	global width
	global selected_cell
	cell_components = selected_cell.split(',')
	x = int(cell_components[0])
	y = int(cell_components[1])
	x0, y0, x1, y1 = x*grid_size+2*width,y*grid_size+2*width, (x+1)*grid_size+2*width,(y+1)*grid_size+2*width

	#cancel if ID is not unique
	if not IDisUnique(tiles,ID,m) or ID < 1:
		print('The ID has to be unique and greater than 0.')
		return 0
	#adding a robot
	if m == 'Robots':
		tiles[y][x] = 'r'+str(ID)
		deleteCell(display,selected_cell)
		display.create_rectangle(x0+margin,y0+margin,x1-margin,y1-margin, fill = lerpColor('#d00','#ee0',float(ID)/5), tags=selected_cell+'r', width=width)
		name = 'R({})'.format(ID)
		display.create_text(x0+grid_size/2,y0+grid_size/2, text=name, fill='#000', tags=selected_cell+'r')
		display.itemconfig(selected_cell+'n', fill='#ccc')
		print('added robot')
	#adding a shelf
	elif m == 'Shelves':
		tiles[y][x] = 's'+str(ID)
		deleteCell(display,selected_cell)
		display.create_oval(x0+margin,y0+margin,x1-margin,y1-margin, fill = lerpColor('#d0d','#0fd',float(ID)/5), tags=selected_cell, width=width)
		name = 'S({})'.format(ID)
		display.create_text(x0+grid_size/2,y0+grid_size/2, text=name, fill='#000', tags=selected_cell)
		display.itemconfig(selected_cell+'n', fill='#ccc')
		print('added shelf')
		
def deleteCell(canvas,cell):
	canvas.delete(cell)
	canvas.delete(cell+'r')
	canvas.delete(cell+'p')
	global tiles
	global plans
	cell_components = cell.split(',')
	x = int(cell_components[0])
	y = int(cell_components[1])
	if tiles[y][x][0] == 'r':
		ID = int(tiles[y][x][1:])
		remove_key = plans.pop(ID,None)
		if remove_key != None:
			print('key removed')
		else:
			print('key not removed')


def loadPlan(canvas,ID):
	global tiles
	global plans
	global grid_size
	global margin

	if ID in plans:
		for i, c in enumerate(plans[ID]):
			x, y = c[0], c[1]
			x0, y0, x1, y1 = x*grid_size,y*grid_size, (x+1)*grid_size,(y+1)*grid_size
			cell = '{},{},'.format(x,y)
			canvas.create_rectangle(x0+margin,y0+margin,x1-margin,y1-margin, fill = lerpColor('#d88','#ee8',float(selected_robot_ID)/5), tags=cell+'p', width=width)
			text = 'T={}'.format(i)
			canvas.create_text(x0+grid_size/2,y0+grid_size/2, text=text, fill='#000', tags=cell+'p')

def unloadPlan(canvas):
	global tiles
	for x in range(tiles.shape[1]):
		for y in range(tiles.shape[0]):
			tag = '{},{},'.format(x,y)
			canvas.delete(tag+'p')
			if tiles[y][x][0] in ['r','n']:
				canvas.itemconfig(tag+'n', fill='#ccc')
	global hint
	try:
		hint.destroy()
	except:
		pass


#program
#configuration

#main window
master = Tk()
master.title('Benchmark Tool')
width = 520
height = 550
if platform.system() == 'Darwin':
    master.geometry('%dx%d' % (700,height))
else:
    master.geometry('%dx%d' % (width,height))
#master.resizable(width=0, height=0)
if platform.system() == 'Windows':
	master.iconbitmap('icons/present.ico')

#frame
menu = Frame(master, width=width/2, height=height/2)#, bg='#ddd')
menu.pack(side=TOP)

canvas_width = width#*0.8
canvas_height = height*0.8

#canvas
display = Canvas(master, width=canvas_width, height=canvas_height)
display.pack(side=BOTTOM)
#bind an event when you click on the grid
display.bind("<Button-1>", clickAdd)
if platform.system() == 'Darwin':
	display.bind("<Double-Button-2>", clickSelectRobot)
	display.bind("<Button-2>", clickRemove)
	display.bind("<Button-3>", clickSelectRobot)
else:
	display.bind("<Button-2>", clickSelectRobot)
	display.bind("<Button-3>", clickRemove)
	display.bind("<Double-Button-3>", clickSelectRobot)

n_col_label = Label(menu, text='Width: ')
n_row_label = Label(menu, text='Height: ')
n_row_entry = Entry(menu)
n_row_entry.insert(0, "3")
n_col_entry = Entry(menu)
n_col_entry.insert(0, "4")
create_button = Button(menu, text='Create', command=newGrid)

n_row_label.grid(row=0, column=2, sticky=E, padx=5, pady=5)
n_col_label.grid(row=0, column=0, sticky=E, padx=5, pady=5)
n_row_entry.grid(row=0, column=3, sticky=W, padx=5, pady=5)
n_col_entry.grid(row=0, column=1, sticky=W, padx=5, pady=5)
create_button.grid(row=0, column=4)

#dropdown menu
OptionList = [
'Nodes',
'Robots',
'Shelves',
'Plans'
]

mode = StringVar(menu)
mode.set(OptionList[0])

mode_options = OptionMenu(menu, mode, *OptionList)
if platform.system() == 'Darwin':
    info = Label(menu, text='LMB to add\nRMB to remove\nMMB or double RMB to select')
else:
    info = Label(menu, text='LMB to add\nRMB to remove\nMMB to select')
mode_options.grid(row=1,column=0)
info.grid(row=1, column=1)

#menubar
menubar = Menu(master)
filemenu = Menu(menubar)
#filemenu.add_command(label="Open Full Benchmark", command=open_benchmark)
filemenu.add_command(label="Open Instance", command=open_instance)
filemenu.add_command(label="Load Plans", command=load_plans)
filemenu.add_command(label="Save All", command=save_all)
filemenu.add_command(label="Save Instance", command=save_instance)
filemenu.add_command(label="Save Plans", command=save_plans)
filemenu.add_command(label="Exit", command=quit)

menubar.add_cascade(label="File", menu=filemenu)
master.config(menu=menubar)

#start
#global variables
tiles = []
plans = {}
grid_size = 0
margin = 0
width = 2
selected_cell = ''
selected_robot_ID = 0

newGrid()


mainloop()