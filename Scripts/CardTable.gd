extends Control

signal gene_clicked;
signal player_done;
signal next_turn(turn_text, round_num);

onready var justnow_label = $sc_justnow/lbl_justnow;
onready var criteria_label = $sc_criteria/lbl_criteria;
onready var orgn = $Organism;
onready var nxt_btn = $button_grid/btn_nxt;
onready var status_bar = $ChromosomeStatus;

var has_gaps = false;
var wait_on_anim = false;
var wait_on_select = false;

func _ready():
	Game.card_table = self;
	orgn.setup(self);
	
	$lbl_turn.text = Game.get_turn_txt();
	connect("next_turn", orgn, "adv_turn");
	
	reset_status_bar();

func reset_status_bar():
	status_bar.clear_cmsms();
	status_bar.add_cmsm(orgn.get_cmsm(0));
	status_bar.add_cmsm(orgn.get_cmsm(1));
	status_bar.update();

func get_cmsm_status():
	return status_bar;

# Replication

func show_replicate_opts(show):
	$pnl_reproduce.visible = show;
	if (show):
		status_bar.visible = false;
		$pnl_reproduce/hsplit/ilist_choices.select(0);
		upd_replicate_desc(0);

func upd_replicate_desc(idx):
	$pnl_reproduce/hsplit/vsplit/btn_apply_replic.disabled = idx == 1 && !orgn.can_meiosis();
	match (idx):
		0:
			$pnl_reproduce/hsplit/vsplit/scroll/lbl_choice_desc.text = "Replicate both chromosomes and choose one pair.";
		1:
			$pnl_reproduce/hsplit/vsplit/scroll/lbl_choice_desc.text = "Replicate and separate both chromosomes; choose two to keep, including a random one from the gene pool.";
		var _err_idx:
			$pnl_reproduce/hsplit/vsplit/scroll/lbl_choice_desc.text = "This is an error! You picked an option (#%d) we are not familiar with!" % _err_idx;

func _on_replic_choices_item_activated(idx):
	do_replicate(idx);

func _on_btn_apply_replic_pressed():
	do_replicate($pnl_reproduce/hsplit/ilist_choices.get_selected_items()[0]);

func do_replicate(idx):
	show_replicate_opts(false);
	orgn.replicate(idx);

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

func _on_Organism_updated_gaps(gaps_exist, gap_text):
	has_gaps = gaps_exist;
	criteria_label.text = gap_text;
	check_if_ready();

func _on_ilist_choices_item_activated(idx):
	orgn.apply_repair_choice(idx);

# Next Turn button and availability

func _on_btn_nxt_pressed():
	if (Game.get_turn_type() == Game.TURN_TYPES.Recombination):
		for g in orgn.gene_selection:
			g.disable(true);
	Game.adv_turn();
	$lbl_turn.text = "%s\n%s\n%s" % [
		"Generation %d" % Game.round_num,
		Game.get_turn_txt(),
		"Progeny: %d" % (Game.round_num - 1)
	];
	emit_signal("next_turn", Game.round_num, Game.turn_idx);
	$pnl_saveload.new_save(Game.get_save_str());

func _on_animating_changed(state):
	wait_on_anim = state;
	check_if_ready();

func _on_Organism_doing_work(working):
	wait_on_select = working;
	check_if_ready();

func _on_Organism_died(org):
	Game.round_num = 0
	nxt_btn.visible = false;
	$button_grid/btn_energy_allocation.visible = false;
	$button_grid/btn_dead_menu.visible = true;
	$button_grid/btn_dead_restart.visible = true;
	$button_grid/hsep_dead.visible = true;

func check_if_ready():
	nxt_btn.disabled = orgn.is_dead() || wait_on_anim || wait_on_select || has_gaps;

func _on_btn_energy_allocation_pressed():
	$pnl_energy_allocation.visible = true;

func _on_WorldMap_player_done():
	emit_signal("player_done");

func _on_btn_saveload_pressed():
	$pnl_saveload.visible = !$pnl_saveload.visible;

func _on_pnl_saveload_loaded():
	nxt_btn.disabled = false;
	_on_Organism_justnow_update("Loaded from a save.");

func _on_Organism_show_reprod_opts(show):
	show_replicate_opts(show);

func _on_btn_dead_menu_pressed():
	get_tree().change_scene("res://Assets/Images/Main Menu/Scenes/TitleScreen.tscn");

func _on_btn_dead_restart_pressed():
	Game.restart_game();
	get_tree().reload_current_scene();

func _on_Organism_finished_replication():
	reset_status_bar();
	status_bar.visible = true;
