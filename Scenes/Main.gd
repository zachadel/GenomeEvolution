extends Node

export (PackedScene) var Gene

var game_over = false

func _ready():
	pass

func new_game():
	game_over = false
	$Chromosome.start()

func _process(delta):
	pass
	#while(!game_over):
	#	turn_sequence()
	#	scoring()
		
func scoring():
	pass
	
func turn_sequence():
	gain_transposons()
	transposon_jumping()
	
func gain_transposons():
	pass
	
func transposon_jumping():
	pass
	

