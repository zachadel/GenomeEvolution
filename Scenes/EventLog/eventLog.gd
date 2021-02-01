extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$VSplitContainer/ScrollContainer/VBoxContainer/content.text = ""
	
	 # Replace with function body.

func addContent(title, text):
	#get_node("VSplitContainer/ScrollContainer/VBoxContainer/content").add_color_override("font_color", Color(1,0,0,1));
	if(title == "clear board," or text == ""):
		$VSplitContainer/ScrollContainer/VBoxContainer/content.text ="";
	else:
		$VSplitContainer/ScrollContainer/VBoxContainer/content.text += title+", \n";
		$VSplitContainer/ScrollContainer/VBoxContainer/content.text += text;
	pass

func clearContent():
	$VSplitContainer/ScrollContainer/VBoxContainer/content.text = "";

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_close_pressed():
	visible = false;
	 # Replace with function body.
