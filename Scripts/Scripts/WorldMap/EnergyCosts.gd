extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal update_costs

export var colors = {
	"base": Color.green,
	"mineral": Color.brown,
	"oxygen": Color.blue,
	"temperature": Color.red
}
export var unfilled_color = Color(100, 100, 100)

export var action = ""

var functions = {
	"base": null,
	"mineral": null,
	"oxygen": null,
	"temperature": null
}

var costs = {
	"base": 0,
	"mineral": 0,
	"oxygen": 0,
	"temperature": 0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in get_children():
		child.set_unfilled_color(unfilled_color)
		
	pass # Replace with function body.

func set_functions(organism):
	functions["base"] = funcref(organism, "get_base_energy_cost")
	#print(functions["base"].call_func("simple_carbs_to_complex_carbs", 1))
	functions["mineral"] = funcref(organism, "get_mineral_energy_cost")
	functions["oxygen"] = funcref(organism, "get_oxygen_energy_cost")
	functions["temperature"] = funcref(organism, "get_temperature_energy_cost")
	
	update_costs()
	
func set_action(action_str: String):
	action = action_str	
	
#Doesn't yet do borders, just full boxes
func update_costs():
	emit_signal("update_costs")
	if action != "":
		costs["base"] = functions["base"].call_func(action)
		var bars = {
			"base": costs["base"],
			"mineral": 0,
			"oxygen": 0,
			"temperature": 0}
		
		for cost_type in functions:
			if cost_type != "base":
				costs[cost_type] = functions[cost_type].call_func(action, 1, costs["base"])
				
				if costs[cost_type] < 0:
					bars["base"] = clamp(bars["base"] + costs[cost_type], 1, 100)
					#bars[cost_type] = costs[cost_type]
				elif costs[cost_type] >= 0:
					bars[cost_type] = costs[cost_type]
		
		_update_gui(bars)
	pass
	
func _update_gui(bars: Dictionary):
	var index = 0		
	for unit in get_children():
		unit.enable()
		if index < bars["base"]:
			unit.set_colors(colors["base"], colors["base"])
			
		elif index < bars["base"] + bars["temperature"]:
			unit.set_colors(colors["temperature"], colors["temperature"])
			
		elif index < bars["base"] + bars["temperature"] + bars["oxygen"]:
			unit.set_colors(colors["oxygen"], colors["oxygen"])
		
		elif index < bars["base"] + bars["temperature"] + bars["oxygen"] + bars["mineral"]:
			unit.set_colors(colors["mineral"], colors["mineral"])
		else:
			unit.disable()
			
		index += 1
	pass
