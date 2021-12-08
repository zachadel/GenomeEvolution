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

func skill_gained():
	#make golden arrow
	$skill_box.visible = true
	$skill_box/skill_text.bbcode_text = "[center][wave amp=50 freq=2]Skill Gained![/wave][/center]"
	pass

func skill_lost():
	$skill_box.visible = true
	$skill_box/skill_text.bbcode_text = "[center][wave amp=50 freq=2]Skill Lost![/wave][/center]"

func skill_mixed():
	$skill_box.visible = true
	$skill_box/skill_text.bbcode_text = "[center][wave amp=50 freq=2]Skill Changed![/wave][/center]"
	pass

func pseudogene():
	$green_arrow.visible = false
	$red_arrow.visible = false
	$top_value.visible = false
	$bottom_value.visible = false
	$skill_box.visible = false
	$pseudo_arrow.visible = true
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
