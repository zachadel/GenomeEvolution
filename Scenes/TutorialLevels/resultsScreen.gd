extends Panel



func _on_start_over_pressed():
	get_tree().change_scene("res://Scenes/TutorialLevels/GeneShop.tscn")
	
func set_values(score):
	$mainStat1/score.text = str(score)
