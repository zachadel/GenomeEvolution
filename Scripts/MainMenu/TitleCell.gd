extends RigidBody2D

signal exploded(dna_array)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MIN_SPEED = 150
const MAX_SPEED = 250
const MAX_DNA = 5
const MIN_DNA = 1

export (PackedScene) var DNA

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_cell_type(cell_type: String):
	$Body.set_cell_type(cell_type)

func set_random_cell():
	var num_cells = len(Game.cells.keys())
	$Body.set_cell_type(Game.cells.keys()[randi() % num_cells])

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.

func generate_dna(num_dna: int = -1) -> Array:
	var dna_array = []
	
	if num_dna == -1:
		num_dna = randi() % (MAX_DNA - MIN_DNA) + MIN_DNA
	
	for i in range(num_dna):
		var direction = 2*PI*randf()
		var dna = DNA.instance()
		
		dna.position = position
		dna.rotation = direction + PI / 2
		
		dna.linear_velocity = Vector2(rand_range(dna.MIN_SPEED, dna.MAX_SPEED), 0)
		dna.linear_velocity = dna.linear_velocity.rotated(direction)
		
		dna.modulate = Color(randf(), randf(), randf(), 1)
		
		dna_array.append(dna)
		
	return dna_array
	
func explode():
	var dna_array = generate_dna()
		
	emit_signal("exploded", dna_array)
	visible = false
	
	return dna_array


func _on_Cell_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouse_left"):
		explode()
