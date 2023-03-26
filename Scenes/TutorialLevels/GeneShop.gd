extends Control

onready var gene_labels = [
	get_node("Genome/Construction_Label"),
	get_node("Genome/Component_Label"),
	get_node("Genome/Deconstruction_Label"),
	get_node("Genome/Helper_Label"),
	get_node("Genome/Locomotion_Label"),
	get_node("Genome/Manipulation_Label"),
	get_node("Genome/Replication_Label"),
	get_node("Genome/Sensing_Label")
]

onready var gene_prices = [
	int(get_node("Construction/Construction_Price").get_text()),
	int(get_node("Component/Component_Price").get_text()),
	int(get_node("Deconstruction/Deconstruction_Price").get_text()),
	int(get_node("Helper/Helper_Price").get_text()),
	int(get_node("Locomotion/Locomotion_Price").get_text()),
	int(get_node("Manipulation/Manipulation_Price").get_text()),
	int(get_node("Replication/Replication_Price").get_text()),
	int(get_node("Sensing/Sensing_Price").get_text())
]

const gene_buttons = [
	"Construction", 
	"Component", 
	"Deconstruction",
	"Helper", 
	"Locomotion", 
	"Manipulation", 
	"Replication", 
	"Sensing"
]

var genes = [2, 2, 2, 2, 2, 2, 2, 2]
const LV1 = 3
const LV2 = 4
const LV3 = 6
const LV4 = 8
const LV5 = 10

var credits = 30

func _ready():
	get_node("Transposon").set_color(Color.red)
	
func _update_player_display(index: int):
	var gene = gene_buttons[index]
	if genes[index] >= LV4:
		get_node("PlayerDisplay/"+gene+"Part").set_texture(load("res://Scenes/TutorialLevels/PlayerSprite/"+gene+"_4.png"))
	elif genes[index] >= LV3:
		get_node("PlayerDisplay/"+gene+"Part").set_texture(load("res://Scenes/TutorialLevels/PlayerSprite/"+gene+"_3.png"))
	elif genes[index] >= LV2:
		get_node("PlayerDisplay/"+gene+"Part").set_texture(load("res://Scenes/TutorialLevels/PlayerSprite/"+gene+"_2.png"))
	elif genes[index] >= LV1:
		get_node("PlayerDisplay/"+gene+"Part").visible = true

func _update_gene_count(index: int):
	genes[index] += 1
	gene_labels[index].set_text("x " + String(genes[index]))
	

func _on_gene_pressed(button_name: String):
	var index = gene_buttons.find(button_name)
	var price = gene_prices[index]
	var warning = get_node("Credit/NotEnough")
	if credits >= price:
		warning.visible = false
		_update_gene_count(index)
		_update_player_display(index)
		credits -= price
		get_node("Credit/CreditVal").set_text(String(credits))
	else:
		warning.visible = true
	
