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
	
func add_TE():
	var num_of_TE = randi()%6+1
	for i in range(num_of_TE):
		var new_pos = randi()%gene_TE_Arrays.size()
		var prime_ndx = new_pos / number_of_genes
		gene_TE_Arrays[floor(prime_ndx)].insert(new_pos, TE_scene.instance())
		gene_TE_Arrays[new_pos].position
	pass
	
#this function instances all of the initial genes, puts them
#into an array, then sets their positions appropriately, and
#finally adds them as a child of the chromosome object
func init_genes():
	var init_pos = Vector2(OS.get_real_window_size().x / 2, OS.get_real_window_size().y / 3)
	var temp_gene = gene_scene.instance()
	var gene_sprite_size = temp_gene.get_node("Sprite").get_texture().get_size()
	temp_gene.queue_free()
	
	for i in range(2):
		for j in range(number_of_genes):
			gene_TE_Arrays[i].push_back(gene_scene.instance())
			
			if number_of_genes % 2 == 0:
				gene_TE_Arrays[i][j].position.x = init_pos.x + (gene_sprite_size.x * 2 * (j + 0.5 - (number_of_genes/2)))
			else:
				gene_TE_Arrays[i][j].position.x = init_pos.x + (gene_sprite_size.x * 2 * (j - (number_of_genes/2)))
			gene_TE_Arrays[i][j].position.y = init_pos.y + (gene_sprite_size.y * i * 2)
			
			gene_TE_Arrays[i][j].init(j)
			add_child(gene_TE_Arrays[i][j])
