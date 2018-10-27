extends Node

var sqelm_textures = {"gene": load("res://Assets/Images/gene.png"), "break": load("res://Assets/Images/break.png")};
var essential_classes = ["Replication", "Locomotion", "Manipulation", "Sensing", "Construction", "Deconstruction"];

var turns = ["New TEs", "Active TEs Jump", "Repair Breaks", "Environmental Damage", "Repair Breaks", "Recombination", "Evolve", "Check Viability"];
var turn_idx = -1;
var round_num = 1;

var animation_duration = 1;
var animation_ease = Tween.EASE_IN;
var animation_trans = Tween.TRANS_LINEAR;

func _ready():
	randomize();

func getTEName():
	return "T" + str(randi()%10);

# This is a little hack I've come up with to make bars in ScrollContainer controls larger
func change_slider_width(scroll_cont, horiz = true, width = 30):
	if (horiz):
		var slider = scroll_cont.get_node("_h_scroll");
		slider.margin_top = -width;
		slider.rect_size.y = width;
	else:
		var slider = scroll_cont.get_node("_v_scroll");
		slider.margin_left = -width;
		slider.rect_size.x = width;

func adv_turn():
	turn_idx += 1;
	if (turn_idx == turns.size()):
		turn_idx = 0;
		round_num += 1;

func get_turn_txt():
	return turns[turn_idx];

func roll(n, d = null):
	if (d == null):
		var i = n.split("d");
		n = int(i[0]);
		d = int(i[1]);
	var sum = 0;
	for i in range(n):
		sum += randi()%d + 1;
	return sum;

func copy_elm(elm):
	var copy = load("res://Scenes/SequenceElement.tscn").instance();
	copy.setup(elm.type, elm.id, elm.mode, elm.ess_class);
	return copy;

func rollATEJumps():
	var rand = randf();
	if (rand <= .2778):
		return 0;
	elif (rand <= .7223):
		return 1;
	elif (rand <= .9167):
		return 2;
	else:
		return 3;

func rollCopyRepair():
	var rand = randf();
	if (rand <= .1667):
		return 0;
	elif (rand <= .3334):
		return 1;
	elif (rand <= .8335):
		return 2;
	else:
		return 3;

func rollJoinEnds():
	var rand = randf();
	if (rand <= .5001):
		return 0;
	elif (rand <= .8335):
		return 1;
	else:
		return 2;

func rollEvolve():
	var rand = randf();
	if (rand <= 0.3334):
		return 0;
	if (rand <= 0.8335):
		return 1;
	else:
		return 2;