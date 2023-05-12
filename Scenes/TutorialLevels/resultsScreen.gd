extends Panel



func _on_start_over_pressed():
	get_tree().change_scene("res://Scenes/TutorialLevels/GeneShop.tscn")
	
func set_values(score, indicator_values):
	$mainStat1/score.text = str(score)
	$mainStat2/score.text = str(indicator_values["genes"][0])
	$mainStat3/score.text = str(indicator_values["HBTE"][0])
	$mainStat4/score.text = str(indicator_values["TEs"][0])
