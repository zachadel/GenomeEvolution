extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal eject_resource(resource, value)

var enabled_input = true

var bar = preload("res://Scenes/WorldMap/LevelBar.tscn")
var charges = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set("custom_constants/separation", bar.instance().get_node("Bar").rect_size.y - bar.instance().get_node("Bar").get("custom_constants/margin_top"))
	for resource in Game.resources:
		if Game.resources[resource]["group"] == "minerals":
			
			if not Game.resources[resource]["tier"] in charges:
				charges.append(Game.resources[resource]["tier"])
				var LevelBar = bar.instance()
				add_child(LevelBar)
				LevelBar.name = resource
				
				LevelBar.set_resource(resource)
				var value = randi() % int(LevelBar.MAXIMUM_VALUE - LevelBar.MINIMUM_VALUE) + LevelBar.MINIMUM_VALUE

				LevelBar.update_value(value)

				LevelBar.connect("eject_resource", self, "_on_LevelBar_eject_resource")
			
	#set("custom_constants/separation", 

func update_resources_values(mineral_resources):
	for child in get_children():
		var resource_class = Game.get_class_from_name(child.name)
			
		child.update_value(mineral_resources[Game.get_class_from_name(child.name)][child.name])

func observe(resource: String):
	var level_bar = get_node(resource)
	
	if not level_bar.is_observed():
		level_bar.observe()

func set_input(enabled: bool):
	enabled_input = enabled

func _on_LevelBar_eject_resource(resource, value):
	if enabled_input:
		emit_signal("eject_resource", resource, value)
