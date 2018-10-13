extends Panel

#export (PackedScene) var gene_scene

var gene_scene = preload("res://Scenes/Gene.tscn")
var TE_scene = preload("res://Scenes/Transposon.tscn")

var gene_TE_Arrays = [[], []]
var number_of_genes = 6

func _ready():
	init_genes()

func _process(delta):
	pass
	
#redorder the array when necessary to update sprite locations
func order_array():
	#these are variables needed for spacing
	var init_pos = Vector2(OS.get_real_window_size().x / 2, OS.get_real_window_size().y / 3)
	var temp_gene = gene_scene.instance()
	var gene_sprite_size = temp_gene.get_node("Sprite").get_texture().get_size()
	temp_gene.queue_free()
	
	#simple reordering
	for i in range(2):
		for j in range(gene_TE_Arrays[i].size()):
			if number_of_genes % 2 == 0:
				gene_TE_Arrays[i][j].position.x = init_pos.x + (gene_sprite_size.x * 2 * (j + 0.5 - (gene_TE_Arrays[i].size()/2)))
			else:
				gene_TE_Arrays[i][j].position.x = init_pos.x + (gene_sprite_size.x * 2 * (j - (gene_TE_Arrays[i].size()/2)))
			gene_TE_Arrays[i][j].position.y = init_pos.y + (gene_sprite_size.y * i * 2)
	pass
	
func add_TE():
	var num_of_TE = randi()%6+1
	for i in range(num_of_TE):
		var new_pos = randi()%(gene_TE_Arrays[0].size() + gene_TE_Arrays[1].size())
		var prime_ndx = floor(new_pos / gene_TE_Arrays[0].size())
		new_pos -= ((prime_ndx * gene_TE_Arrays[0].size()) - 1)
		#print(prime_ndx)
		gene_TE_Arrays[prime_ndx].insert(new_pos, TE_scene.instance())
		gene_TE_Arrays[prime_ndx][new_pos].init()
		add_child(gene_TE_Arrays[prime_ndx][new_pos])
	order_array()
	
#this function instances all of the initial genes, puts them
#into an array, then sets their positions appropriately, and
#finally adds them as a child of the chromosome object
func init_genes():
	for i in range(2):
		for j in range(number_of_genes):
			gene_TE_Arrays[i].push_back(gene_scene.instance())
			gene_TE_Arrays[i][j].init(j)
			add_child(gene_TE_Arrays[i][j])
	order_array()
