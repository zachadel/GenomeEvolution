extends Panel

onready var TurnList := $VBox;

var highlighted_node = null;

func _ready():
	for idx in range(Game.turns.size()):
		var nxt_disp = load("res://Scenes/CardTable/TurnListDisplay.tscn").instance();
		var turn_code : int = Game.turns[idx];
		TurnList.add_child(nxt_disp);
		nxt_disp.setup(idx, Game.get_turn_txt(turn_code), !Unlocks.has_turn_unlock(turn_code));

func highlight(idx : int):
	if highlighted_node != null:
		highlighted_node.set_highlighted(false);
	highlighted_node = TurnList.get_child(idx);
	highlighted_node.set_highlighted(true);

func check_unlocks():
	for idx in TurnList.get_child_count():
		var turn_code : int = Game.turns[idx];
		TurnList.get_child(idx).set_locked(!Unlocks.has_turn_unlock(turn_code));
