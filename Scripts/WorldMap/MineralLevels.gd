extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal eject_resource(resource, value)

var bar = preload("res://Scenes/WorldMap/LevelBar.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	set("custom_constants/separation", bar.instance().get_node("Bar").rect_size.y - bar.instance().get_node("Bar").get("custom_constants/margin_top"))
	for resource in Game.resources:
		if Game.resources[resource]["group"].split('_')[0] == "minerals" and Game.resources[resource]["tier"] == 0:
			var LevelBar = bar.instance()
			
			LevelBar.name = resource
			
			LevelBar.set_resource(resource)
			LevelBar.set_icon_texture(Game.resources[resource]["tile_image"])
			
			LevelBar.MINIMUM_VALUE = float(Game.resources[resource]["safe_range"][0])
			LevelBar.MAXIMUM_VALUE = float(Game.resources[resource]["safe_range"][1])
			
			LevelBar.update_value(randi() % int(LevelBar.MAXIMUM_VALUE - LevelBar.MINIMUM_VALUE) + LevelBar.MINIMUM_VALUE)
			add_child(LevelBar)
			LevelBar.connect("eject_resource", self, "_on_LevelBar_eject_resource")
			
	#set("custom_constants/separation", 

func update_resources_values(mineral_resources):
	for child in get_children():
		child.update_value(mineral_resources[child.name][0])

func _on_LevelBar_eject_resource(resource, value):
	emit_signal("eject_resource", resource, value)
