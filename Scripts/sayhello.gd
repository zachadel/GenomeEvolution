extends Panel

var counter = 0
var textNode = null
var allowed = true

func _ready():
	get_node("Button").connect("pressed", self, "_on_Button_pressed")
	textNode = get_node("Label")

func _process(delta):
	counter += delta
	if textNode != null and allowed:
		textNode.text = str(int(counter))

func _on_Button_pressed():
	textNode.text = "HELLO!"
	allowed = false
