extends Node

var selected_genes = []
var is_simulation = false
var simulation_cell_display

const genes = {
	"Construction":[0,1], 
	"Component":[0,1], 
	"Deconstruction":[0,1],
	"Helper":[0,1], 
	"Locomotion":[0,1], 
	"Manipulation":[0,1], 
	"Replication":[0,1], 
	"Sensing":[0,1],
	"Blank":[0,0],
	"card":[1,0],
	"commuter":[1,0],
	"superjump":[1,0],
	"closefar":[1,0],
	"cnearjfar":[1,0],
	"zigzag":[1,0],
	"buncher":[1,0],
	"budding":[1,0]
}

func register_simulation_cell(sim_cell):
	simulation_cell_display = sim_cell

func get_simulation_cell():
	return simulation_cell_display
	
func set_genes(genes_recieved):
	selected_genes = genes_recieved
	var i = 0
	for gene in genes:
		genes[gene][1] = selected_genes[i]
		i += 1

func shuffle():
	var keys = genes.keys()
	var shuffled_keys = []
	while keys.size() > 0:
		var index = randi() % keys.size()
		shuffled_keys.append(keys[index])
		keys.remove(index)
	
	var shuffled_dict = {}
	for key in shuffled_keys:
		shuffled_dict[key] = genes[key]
	
	return shuffled_dict

