extends PopupPanel

func _on_Reset_pressed():
	get_tree().reload_current_scene()

func _on_Exit_pressed():
	get_tree().quit()

func _on_Organism_died(org):
	$Turn.text += String(get_parent().get_node("Organism").died_on_turn)
