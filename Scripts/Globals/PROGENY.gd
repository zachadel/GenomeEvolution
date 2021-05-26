extends Node
#welcome to the global progeny variable. 
# Frankly, this is a means to an end.
# I couldn't really think of anything that would work as 
#ideally, so here we are

#The progeny_created variable is made to hold an array
#the variable isn't assigned anything until the ready function to 
#ensure that the array is empty at the beginning of every game. 
var progeny_created
var dead_progeny
# Called when the node enters the scene tree for the first time.
func _ready(): #sets up the array of progeny
	progeny_created = []
	progeny_created.clear()
	dead_progeny = []
	dead_progeny.clear()
	pass # Replace with function body.


#the child being passed in is the instance of the progeny that is on the world map
func kill_dead_progeny():
	for i in dead_progeny:
		print("i: " + str(i))
		if STATS.get_rounds() - i["round"] >= 2:
			i.position = null
			i["cell"].enable_sprite(false)
			i["cell"].visible = false
			#i.organism.current_tile = null
			dead_progeny.erase(i)

func add_dead_progeny(child):
	dead_progeny.append(child)

func add_progeny( child):
	progeny_created.append(child)
# the number of progeny should match that on the stats screen.

#what we have right here is a function that will run through each of
#the progeny in the array and move them. 
func move_progeny( distance ): 
	var index = randi() % 3; # I want to get a random value from the vector array
	var direction = randi() % 2;
	if direction == 1:
		distance = -distance
	
	

	for i in progeny_created:
		var player_pos = Game.world_to_map(i.position)
		#var curr_tile = get_tile_at_pos(player_pos)
#		i.set_current_tile()
#		if index == 0:
#			i.organism.current_tile.x += distance
#		elif index == 1:
#			i.organism.current_tile.y += distance
#		else: 
#			i.organism.current_tile.z += distance
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func new_game():
	progeny_created.clear()
	dead_progeny.clear()
	print("progeny_created: " + str(progeny_created))
	print("dead_progeny: " + str(dead_progeny))
	pass
