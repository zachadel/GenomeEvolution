extends Control


signal begin_select_genes


func _on_SelectGenes_pressed():
	emit_signal("begin_select_genes")


func _on_Tutorials_begin_select_genes():
	get_tree().change_scene("res://Scenes/TutorialLevels/SelectGene.tscn")
