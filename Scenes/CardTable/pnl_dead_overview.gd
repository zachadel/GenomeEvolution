extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var num_progeny = 0
var num_rounds = 0
var rank = ""
var curr_rep = 0;
var curr_sens = 0;
var curr_manip = 0
var curr_comp = 0;
var curr_const = 0; 
var curr_decon = 0;
var curr_help = 0;
var curr_locom = 0;
var death_reason = ""

func determine_death_reason():
	if(curr_rep == 0):
		death_reason = "Your Replication Genes Went Down to 0."
		$background/gene1/scoreBox.color = Color.red
	elif(curr_sens == 0):
		death_reason = "Your Sensing Genes Went Down to 0."
		$background/gene2/scoreBox.color = Color.red
	elif(curr_manip == 0):
		death_reason = "Your Manipulation Genes Went Down to 0."
		$background/gene3/scoreBox.color = Color.red
	elif(curr_comp == 0):
		death_reason = "Your Component Genes Went Down to 0."
		$background/gene4/scoreBox.color = Color.red
	elif(curr_const == 0):
		death_reason = "Your Construction Genes Went Down to 0."
		$background/gene5/scoreBox.color = Color.red
	elif(curr_decon == 0):
		death_reason = "Your Deconstruction Genes Went Down to 0."
		$background/gene6/scoreBox.color = Color.red
	elif(curr_help == 0):
		death_reason = "Your Helper Genes Went Down to 0."
		$background/gene7/scoreBox.color = Color.red
	elif(curr_locom == 0):
		death_reason = "Your Locomotion Genes Went Down to 0."
		$background/gene8/scoreBox.color = Color.red
	else:
		death_reason = "You ran out of energy!"
	$background/death_Reason.text=death_reason;
func determine_rank():
	if(num_rounds <= 5):
		rank = "survivor"
	elif(num_rounds <= 10):
		rank = "prey"
	elif(num_rounds >10):
		rank = "predator"

# Called when the node enters the scene tree for the first time.
func _ready():
	$background/gene1/scoreBox.color = Color.yellow
	$background/gene2/scoreBox.color = Color.yellow
	$background/gene3/scoreBox.color = Color.yellow
	$background/gene4/scoreBox.color = Color.yellow
	$background/gene5/scoreBox.color = Color.yellow
	$background/gene6/scoreBox.color = Color.yellow
	$background/gene7/scoreBox.color = Color.yellow
	$background/gene8/scoreBox.color = Color.yellow
	
	$background/gene1/scoreBox/Label.text = str(curr_rep)
	$background/gene2/scoreBox/Label.text = str(curr_sens)
	$background/gene3/scoreBox/Label.text = str(curr_manip)
	$background/gene4/scoreBox/Label.text = str(curr_comp)
	$background/gene5/scoreBox/Label.text = str(curr_const)
	$background/gene6/scoreBox/Label.text = str(curr_decon)
	$background/gene7/scoreBox/Label.text = str(curr_help)
	$background/gene8/scoreBox/Label.text = str(curr_locom)
	num_progeny= STATS.get_progeny()
	num_rounds = STATS.get_rounds()
	determine_death_reason()
	$background/progeny2.text = str(num_progeny)
	$background/rounds2.text = str(num_rounds)
	pass # Replace with function body.

func update_values():
	#setting values to update
	num_progeny= STATS.get_progeny()
	num_rounds = STATS.get_rounds()
	curr_rep = STATS.get_currentRep();
	curr_sens = STATS.get_currentSens();
	curr_manip = STATS.get_currentManip()
	curr_comp = STATS.get_currentComp();
	curr_const = STATS.get_currentCon(); 
	curr_decon = STATS.get_currentDeCon();
	curr_help = STATS.get_currentHelp();
	curr_locom = STATS.get_currentLoc();
	#Loading the gene values into the places
	$background/gene1/scoreBox/Label.text = str(curr_rep)
	$background/gene2/scoreBox/Label.text = str(curr_sens)
	$background/gene3/scoreBox/Label.text = str(curr_manip)
	$background/gene4/scoreBox/Label.text = str(curr_comp)
	$background/gene5/scoreBox/Label.text = str(curr_const)
	$background/gene6/scoreBox/Label.text = str(curr_decon)
	$background/gene7/scoreBox/Label.text = str(curr_help)
	$background/gene8/scoreBox/Label.text = str(curr_locom)
	
	$background/progeny2.text = str(num_progeny)
	$background/rounds2.text = str(num_rounds)
	determine_death_reason()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
