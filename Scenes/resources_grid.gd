extends Panel

var org

func _ready():
	org = get_tree().get_root().get_node("Control/Canvas_CardTable/CardTable/Organism")
	
	$GridContainer/TextureProgress1/Label.hide()
	$GridContainer/TextureProgress2/Label.hide()
	$GridContainer/TextureProgress3/Label.hide()
	$GridContainer/TextureProgress4/Label.hide()

func _process(delta):
	
	for i in range(1, 5):
		var path = "GridContainer/TextureProgress" + str(i) + "/Label"
		get_node(path).text = str(org.resources[i - 1])
#		$GridContainer/TextureProgress1/Label.text = ""
#		$GridContainer/TextureProgress2/Label.text = ""
#		$GridContainer/TextureProgress3/Label.text = ""
#		$GridContainer/TextureProgress4/Label.text = ""


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
