extends Panel

var current_breaks = "\n Round 0: ";
var current_bandage = "\n Round 0: \n";
var current_round_break = 0;
var current_round_bandage = 0;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

# Called when the node enters the scene tree for the first time.
	 # Replace with function body.
# What is outputted where is all dependent on the title of the signal that is coming in
func addContent( text, tags:={}): 
	#print("here")
	#print("current_round break: "+str(current_round_break))
	#print("current_round_bandage: "+str(current_round_bandage))
	var new_round = STATS.get_rounds()
	#print("new round: "+str(new_round))
	#the conditionals split up the data and update where the event log needs to be updated
	if(current_round_break < new_round):
			text += "\n \n Round: "+str(new_round);
			current_round_break = new_round;
	
	if !tags.has("align"):
		tags["align"] = RichTextLabel.ALIGN_CENTER;
	
	for t in tags:
		$VSplitContainer/RichTextLabel.call("push_%s" % t, tags[t]);
	$VSplitContainer/RichTextLabel.append_bbcode(text);
	for _t in tags:
		$VSplitContainer/RichTextLabel.pop();
	$VSplitContainer/RichTextLabel.scroll_following = true;

func clearContent(): #you're not really going to need this funciton, this is just in case it's needed later.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_close_pressed():
	get_tree().paused = false;
	visible = false;
	 # Replace with function body.
