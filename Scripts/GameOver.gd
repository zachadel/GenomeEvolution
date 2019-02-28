extends PopupPanel

func display():
	get_tree().get_root().get_node("Control/WorldMap").hide()
	get_tree().get_root().get_node("Control/Canvas_CardTable/CardTable").hide()

func _on_Reset_pressed():
	get_tree().reload_current_scene()

func _on_Exit_pressed():
	get_tree().quit()
#
#func _on_Organism_died(org):
#	get_tree().get_root().get_node("Control/Canvas_UI/modeSwitch").hide()
#	$Turn.text += String(get_parent().get_node("Organism").died_on_turn)
