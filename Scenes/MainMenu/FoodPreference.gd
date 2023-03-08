extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var settings = {}

var meat_items = ["chicken", "egg", "steak"]
var vegan_items = ["tofu"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


func _on_OmnivoreCheck_pressed():
	$CarnivoreCheck.pressed = false
	$VeganCheck.pressed = false
	pass # Replace with function body.


func _on_CarnivoreCheck_pressed():
	$OmnivoreCheck.pressed = false
	$VeganCheck.pressed = false
	pass # Replace with function body.


func _on_VeganCheck_pressed():
	$CarnivoreCheck.pressed = false
	$OmnivoreCheck.pressed = false
	pass # Replace with function body.


func _on_ApplyPreferences_pressed():
	if($VeganCheck.pressed):
		for name in meat_items:
			Settings.settings["resources"][name]["scale"] = 0
		for name in vegan_items:
			Settings.settings["resources"][name]["scale"] = 15
	if($CarnivoreCheck.pressed):
		for name in vegan_items:
			Settings.settings["resources"][name]["scale"] = 0
		for name in meat_items:
			Settings.settings["resources"][name]["scale"] = 15
	if($OmnivoreCheck.pressed):
		for name in meat_items:
			Settings.settings["resources"][name]["scale"] = 15
		for name in vegan_items:
			Settings.settings["resources"][name]["scale"] = 15
		
	pass # Replace with function body.
