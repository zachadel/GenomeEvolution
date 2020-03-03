extends Control

signal begin_new_game
signal go_to_settings
signal exit_game

export (PackedScene) var Cell

const MIN_SPEED = 150
const MAX_SPEED = 250

func _ready():
	$nudResRate.value = Game.resource_mult;
	$CellTimer.start()

func _on_nudResRate_value_changed(val):
	Game.resource_mult = val;

func _on_cboxUnlockAll_toggled(pressed):
	Unlocks.unlock_override = pressed;

func _on_NewGame_pressed():
	emit_signal("begin_new_game")
	pass # Replace with function body.
	
func _on_Settings_pressed():
	emit_signal("go_to_settings")


func _on_Exit_pressed():
	emit_signal("exit_game")


func _on_Tutorial_pressed():
	pass # Replace with function body.

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
