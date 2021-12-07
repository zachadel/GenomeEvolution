extends TextureRect

var top_value
var bottom_value
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_top_value(var number):
	$top_value.bbcode_text = "[center]"+ "%.1f" % number +"[/center]";
	top_value = number
	pass
	
func set_bottom_value(var number):
	$bottom_value.bbcode_text = "[center]"+ "%.1f" % number +"[/center]";
	bottom_value = number
	pass
	
func choose_arrow():
	if top_value > bottom_value:
		$red_arrow.visible = true
	else:
		$green_arrow.visible = true

func golden_arrow():
	pass

func psuedogene():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
