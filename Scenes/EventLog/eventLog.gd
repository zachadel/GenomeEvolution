extends Panel

var current_eat = "You have eaten 0 resources";
var current_move = "You have gone 0 tiles";
var current_breaks = "\n Round 0: ";
var current_bandage = "\n Round 0: \n";
var current_round_break = 0;
var current_round_bandage = 0;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
	 # Replace with function body.
# What is outputted where is all dependent on the title of the signal that is coming in
func addContent(title, text): 
	#print("current_round break: "+str(current_round_break))
	#print("current_round_bandage: "+str(current_round_bandage))
	var new_round = STATS.get_rounds()
	#print("new round: "+str(new_round))
	current_eat = "\n You have eaten "+str(STATS.get_resources_consumed())+" resources\n";
	current_move = "You have gone "+ str(STATS.get_tiles_traveled())+" tiles \n \n";
	#the conditionals split up the data and update where the event log needs to be updated
	$VSplitContainer/ScrollContainer/VBoxContainer/WorldMap_content.text = current_eat + current_move;
	if(current_round_break < new_round):
			current_breaks += "\n \n Round: "+str(new_round);
			current_round_break = new_round;
	
	if(current_round_bandage < new_round):
			current_bandage += "\n \n Round: "+str(new_round)+"\n";
			current_round_bandage = new_round;
	
	if(title == "card_break_update"):# updates each time there is a break repair update
		#this should just be a conitnuous log, so there shouldn't be any need for this to be deleted.
		current_breaks += text;
		$VSplitContainer/ScrollContainer/VBoxContainer/Breaks_content.text = current_breaks;
	elif(title=="card_bandage_update"): #updates each time there is a bandage
		current_bandage += text;
		$VSplitContainer/ScrollContainer/VBoxContainer/Bandage_content.text = current_bandage;
	pass

func clearContent(): #you're not really going to need this funciton, this is just in case it's needed later.
	$VSplitContainer/ScrollContainer/VBoxContainer/WorldMap_content.text = ""
	$VSplitContainer/ScrollContainer/VBoxContainer/CardTable_content.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_close_pressed():
	visible = false;
	 # Replace with function body.
