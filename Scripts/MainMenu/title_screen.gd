extends Control

signal begin_new_game
signal go_to_settings
signal exit_game

export (PackedScene) var Cell

const MIN_SPEED = 150
const MAX_SPEED = 250

func _ready():
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
	get_tree().change_scene("res://Scenes/MainMenu/Intro.tscn")
	pass # Replace with function body.


func _on_TitleScreen_exit_game():
	get_tree().quit()
	pass # Replace with function body.
