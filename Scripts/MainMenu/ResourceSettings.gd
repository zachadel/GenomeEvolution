extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var resource_index = 0
var settings = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("HELLO WORLD")
	_update_local_settings()
	_update_ui()
	
func refresh():
	_update_local_settings()
	_update_ui()

#dict[resource][biomes/scale/bias/priority/richness]
func update_via_dictionary(dict: Dictionary):
	for i in range(len(Settings.settings["resources"].keys())):
		var resource = Settings.settings["resources"].keys()[i]
		
		settings[i]["biomes"] = dict[resource]["biomes"]
		settings[i]["scale"] = dict[resource]["scale"]
		settings[i]["bias"] = dict[resource]["bias"]
		settings[i]["richness"] = dict[resource]["richness"]
		settings[i]["priority"] = dict[resource]["priority"]
		settings[i]["observation_threshold"] = dict[resource]["observation_threshold"]
	
	_update_ui()

func update_global_settings():
	_update_local_settings()
	_update_settings()
	for i in range(len(Settings.settings["resources"].keys())):
		var resource_name = Settings.settings["resources"].keys()[i]
		Settings.settings["resources"][resource_name]["biomes"] = settings[i]["biomes"]
		Settings.settings["resources"][resource_name]["scale"] = settings[i]["scale"]
		Settings.settings["resources"][resource_name]["bias"] = settings[i]["bias"]
		Settings.settings["resources"][resource_name]["richness"] = settings[i]["richness"]
		Settings.settings["resources"][resource_name]["priority"] = settings[i]["priority"]
		Settings.settings["resources"][resource_name]["observation_threshold"] = settings[i]["observation_threshold"]
		var r = float(settings[i]["richness"]) / 100.0
		
		Settings.settings["resources"][resource_name]["primary_resource_max"] = int(Settings.settings["resources"][resource_name]["primary_resource_max"])
		Settings.settings["resources"][resource_name]["primary_resource_min"] = int(Settings.settings["resources"][resource_name]["primary_resource_min"])
		Settings.settings["resources"][resource_name]["secondary_resource_max"] = int(Settings.settings["resources"][resource_name]["secondary_resource_max"])
		Settings.settings["resources"][resource_name]["secondary_resource_min"] = int(Settings.settings["resources"][resource_name]["secondary_resource_min"])
		Settings.settings["resources"][resource_name]["accessory_resource_max"] = int(Settings.settings["resources"][resource_name]["accessory_resource_max"])
		Settings.settings["resources"][resource_name]["accessory_resource_min"] = int(Settings.settings["resources"][resource_name]["accessory_resource_min"])

func _update_local_settings():
	settings = {}
	for i in range(len(Settings.settings["resources"].keys())):
		settings[i] = {}
		
		var resource_name = Settings.settings["resources"].keys()[i]
		settings[i]["biomes"] = Settings.settings["resources"][resource_name]["biomes"]
		settings[i]["scale"] = Settings.settings["resources"][resource_name]["scale"]
		settings[i]["bias"] = Settings.settings["resources"][resource_name]["bias"]
		settings[i]["richness"] = Settings.settings["resources"][resource_name]["richness"]
		settings[i]["priority"] = Settings.settings["resources"][resource_name]["priority"]
		settings[i]["observation_threshold"] = Settings.settings["resources"][resource_name]["observation_threshold"]

func _update_ui():
	
	var resource_name = Settings.settings["resources"].keys()[resource_index]
	for biome in $Biomes.get_children():
		if biome.name in settings[resource_index]["biomes"]:
			biome.pressed = true
		else:
			biome.pressed = false
			
	$Icon.texture = load(Settings.settings["resources"][resource_name]["tile_image"])		
	
	$scale.value = settings[resource_index]["scale"]
	$scale/Amount.text = str($scale.value)
	
	$bias.value = settings[resource_index]["bias"]
	$bias.max_value = clamp($scale.max_value - $scale.value, -100, 100)
	$bias.min_value = clamp(-$scale.max_value + $scale.value, -100, 100)
	$bias/Amount.text = str($bias.value)
	
	$richness.value = settings[resource_index]["richness"]
	$richness/Amount.text = str($richness.value)
	
	$priority.value = settings[resource_index]["priority"]
	$priority/Amount.text = str($priority.value)
	
	$observation_threshold.value = settings[resource_index]["observation_threshold"]
	$observation_threshold/Amount.text = str($observation_threshold.value)
	$resourceName.text = Settings.settings["resources"].keys()[resource_index]

func _update_settings():
	var resource_name = Settings.settings["resources"].keys()[resource_index]
	for biome in $Biomes.get_children():
		if biome.name in settings[resource_index]["biomes"]:
			if not biome.pressed:
				settings[resource_index]["biomes"].erase(biome.name)
		else:
			if biome.pressed:
				settings[resource_index]["biomes"].append(biome.name)
	
	
	settings[resource_index]["scale"] = $scale.value
	
	settings[resource_index]["bias"] = $bias.value
	
	settings[resource_index]["richness"] = $richness.value
	
	settings[resource_index]["priority"] = $priority.value
	
	settings[resource_index]["observation_threshold"] = $observation_threshold.value

func _on_ArrowLeft_pressed():
	update_global_settings()
	resource_index = int(fposmod(resource_index - 1, len(Settings.settings["resources"].keys())))
	print("Using resource index " + str(resource_index))
	_update_ui()

func _on_ArrowRight_pressed():
	update_global_settings()
	resource_index = int(fposmod(resource_index + 1, len(Settings.settings["resources"].keys())))
	print("Using resource index " + str(resource_index))
	_update_ui() 

func _on_scale_Amount_text_entered(value):
	$scale.value = int(value)
	$scale/Amount.caret_position = len($scale/Amount.text)
	update_global_settings()
	
func _on_scale_value_changed(value):
	$scale/Amount.text = str(value);
	$bias.max_value = clamp($scale.max_value - $scale.value, -100, 100)
	$bias.min_value = clamp(-$scale.max_value + $scale.value, -100, 100)
	$bias.value = clamp($bias.value, $bias.min_value, $bias.max_value)
	$bias/Amount.text = str($bias.value)
	$bias/Title.text = str("Bias [" + str($bias.min_value) + ", " + str($bias.max_value) + "]" )
	update_global_settings()

func _on_bias_Amount_text_entered(value):
	$bias.value = int(value)
	$bias/Amount.caret_position = len($bias/Amount.text)
	update_global_settings()

func _on_bias_value_changed(value):
	$bias/Amount.text = str($bias.value)
	update_global_settings()

func _on_richness_value_changed(value):
	$richness/Amount.text = str($richness.value)
	update_global_settings()


func _on_priority_Amount_text_entered(value):
	$priority.value = int(value)
	$priority/Amount.caret_position = len($priority/Amount.text)
	update_global_settings()

func _on_priority_value_changed(value):
	$priority/Amount.text = str($priority.value)
	update_global_settings()

func _on_observation_threshold_value_changed(value):
	$observation_threshold/Amount.text = str($observation_threshold.value)
	update_global_settings()

func reload():
	_ready()
