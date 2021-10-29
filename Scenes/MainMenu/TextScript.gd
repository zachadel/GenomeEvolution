extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Replication_mouse_entered():
	self.show()


func _on_Replication_mouse_exited():
	self.hide()


func _on_Component_mouse_entered():
	self.show()


func _on_Component_mouse_exited():
	self.hide()


func _on_Deconstruction_mouse_entered():
	self.show()


func _on_Deconstruction_mouse_exited():
	self.hide()


func _on_Helper_mouse_entered():
	self.show()


func _on_Helper_mouse_exited():
	self.hide()


func _on_Locomotion_mouse_entered():
	self.show()


func _on_Locomotion_mouse_exited():
	self.hide()


func _on_Manipulation_mouse_entered():
	self.show()


func _on_Manipulation_mouse_exited():
	self.hide()


func _on_Sensing_mouse_entered():
	self.show()


func _on_Sensing_mouse_exited():
	self.hide()
