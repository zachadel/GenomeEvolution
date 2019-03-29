extends Control

signal gene_clicked;
signal player_done;
signal next_turn(turn_text, round_num);

onready var justnow_label = $sc_justnow/lbl_justnow;
onready var criteria_label = $sc_criteria/lbl_criteria;
onready var orgn = $Organism;

func _ready():
	Game.card_table = self;
	orgn.setup(self);
	
	$lbl_turn.text = "Click \"Continue\" to start.";
	connect("next_turn", orgn, "adv_turn");

func get_cmsm_status():
	return $ChromosomeStatus;

# Gaps and repairs

func show_repair_opts(show):
	$pnl_repair_choices.visible = show;
	if (show):
		$pnl_repair_choices/hsplit/ilist_choices.select(orgn.sel_repair_idx);
		upd_repair_desc(orgn.sel_repair_idx);

func _on_Organism_show_repair_opts(show):
	show_repair_opts(show);

func hide_repair_opts():
	$pnl_repair_choices.visible = false;

func upd_repair_desc(idx):
	$pnl_repair_choices/hsplit/vsplit/btn_apply_repair.disabled = !orgn.repair_type_possible[idx];
	orgn.change_selected_repair(idx);
	match (idx):
		0:
			$pnl_repair_choices/hsplit/vsplit/scroll/lbl_choice_desc.text = "If the genes to the left and the right of the gap are the same, the break can be repaired by discarding one of the duplicates.";
		1:
			$pnl_repair_choices/hsplit/vsplit/scroll/lbl_choice_desc.text = "If both ends of the gap can be matched to an intact pattern on the other chromosome, you can attempt to copy the pattern. There is a decent chance of complications (duplicates, discarding, etc.).";
		2:
			$pnl_repair_choices/hsplit/vsplit/scroll/lbl_choice_desc.text = "You can always just attempt to join ends without a template. There is a high chance for complications (duplications, discarding, etc.).";
		var _err_idx:
			$pnl_repair_choices/hsplit/vsplit/scroll/lbl_choice_desc.text = "This is an error! You picked an option (#%d) we are not familiar with!" % _err_idx;

func _on_btn_apply_repair_pressed():
	$pnl_saveload.new_save(Game.get_save_str());
	orgn.auto_repair();

func _on_Organism_justnow_update(text):
	if (justnow_label == null):
		justnow_label = $sc_justnow/lbl_justnow;
	justnow_label.text = text;

func _on_Organism_updated_gaps(has_gaps, gap_text):
	$btn_nxt.disabled = has_gaps;
	criteria_label.text = gap_text;

func _on_ilist_choices_item_activated(idx):
	orgn.apply_repair_choice(idx);

# Next Turn button and availability

func _on_btn_nxt_pressed():
	Game.adv_turn();
	$lbl_turn.text = "Round " + str(Game.round_num) + "\n" + Game.get_turn_txt();
	emit_signal("next_turn", Game.round_num, Game.turn_idx);
	$pnl_saveload.new_save(Game.get_save_str());

var wait_on_anim = false;
var wait_on_select = false;
func _on_animating_changed(state):
	wait_on_anim = state;
	check_if_ready();

func _on_Organism_doing_work(working):
	wait_on_select = working;
	check_if_ready();

func _on_Organism_died(org):
	$GameOver.popup_centered()
	Game.round_num = 0
	$btn_nxt.disabled = true;

func check_if_ready():
	$btn_nxt.disabled = orgn.is_dead() || wait_on_anim || wait_on_select;

func _on_btn_energy_allocation_pressed():
	$pnl_energy_allocation.visible = true;

func _on_WorldMap_player_done():
	emit_signal("player_done");

func _on_btn_saveload_pressed():
	$pnl_saveload.visible = !$pnl_saveload.visible;

func _on_pnl_saveload_loaded():
	_on_Organism_justnow_update("Loaded from a save.");
