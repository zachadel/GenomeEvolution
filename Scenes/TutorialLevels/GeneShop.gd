extends Control

onready var gene_labels = [
	get_node("Genome/ConstructionCtrl/Construction_Label"),
	get_node("Genome/ComponentCtrl/Component_Label"),
	get_node("Genome/DeconstructionCtrl/Deconstruction_Label"),
	get_node("Genome/HelperCtrl/Helper_Label"),
	get_node("Genome/LocomotionCtrl/Locomotion_Label"),
	get_node("Genome/ManipulationCtrl/Manipulation_Label"),
	get_node("Genome/ReplicationCtrl/Replication_Label"),
	get_node("Genome/SensingCtrl/Sensing_Label"),
	get_node("Genome/BlankCtrl/Blank_Label"),
	get_node("TE/ClassicCtrl/Classic_Label"),
	get_node("TE/CommuterCtrl/Commuter_Label"),
	get_node("TE/SuperJumperCtrl/SuperJumper_Label"),
	get_node("TE/AssistCtrl/Assist_Label"),
	get_node("TE/NestlerCtrl/Nestler_Label"),
	get_node("TE/ZigZagCtrl/ZigZag_Label"),
	get_node("TE/BuncherCtrl/Buncher_Label"),
	get_node("TE/BuddyCtrl/Buddy_Label")
]

onready var gene_prices = [
	int(get_node("Genome//Construction_Price").get_text()),
	int(get_node("Genome/Component_Price").get_text()),
	int(get_node("Genome/Deconstruction_Price").get_text()),
	int(get_node("Genome/Helper_Price").get_text()),
	int(get_node("Genome/Locomotion_Price").get_text()),
	int(get_node("Genome/Manipulation_Price").get_text()),
	int(get_node("Genome/Replication_Price").get_text()),
	int(get_node("Genome/Sensing_Price").get_text()),
	int(get_node("Genome/Blank_Price").get_text()),
	int(get_node("TE/Classic_Price").get_text()),
	int(get_node("TE/Commuter_Price").get_text()),
	int(get_node("TE/SuperJumper_Price").get_text()),
	int(get_node("TE/Assist_Price").get_text()),
	int(get_node("TE/Nestler_Price").get_text()),
	int(get_node("TE/ZigZag_Price").get_text()),
	int(get_node("TE/Buncher_Price").get_text()),
	int(get_node("TE/Buddy_Price").get_text())
]

const gene_buttons = [
	"Construction", 
	"Component", 
	"Deconstruction",
	"Helper", 
	"Locomotion", 
	"Manipulation", 
	"Replication", 
	"Sensing",
	"Blank",
	"Classic",
	"Commuter",
	"SuperJumper",
	"Assist",
	"Nestler",
	"ZigZag",
	"Buncher",
	"Buddy"
]

var genes = [2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0]
const LV1 = 3
const LV2 = 4
const LV3 = 7
const LV4 = 9

var credits = 100

func _ready():
	for te in range(9, 17):
		get_node("TE/"+gene_buttons[te]).set_color(Color.red)

func _update_player_display(index: int, type: String):
	var gene = gene_buttons[index]
	if index <8:
		if genes[index] >= LV4:
			get_node("PlayerDisplay/"+gene+"Part").set_texture(load("res://Scenes/TutorialLevels/PlayerSprite/"+gene+"_4.png"))
		elif genes[index] >= LV3:
			get_node("PlayerDisplay/"+gene+"Part").set_texture(load("res://Scenes/TutorialLevels/PlayerSprite/"+gene+"_3.png"))
		elif genes[index] >= LV2:
			get_node("PlayerDisplay/"+gene+"Part").set_texture(load("res://Scenes/TutorialLevels/PlayerSprite/"+gene+"_2.png"))
		elif genes[index] == LV1 and type == "sell":
			get_node("PlayerDisplay/"+gene+"Part").set_texture(load("res://Scenes/TutorialLevels/PlayerSprite/"+gene+"_1.png"))
		elif genes[index] == LV1 and type == "buy":
			get_node("PlayerDisplay/"+gene+"Part").visible = true
		else:
			get_node("PlayerDisplay/"+gene+"Part").visible = false

func _update_gene_count(index: int, type: String):
	if type == "buy":
		genes[index] += 1
	elif type == "sell":
		genes[index] -= 1
		
	gene_labels[index].set_text(String(genes[index]))
	

func _on_gene_increase(button_name: String):
	var index = gene_buttons.find(button_name)
	var price = gene_prices[index]
	var warning = get_node("Credit/NotEnough")
	if credits >= price:
		warning.visible = false
		_update_gene_count(index, "buy")
		_update_player_display(index, "buy")
		credits -= price
		get_node("Credit/CreditVal").set_text(String(credits))
	else:
		warning.visible = true
	


func _on_gene_decrease(button_name: String):
	var index = gene_buttons.find(button_name)
	if genes[index] > 0:
		var price = gene_prices[index]
		var warning = get_node("Credit/NotEnough")
		warning.visible = false
		_update_gene_count(index, "sell")
		_update_player_display(index, "sell")
		credits += price
		get_node("Credit/CreditVal").set_text(String(credits))
