extends Panel

var org

func _ready():
	org = get_tree().get_root().get_node("Main/Canvas_CardTable/CardTable/Organism")
	
	for i in range(1, 5):
		var path = "GridContainer/TextureProgress" + str(i)
		get_node(path + "/Label").text = str(org.resources[i - 1])
		get_node(path).value = 50
		get_node(path).value = org.resources[i - 1]
		get_node(path + "/Label").hide()

func _process(delta):
	
	for i in range(1, 5):
		var path = "GridContainer/TextureProgress" + str(i)
		get_node(path + "/Label").text = str(org.resources[i - 1])
		get_node(path).value = org.resources[i - 1]


func _on_TextureProgress1_mouse_entered():
	$GridContainer/TextureProgress1/Label.show()

func _on_TextureProgress1_mouse_exited():
	$GridContainer/TextureProgress1/Label.hide()

func _on_TextureProgress2_mouse_entered():
	$GridContainer/TextureProgress2/Label.show()

func _on_TextureProgress2_mouse_exited():
	$GridContainer/TextureProgress2/Label.hide()

func _on_TextureProgress3_mouse_entered():
	$GridContainer/TextureProgress3/Label.show()

func _on_TextureProgress3_mouse_exited():
	$GridContainer/TextureProgress3/Label.hide()

func _on_TextureProgress4_mouse_entered():
	$GridContainer/TextureProgress4/Label.show()

func _on_TextureProgress4_mouse_exited():
	$GridContainer/TextureProgress4/Label.hide()
