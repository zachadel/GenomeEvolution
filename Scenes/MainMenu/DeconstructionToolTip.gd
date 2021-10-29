extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_texture(null)
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Deconstruction_mouse_entered():
	self.set_texture(load("res://.import/SpeechRectLeft.png-f6bb2d2ed643c75702148229d976685c.stex"))


func _on_Deconstruction_mouse_exited():
	self.set_texture(null)
