extends Node

var selected_genes = []
var is_simulation = false
var simulation_cell_display

const genes = [
	"Construction", 
	"Component", 
	"Deconstruction",
	"Helper", 
	"Locomotion", 
	"Manipulation", 
	"Replication", 
	"Sensing",
	"Blank",
]

func register_simulation_cell(sim_cell):
	simulation_cell_display = sim_cell

func get_simulation_cell():
	return simulation_cell_display
	
func set_genes(genes):
	selected_genes = genes

