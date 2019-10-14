extends Control

signal next_turn(turn_text, round_num);
var new_ai = 0;
var simd = 0;
var simfor = 1;

func _ready():
	force_add();

func disable_sims(dis):
	for c in $ctl_sims.get_children():
		if ("disabled" in c):
			c.disabled = dis;

func _on_btn_next_pressed():
	Game.adv_turn();
	add_ais();
	emit_signal("next_turn", Game.round_num, Game.get_turn_txt());

func _on_btn_leap_pressed():
	start_sim(1);

func _on_btn_bigsim_pressed():
	start_sim($ctl_sims/nud_bigsim.value);

func start_sim(count):
	disable_sims(true);
	simfor = count;
	simd = 0;
	$ctl_sims/wait_timer.start();

func _on_wait_timer_timeout():
	_on_btn_next_pressed();
	if (Game.get_turn_txt() == "Check Viability"):
		simd += 1;
		if (simd == simfor):
			$ctl_sims/wait_timer.stop();
			disable_sims(false);

func _on_btn_add_pressed():
	new_ai += 1;
	add_ais();

func add_ais():
	if (Game.get_turn_txt() == "Check Viability"):
		for i in range(new_ai):
			force_add();
		new_ai = 0;

func force_add():
	var nxt_ai = load("res://Scenes/Organism.tscn").instance();
	nxt_ai.is_ai = true;
	nxt_ai.visible = false;
	nxt_ai.name = str($vbox.get_child_count());
	connect("next_turn", nxt_ai, "adv_turn");
	nxt_ai.connect("died", self, "org_died");
	$vbox.add_child(nxt_ai);
	$list.add_item("Born %d" % Game.round_num);

func org_died(org):
	$list.set_item_text(int(org.name), "Born %d | Died %d | Lasted %d" % [org.born_on_turn, org.died_on_turn, org.died_on_turn - org.born_on_turn]);

var sel_org = null;
func _on_list_item_selected(idx):
	if (sel_org != null):
		sel_org.visible = false;
	sel_org = $vbox.get_child(idx);
	sel_org.visible = true;
