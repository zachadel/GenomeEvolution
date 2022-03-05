extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal eject_resource(resource, value)
signal n_for_s_to_am(value)
signal n_for_am_to_s(value)

var enabled_input = true

#var bar = preload("res://Scenes/WorldMap/LevelBar2.tscn")
var charges = []

# Called when the node enters the scene tree for the first time.
func _ready():
#	set("custom_constants/separation", bar.instance().get_node("Bar").rect_size.y - bar.instance().get_node("Bar").get("custom_constants/margin_top"))
	for bar in get_children():
		bar.make_invis()
		
		if Settings.settings["resources"].has(bar.name):
			var value = randi() % int(bar.MAXIMUM_VALUE - bar.MINIMUM_VALUE) + bar.MINIMUM_VALUE

			bar.update_value(value)
#
##				LevelBar.connect("eject_resource", self, "_on_LevelBar_eject_resource")
	pass
	#set("custom_constants/separation", 

func update_resources_values(mineral_resources):
	for resource_class in mineral_resources:
		for resource in mineral_resources[resource_class]:
			if has_node(resource):
				var bar = get_node(resource)
				
				bar.update_value(mineral_resources[resource_class][resource])
				if resource == "nitrogen": #Looks for the nitrogen feature. 
					STATS.set_amt_of_nitrogen(mineral_resources[resource_class][resource]) #Sets the new value.
					#print(mineral_resources[resource_class][resource])
				elif resource == "phosphorus":
					STATS.set_P(mineral_resources[resource_class][resource])
				elif resource == "iron":
					STATS.set_Fe(mineral_resources[resource_class][resource])
				elif resource == "calcium":
					STATS.set_Ca(mineral_resources[resource_class][resource])
				elif resource == "sodium":
					STATS.set_Na(mineral_resources[resource_class][resource])
				elif resource == "mercury":
					STATS.set_P(mineral_resources[resource_class][resource])

func observe(resource: String):
	if has_node(resource):
		var level_bar = get_node(resource)
		
		if not level_bar.is_observed():
			level_bar.observe()

func set_input(enabled: bool):
	enabled_input = enabled

func lower_nitrogen(val):
	#print("hello")
	STATS.set_amt_of_nitrogen(STATS.get_amt_of_nitrogen()-val)
	var nitrogen_bar = get_node("nitrogen")
	nitrogen_bar.update_value(STATS.get_amt_of_nitrogen())

func raise_nitrogen(val):
	STATS.set_amt_of_nitrogen(STATS.get_amt_of_nitrogen()+val)
	var nitrogen_bar = get_node("nitrogen")
	nitrogen_bar.update_value(STATS.get_amt_of_nitrogen())
