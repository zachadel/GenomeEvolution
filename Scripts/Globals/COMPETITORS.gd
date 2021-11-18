extends Node
#welcome to the global progeny variable. 
# Frankly, this is a means to an end.
# I couldn't really think of anything that would work as 
#ideally, so here we are

#The progeny_created variable is made to hold an array
#the variable isn't assigned anything until the ready function to 
#ensure that the array is empty at the beginning of every game. 
var competitors_created
var dead_competitors
# Called when the node enters the scene tree for the first time.
func _ready(): #sets up the array of progeny
	competitors_created = []
	competitors_created.clear()
	dead_competitors = []
	dead_competitors.clear()
	pass # Replace with function body.


#the child being passed in is the instance of the progeny that is on the world map
func kill_dead_competitors():
	for i in dead_competitors:
		print("i: " + str(i))
		if STATS.get_rounds() - i["round"] >= 2:
			i.position = null
			i["cell"].enable_sprite(false)
			i["cell"].visible = false
			#i.organism.current_tile = null
			dead_competitors.erase(i)

func add_dead_competitors(child):
	dead_competitors.append(child)

func add_competitors( child):
	competitors_created.append(child)
# the number of progeny should match that on the stats screen.

#what we have right here is a function that will run through each of
#the progeny in the array and move them. 
func move_competitor( distance ): 
	var index = randi() % 3; # I want to get a random value from the vector array
	var direction = randi() % 2;
	if direction == 1:
		distance = -distance
	
	

	for i in competitors_created:
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
	competitors_created.clear()
	dead_competitors.clear()
	print("competitors_created: " + str(competitors_created))
	print("dead_competitors: " + str(dead_competitors))
	pass
