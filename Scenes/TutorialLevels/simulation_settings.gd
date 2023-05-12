extends Node

var selected_genes = []
var is_simulation = false
var simulation_cell_display

# gene [gene type, # of genes, gene value]
# gene type:
# 0 -> gene, 1 -> transposon, 2 -> blank
const genes = {
	"Construction":[0,1,1], 
	"Component":[0,1,1], 
	"Deconstruction":[0,1,1],
	"Helper":[0,1,1], 
	"Locomotion":[0,1,1], 
	"Manipulation":[0,1,1], 
	"Replication":[0,1,1], 
	"Sensing":[0,1,1],
	"Blank":[2,0,0],
	"card":[1,0,1],
	"commuter":[1,0,1],
	"superjump":[1,0,1],
	"closefar":[1,0,1],
	"cnearjfar":[1,0,1],
	"zigzag":[1,0,1],
	"buncher":[1,0,1],
	"budding":[1,0,1]
}

func register_simulation_cell(sim_cell):
	simulation_cell_display = sim_cell

func get_simulation_cell():
	return simulation_cell_display
	
func set_genes(genes_recieved, gene_values):
	var i = 0
	for gene in genes:
		genes[gene][1] = genes_recieved[i]
		genes[gene][2] = gene_values[i]
		i += 1
	
	for gene in genes:
		for count in range(genes[gene][1]):
			selected_genes.append([gene, genes[gene][0], genes[gene][2]])

func shuffle():
	selected_genes.shuffle()
	return selected_genes
