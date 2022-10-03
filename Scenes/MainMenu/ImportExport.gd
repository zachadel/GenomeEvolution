extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func clean():
	$TextEdit.text = ""


func _on_ExportSettings_pressed():	
	var outputString = ""
	
	for resource in Settings.settings["resources"].keys():
		outputString += "[" + resource + "]" + "\n"
		for key in Settings.settings["resources"][resource].keys():
			if(key == "biomes"):
				outputString += key + "=["
				for i in range(len(Settings.settings["resources"][resource][key])):
					outputString += "\"" + Settings.settings["resources"][resource][key][i] + "\""
					if(i+1 != len(Settings.settings["resources"][resource][key])):
						outputString += ", "
				outputString += "]" + "\n"
			else:
				var resourceRow =  String(Settings.settings["resources"][resource][key])
				if (typeof(Settings.settings["resources"][resource][key]) == TYPE_STRING):
					resourceRow = "\"" + resourceRow + "\""
				
				outputString += key + "=" + resourceRow + "\n"
		outputString += "\n"
	
	$TextEdit.text = outputString
	pass # Replace with function body.
	

func _on_LoadSettings_pressed():
	# Assume the text is already here
	var text = $TextEdit.text
	var newFile = File.new()
	newFile.open("res://Data//resources.cfg", newFile.WRITE)
	assert(newFile.is_open())
	newFile.store_string(text)
	newFile.close()
	# New settings are saved, let's run, now let's replace?
	# Change Settings.settings["reousrces"]
	Settings.load_setting("resources", false)
	pass # Replace with function body.
