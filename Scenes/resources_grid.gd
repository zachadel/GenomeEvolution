extends Panel

func _ready():
	$GridContainer/TextureProgress1/Label.hide()
	$GridContainer/TextureProgress2/Label.hide()
	$GridContainer/TextureProgress3/Label.hide()
	$GridContainer/TextureProgress4/Label.hide()

func _process(delta):
	pass


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
