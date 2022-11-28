extends Panel


var resource_index = 0
var settings = {}

func _ready():
	#print("HELLO WORLD")
	settings = {}
	for i in range(len(Settings.settings["resources"].keys())):
		
		settings[i] = {}
		
		var resource_name = Settings.settings["resources"].keys()[i]
		settings[i]["biomes"] = Array(Settings.settings["resources"][resource_name]["biomes"])
		settings[i]["scale"] = Settings.settings["resources"][resource_name]["scale"]
		settings[i]["bias"] = Settings.settings["resources"][resource_name]["bias"]
		settings[i]["richness"] = Settings.settings["resources"][resource_name]["richness"]
		settings[i]["priority"] = Settings.settings["resources"][resource_name]["priority"]
		settings[i]["observation_threshold"] = Settings.settings["resources"][resource_name]["observation_threshold"]
		
	_update_ui()
	
func refresh():
	_ready()
	
func _update_ui():
	var resource_name = Settings.settings["resources"].keys()[resource_index]
	$ResourceName.text = resource_name
	$ResourceIcon.texture = load(Settings.settings["resources"][resource_name]["tile_image"])	
	$EventLabel.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_LeftArrow_pressed():
	resource_index = int(fposmod(resource_index - 1, len(Settings.settings["resources"].keys())))
	_update_ui()

func _on_RightArrow_pressed():
	resource_index = int(fposmod(resource_index + 1, len(Settings.settings["resources"].keys())))
	_update_ui() 

func generateStringHash():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var validCharacters = "qwertyuiopasdfghjklzxcvbnm1234567890QWERTYUIOPASDFGHJKLZXCVBNM!@#$%^&*()"
	var generatedString = "|-|"
	for i in range(0,10):
		var randomIndex = rng.randi_range(0,len(validCharacters)-1)
		generatedString += validCharacters[randomIndex]
	return generatedString

func _on_AddNewInstance_pressed():
	var original_resource = Settings.settings["resources"].keys()[resource_index]
	var newResource = original_resource + generateStringHash()
	Settings.settings["resources"][newResource] = {}
	for characteristic in Settings.settings["resources"][original_resource].keys():
		if characteristic == "biomes":
			Settings.settings["resources"][newResource][characteristic] = [] + Settings.settings["resources"][original_resource][characteristic]
		else:
			Settings.settings["resources"][newResource][characteristic] = Settings.settings["resources"][original_resource][characteristic]
	
	$EventLabel.text = "New instance added"

func _on_DeleteInstance_pressed():
	var original_resource = Settings.settings["resources"].keys()[resource_index]
	Settings.settings["resources"].erase(original_resource)
	resource_index = resource_index-1
	
	$EventLabel.text = "Instance deleted"
