extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var num_progeny = 0
var num_rounds = 0
var rank = ""

func determine_rank():
	if(num_rounds <= 5):
		rank = "survivor"
	elif(num_rounds <= 10):
		rank = "prey"
	elif(num_rounds >10):
		rank = "predator"

# Called when the node enters the scene tree for the first time.
func _ready():
	num_progeny= STATS.get_progeny()
	num_rounds = STATS.get_rounds()
	$background/progeny2.text = str(num_progeny)
	$background/rounds2.text = str(num_rounds)
	determine_rank()
	$background/Rank2.text = rank
	pass # Replace with function body.

func update_values():
	num_progeny= STATS.get_progeny()
	num_rounds = STATS.get_rounds()
	$background/progeny2.text = str(num_progeny)
	$background/rounds2.text = str(num_rounds)
	determine_rank()
	$background/Rank2.text = rank
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
