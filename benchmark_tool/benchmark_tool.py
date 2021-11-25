#import
from tkinter import *
from functionality import *
import numpy as np

#functions
def displayGrid(canvas, tiles):
	n_rows, n_cols = tiles.shape

	#fill grid only into full screen size for maximum dimension of grid to maintain perfect squares
	global grid_size
	global margin
	grid_size = canvas_width/n_cols if n_rows < n_cols else canvas_height/n_rows
	margin = grid_size/10

	for col in range(n_cols):
		for row in range(n_rows):
			tag = '{},{},'.format(col,row)
			x0, y0, x1, y1 = col*grid_size,row*grid_size, (col+1)*grid_size,(row+1)*grid_size
			#Nodes
			canvas.create_rectangle(x0,y0,x1,y1, fill='#ccc', tags=tag+'n')
			#Shelves
			#canvas.create_oval(x0+margin,y0+margin,x1-margin,y1-margin, fill='#800', tags=tag)
			#Labels
			#canvas.create_text(x0+grid_size/2,y0+grid_size/2, text="R(1)", fill='#000', tags=tag)
			#Robots
			#canvas.create_rectangle(x0+margin,y0+margin,x1-margin,y1-margin, fill = '#808', tags=tag)

def newGrid():
	display.delete('all')
	global tiles
	tiles = newTiles(int(n_col_entry.get()),int(n_row_entry.get()))
	displayGrid(display,tiles)

def clickOnGrid(event,add):
	if display.find_withtag(CURRENT):
		#display.itemconfig(CURRENT, fill=color)
		tag = display.gettags(CURRENT)[0]
		tag_components = tag.split(',')
		x = int(tag_components[0])
		y = int(tag_components[1])
		o = tag_components[2]
		cell = '{},{},'.format(x,y)

		global tiles
		global grid_size
		global margin
		global selected_cell
		x0, y0, x1, y1 = x*grid_size,y*grid_size, (x+1)*grid_size,(y+1)*grid_size
		#is adding an object
		if add:
			if mode.get() == 'Nodes':
				#Nodes
				print('add node')
				tiles[y][x] = 'n'
				display.itemconfig(cell+'n', fill='#ccc')
			elif mode.get() in ['Robots', 'Shelves']:
				#Robots
				selected_cell = cell
				global popup
				try:
					popup.destroy()
				except:
					print('error')
				open_popup()
		else:
			if o == 'n':
				#Nodes
				print('delete node')
				tiles[y][x] = 'e'
				display.delete(cell)
				display.itemconfig(cell+'n', fill='#333')
			else:
				#Robots and Shelves
				print('delete object')
				tiles[y][x] = 'n'
				display.delete(cell)
		#print(tiles)
                
def clickAdd(event):
	clickOnGrid(event,True)

def clickRemove(event):
	clickOnGrid(event,False)

def quit():
	master.destroy()

def save_instance():
	global tiles
	saveInstance(tiles, 'output')

popup = 0
def open_popup():
	#pop up
	########################################
	def exit_popup():
		addObject(int(robot_id_entry.get()),mode.get())
		popup.destroy()
		
	global popup
	popup = Tk()
	popup.title('ID')
	popup.geometry('200x100')
	robot_id_label = Label(popup, text='Object ID: ')
	robot_id_entry = Entry(popup)
	robot_id_button = Button(popup, text='Confirm', command=exit_popup)
	robot_id_label.grid(row=0,column=0)
	robot_id_entry.grid(row=0,column=1)
	robot_id_button.grid(row=1,column=0)
	########################################

def addObject(ID, m):
	global tiles
	global grid_size
	global margin
	global selected_cell
	cell_components = selected_cell.split(',')
	x = int(cell_components[0])
	y = int(cell_components[1])
	x0, y0, x1, y1 = x*grid_size,y*grid_size, (x+1)*grid_size,(y+1)*grid_size
	if m == 'Robots':
		print('add robot')
		tiles[y][x] = 'r'+str(ID)
		display.delete(selected_cell)
		display.create_rectangle(x0+margin,y0+margin,x1-margin,y1-margin, fill = '#808', tags=selected_cell)
		name = 'R({})'.format(ID)
		display.create_text(x0+grid_size/2,y0+grid_size/2, text=name, fill='#000', tags=selected_cell)
		display.itemconfig(selected_cell+'n', fill='#ccc')
	elif m == 'Shelves':
		#Shelves
		tiles[y][x] = 's'+str(ID)
		display.delete(selected_cell)
		display.create_oval(x0+margin,y0+margin,x1-margin,y1-margin, fill='#800', tags=selected_cell)
		name = 'S({})'.format(ID)
		display.create_text(x0+grid_size/2,y0+grid_size/2, text=name, fill='#000', tags=selected_cell)
		display.itemconfig(selected_cell+'n', fill='#ccc')
		
	

#program
#configuration

#main window
master = Tk()
master.title('Benchmark Tool')
width = 500
height = 400
master.geometry('%dx%d' % (width,height))

#frame
menu = Frame(master, width=width/2, height=height/2, bg='#ccc')
menu.pack(side=TOP)

canvas_width = width=width*0.8
canvas_height = height=height*0.8

#canvas
display = Canvas(master, width=canvas_width, height=canvas_height)
display.pack(side=BOTTOM)
#bind an event when you click on the grid
display.bind("<Button-1>", clickAdd)
display.bind("<Button-3>", clickRemove)

n_col_label = Label(menu, text='Width: ')
n_row_label = Label(menu, text='Height: ')
n_row_entry = Entry(menu)
n_row_entry.insert(0, "3")
n_col_entry = Entry(menu)
n_col_entry.insert(0, "3")
create_button = Button(menu, text='Create', command=newGrid)
quit_button = Button(menu, text='QUIT', command=quit)

n_row_label.grid(row=0, column=2)
n_col_label.grid(row=0, column=0)
n_row_entry.grid(row=0, column=3)
n_col_entry.grid(row=0, column=1)
create_button.grid(row=0, column=4)
quit_button.grid(row=0, column=5)

#dropdown menu
OptionList = [
"Nodes",
"Robots",
"Shelves"
]

mode = StringVar(menu)
mode.set(OptionList[0])

mode_options = OptionMenu(menu, mode, *OptionList)
info = Label(menu, text='LEFT MOUSE CLICK to add\nRIGHT MOUSE CLICK to remove')
mode_options.grid(row=1,column=0)
info.grid(row=1, column=1)

#menubar
menubar = Menu(master)
filemenu = Menu(menubar)
filemenu.add_command(label="Open", command=loadInstance)
filemenu.add_command(label="Save", command=save_instance)
filemenu.add_command(label="Exit", command=quit)

menubar.add_cascade(label="File", menu=filemenu)
master.config(menu=menubar)

#start
#global variables
tiles = []
grid_size = 0
margin = 0
selected_cell = ''
current_id = 0

newGrid()


mainloop()