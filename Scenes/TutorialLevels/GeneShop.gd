extends Control

onready var Construction = get_node("Genome/Construction_Label")
onready var Component = get_node("Genome/Component_Label")
onready var Deconstruction = get_node("Genome/Deconstruction_Label")
onready var Helper = get_node("Genome/Helper_Label")
onready var Locomotion = get_node("Genome/Locomotion_Label")
onready var Manipulation = get_node("Genome/Manipulation_Label")
onready var Replication = get_node("Genome/Replication_Label")
onready var Sensing = get_node("Genome/Sensing_Label")

var genes = {
	"Construction": 2,
	"Component": 2,
	"Deconstruction": 2,
	"Helper": 2,
	"Locomotion": 2, 
	"Manipulation": 2,
	"Replication": 2,
	"Sensing": 2
}

func _ready():
	get_node("Transposon").set_color(Color.red)

func _on_Construction_pressed():
	var ConstructionCount : int = int(Construction.get_text())
	ConstructionCount += 1
	genes.Construction = ConstructionCount
	Construction.set_text("x "+String(ConstructionCount))


func _on_Component_pressed():
	var ComponentCount : int = int(Component.get_text())
	ComponentCount += 1
	genes.Component = ComponentCount
	Component.set_text("x "+String(ComponentCount))


func _on_Deconstruction_pressed():
	var DeconstructionCount : int = int(Deconstruction.get_text())
	DeconstructionCount += 1
	genes.Deconstruction = DeconstructionCount
	Deconstruction.set_text("x "+String(DeconstructionCount))


func _on_Helper_pressed():
	var HelperCount : int = int(Helper.get_text())
	HelperCount += 1
	genes.Helper = HelperCount
	Helper.set_text("x "+String(HelperCount))


func _on_Locomotion_pressed():
	var LocomotionCount : int = int(Locomotion.get_text())
	LocomotionCount += 1
	genes.Locomotion = LocomotionCount
	Locomotion.set_text("x "+String(LocomotionCount))


func _on_Manipulation_pressed():
	var ManipulationCount : int = int(Manipulation.get_text())
	ManipulationCount += 1
	genes.Manipulation = ManipulationCount
	Manipulation.set_text("x "+String(ManipulationCount))


func _on_Replication_pressed():
	var ReplicationCount : int = int(Replication.get_text())
	ReplicationCount += 1
	genes.Replication = ReplicationCount
	Replication.set_text("x "+String(ReplicationCount))


func _on_Sensing_pressed():
	var SensingCount : int = int(Sensing.get_text())
	SensingCount += 1
	genes.Sensing = SensingCount
	Sensing.set_text("x "+String(SensingCount))
