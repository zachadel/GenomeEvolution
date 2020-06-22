extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var possible_resources = ["candy1", "bread", "avocado", "tomato", "linguini", "apricot"]
	
	for resource in possible_resources:
		if resource == "candy1":
			possible_resources.erase("candy1")
	print(possible_resources)
	
	pass # Replace with function body.

func _is_higher_priority(str1, str2):
	if str1[1] >= str2[1]:
		return true
	else:
		return false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
