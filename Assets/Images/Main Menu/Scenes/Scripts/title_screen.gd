extends Control

var scene_path_to_load

func _ready():
	var butt_array = $Menu/CenterRow/Buttons.get_children()
	butt_array.pop_back()
	for button in butt_array:
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])

func _on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_FadeIn_fade_in_finished():
	get_tree().change_scene(scene_path_to_load)