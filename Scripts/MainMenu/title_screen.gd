extends Control

signal begin_new_game
signal go_to_settings
signal exit_game

export (PackedScene) var Cell

const MIN_SPEED = 150
const MAX_SPEED = 250

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	$CellTimer.start()

func _on_NewGame_pressed():
	emit_signal("begin_new_game")
	pass # Replace with function body.

func _on_Exit_pressed():
	emit_signal("exit_game")

#Add all cells to a group for clearing out when exiting the TitleScreen

func _on_CellTimer_timeout():
	$CellPath/CellSpawnPosition.set_offset(randi())
	
	var cell = Cell.instance()
	cell.set_random_cell()
	add_child_below_node($Background, cell)
	
	var direction = $CellPath/CellSpawnPosition.rotation + PI / 2
	cell.position = $CellPath/CellSpawnPosition.position
	
	direction += rand_range(-PI / 4, PI / 4)
	cell.rotation = direction
	
	cell.linear_velocity = Vector2(rand_range(cell.MIN_SPEED, cell.MAX_SPEED), 0)
	cell.linear_velocity = cell.linear_velocity.rotated(direction)
	
	cell.connect("exploded", self, "_on_Cell_Exploded")
	
func _on_Cell_Exploded(dna_array):
	for dna in dna_array:
		add_child_below_node($Background, dna)


func _on_TitleScreen_begin_new_game():
	Game.round_num = 0
	get_tree().change_scene("res://Scenes/MainMenu/Intro.tscn")
	pass # Replace with function body.


func _on_TitleScreen_exit_game():
	get_tree().quit()
	pass # Replace with function body.


func _on_Credits_pressed():
	get_tree().change_scene("res://Scenes/MainMenu/Credits.tscn")
	pass # Replace with function body.


func _on_Button_pressed():
	$HTTPRequest.request("https://getpantry.cloud/apiv1/pantry/4eb404d9-6961-4797-a4bc-6179d5a5fdf4/basket/Test Pantry")
	#0 is get, 3 is put



func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
