extends Panel

#export (PackedScene) var gene_scene

var gene_scene = preload("res://Scenes/Gene.tscn")

var geneArrays = [[], []]
var number_of_genes = 6

func _ready():
	var init_pos = Vector2(OS.get_real_window_size().x / 2, OS.get_real_window_size().y / 3)
	var temp_gene = gene_scene.instance()
	var gene_sprite_size = temp_gene.get_node("Sprite").get_texture().get_size()
	temp_gene.queue_free()
	
	for i in range(2):
		for j in range(number_of_genes):
			geneArrays[i].push_back(gene_scene.instance())
			
			if number_of_genes % 2 == 0:
				geneArrays[i][j].position.x = init_pos.x + (gene_sprite_size.x * 2 * (j + 0.5 - (number_of_genes/2)))
			else:
				geneArrays[i][j].position.x = init_pos.x + (gene_sprite_size.x * 2 * (j - (number_of_genes/2)))
			geneArrays[i][j].position.y = init_pos.y + (gene_sprite_size.y * i * 2)
			
			geneArrays[i][j].init(j)
			add_child(geneArrays[i][j])

func _process(delta):
	pass
