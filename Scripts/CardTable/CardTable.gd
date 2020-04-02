extends Control

signal gene_clicked;
signal player_done;
signal switch_to_map
signal next_turn(turn_text, round_num);

onready var justnow_label : RichTextLabel = $ctl_justnow/lbl_justnow;
onready var orgn = $Organism;
onready var nxt_btn = $button_grid/btn_nxt;
onready var status_bar = $ChromosomeStatus;

onready var energy_bar = get_node("EnergyBar")

onready var ph_filter_panel := $pnl_ph_filter;

var has_gaps = false;
var wait_on_anim = false;
var wait_on_select = false;

func _ready():
	visible = false; # Prevents an auto-turn before the game begins
	Game.card_table = self;
	orgn.setup(self);
	reset_status_bar();
	$ViewMap.texture_normal = load(Game.get_large_cell_path(Game.current_cell_string))
	
	connect("next_turn", orgn, "adv_turn");
	orgn.connect("energy_changed", energy_bar, "_on_Organism_energy_changed")
	
	$EnergyBar.MAX_ENERGY = orgn.MAX_ENERGY

func reset_status_bar():
	status_bar.clear_cmsms();
	status_bar.add_cmsm(orgn.get_cmsm(0));
	status_bar.add_cmsm(orgn.get_cmsm(1));
	status_bar.update();

func get_cmsm_status():
	return status_bar;

# Replication

func show_replicate_opts(show):
	if $pnl_reproduce.visible != show:
		close_extra_menus($pnl_reproduce);
	if (show):
		status_bar.visible = false;
		$pnl_reproduce/hsplit/ilist_choices.select(0);
		upd_replicate_desc(0);

const REPLICATE_DESC_FORMAT = "Cost:\n%s%s\n\n%s";
func get_replicate_desc(idx):
	var action_name = "";
	var tooltip_key = "";
	match (idx):
		0:
			action_name = "replicate_mitosis";
			tooltip_key = "mitosis";
		1:
			action_name = "replicate_meiosis";
			tooltip_key = "meiosis";
		2:
			action_name = "none";
			tooltip_key = "skip";
		var _err_idx:
			return "This is an error! You picked an option (#%d) we are not familiar with!" % _err_idx;
	
	var deficiency_str = "";
	var df = orgn.check_resources(action_name);
	if !df.empty():
		deficiency_str = "\nDeficient %s" % Game.list_array_string(df);
	var dingo = [orgn.get_cost_string(action_name), deficiency_str, Tooltips.REPLICATE_TTIPS[tooltip_key]];
	return REPLICATE_DESC_FORMAT % [orgn.get_cost_string(action_name), deficiency_str, Tooltips.REPLICATE_TTIPS[tooltip_key]];

func upd_replicate_desc(idx):
	var enable_btn = true;
	var btn_text = "Replicate";
	match (idx):
		0:
			enable_btn = orgn.has_resource_for_action("replicate_mitosis");
			if !enable_btn:
				btn_text = "Insufficient resources";
		1:
			enable_btn = orgn.has_resource_for_action("replicate_meiosis") && orgn.has_meiosis_viable_pool();
			if !enable_btn:
				if orgn.has_meiosis_viable_pool():
					btn_text = "Insufficient resources";
				else:
					btn_text = "Insufficient gene pool";
		2:
			btn_text = "Continue";
	
	$pnl_reproduce/hsplit/vsplit/btn_apply_replic.disabled = !enable_btn;
	$pnl_reproduce/hsplit/vsplit/btn_apply_replic.text = btn_text;
	$pnl_reproduce/hsplit/vsplit/scroll/lbl_choice_desc.text = get_replicate_desc(idx);

func _on_replic_choices_item_activated(idx):
	do_replicate(idx);

func _on_btn_apply_replic_pressed():
	do_replicate($pnl_reproduce/hsplit/ilist_choices.get_selected_items()[0]);

func do_replicate(idx):
	show_replicate_opts(false);
	orgn.replicate(idx);

# Gaps and repairs

func show_repair_opts(show):
	if $pnl_repair_choices.visible != show:
		close_extra_menus($pnl_repair_choices);
	if (show):
		$pnl_repair_choices/hsplit/ilist_choices.select(orgn.sel_repair_idx);
		upd_repair_desc(orgn.sel_repair_idx);

func _on_Organism_show_repair_opts(show):
	show_repair_opts(show);

func hide_repair_opts():
	close_extra_menus();

const REPAIR_DESC_FORMAT = "Cost:\n%s\n\n%s";
func get_repair_desc(idx):
	var action_name = "";
	var tooltip_key = "";
	match (idx):
		0:
			action_name = "repair_cd";
			tooltip_key = "collapse_dupes";
		1:
			action_name = "repair_cp";
			tooltip_key = "copy_pattern";
		2:
			action_name = "repair_je";
			tooltip_key = "join_ends";
		var _err_idx:
			return "This is an error! You picked an option (#%d) we are not familiar with!" % _err_idx;
	return REPAIR_DESC_FORMAT % [orgn.get_cost_string(action_name), Tooltips.REPAIR_TTIPS[tooltip_key]];

func upd_repair_desc(idx):
	var btn = $pnl_repair_choices/hsplit/vsplit/btn_apply_repair;
	btn.disabled = !orgn.repair_type_possible[idx];
	btn.text = "Repair";
	orgn.change_selected_repair(idx);
	if (btn.disabled):
		btn.text = orgn.repair_btn_text[idx];
	$pnl_repair_choices/hsplit/vsplit/scroll/lbl_choice_desc.text = get_repair_desc(idx);

func _on_btn_apply_repair_pressed():
	$pnl_saveload.new_save(Game.get_save_str());
	orgn.auto_repair();

func _add_justnow_bbcode(bbcode : String, tags := {}):
	if !tags.has("align"):
		tags["align"] = RichTextLabel.ALIGN_CENTER;
	
	for t in tags:
		justnow_label.call("push_%s" % t, tags[t]);
	justnow_label.append_bbcode(bbcode);
	for _t in tags:
		justnow_label.pop();

func _on_Organism_justnow_update(text):
	_add_justnow_bbcode("\n%s\n" % text);

func _on_Organism_updated_gaps(gaps_exist, gap_text):
	has_gaps = gaps_exist;
	_add_justnow_bbcode(gap_text);
	check_if_ready();

func _on_ilist_choices_item_activated(idx):
	orgn.apply_repair_choice(idx);

# Next Turn button and availability

func upd_turn_display(upd_turn_unlocks := Game.fresh_round, upd_env_markers := Game.fresh_round):
	$lnum_turn.set_num(Game.round_num);
	$lnum_progeny.set_num(orgn.num_progeny);
	
	$TurnList.highlight(Game.turn_idx);
	
	if upd_turn_unlocks:
		$TurnList.check_unlocks();
	if upd_env_markers && orgn.current_tile.has("hazards"):
		ph_filter_panel.upd_current_ph_marker(orgn.current_tile.hazards["pH"]);

func _on_btn_nxt_pressed():
	close_extra_menus();
	if (Game.get_turn_type() == Game.TURN_TYPES.Recombination):
		for g in orgn.gene_selection:
			g.disable(true);
	
	Game.adv_turn();
	upd_turn_display();
	
	_add_justnow_bbcode("\n\n%s" % Game.get_turn_txt(), {"color": Color(1, 0.75, 0)});
	
	emit_signal("next_turn", Game.round_num, Game.turn_idx);
	$pnl_saveload.new_save(Game.get_save_str());

func _on_animating_changed(state):
	wait_on_anim = state;
	check_if_ready();

func _on_Organism_doing_work(working):
	wait_on_select = working;
	check_if_ready();

#Maybe causes issues with AI dying later?
func _on_Organism_died(org):
	Game.round_num = 0
	nxt_btn.visible = false;
	$button_grid/btn_dead_menu.visible = true;
	$button_grid/btn_dead_restart.visible = true;
	$button_grid/hsep_dead.visible = true;

func show():
	.show();
	check_if_ready();
	
	upd_turn_display(true, true);
	set_map_btn_texture("res://Assets/Images/Cells/body/body_%s_large.svg" % Game.current_cell_string);

func set_map_btn_texture(texture_path: String) -> void:
	var tex: Texture = load(texture_path);
	$ViewMap.texture_normal = tex;
	$ViewMap.texture_disabled = tex;
	$ViewMap.texture_pressed = tex;

func check_if_ready():
	var end_mapturn_on_mapscreen = Game.get_turn_type() == Game.TURN_TYPES.Map && Unlocks.has_turn_unlock(Game.TURN_TYPES.Map);
	nxt_btn.disabled = !is_visible_in_tree() || orgn.is_dead() || end_mapturn_on_mapscreen ||\
		wait_on_anim || wait_on_select || has_gaps;
	
	# Continue automatically
	if !nxt_btn.disabled && Game.get_turn_type() != Game.TURN_TYPES.Recombination:
		$AutoContinue.start();

func close_extra_menus(toggle_menu = null):
	var restore_justnow = toggle_menu == null;
	for p in [$pnl_saveload, ph_filter_panel, $pnl_bugreport, $ctl_justnow, $pnl_repair_choices, $pnl_reproduce]:
		if (p == toggle_menu):
			p.visible = !p.visible;
			if !p.visible:
				restore_justnow = true;
		else:
			p.visible = false;
	if restore_justnow:
		$ctl_justnow.visible = true;

func _on_btn_filter_pressed():
	close_extra_menus(ph_filter_panel);

func _on_WorldMap_player_done():
	emit_signal("player_done");

func _on_btn_saveload_pressed():
	close_extra_menus($pnl_saveload);

func _on_pnl_saveload_loaded():
	nxt_btn.disabled = false;
	has_gaps = false; # Should be false at the start of every new turn, incl. after loading
	_on_Organism_justnow_update("Loaded from a save.");

func _on_Organism_show_reprod_opts(show):
	show_replicate_opts(show);

func _on_btn_dead_menu_pressed():
	Game.restart_game()
	get_tree().reload_current_scene()

func _on_btn_dead_restart_pressed():
	Game.restart_game();
	get_tree().reload_current_scene();

func _on_Organism_finished_replication():
	reset_status_bar();
	status_bar.visible = true;

func refresh_visible_options():
	if ($pnl_repair_choices.visible):
		orgn.upd_repair_opts(orgn.sel_repair_gap);
		upd_repair_desc(orgn.sel_repair_idx);
	if ($pnl_reproduce.visible):
		upd_replicate_desc($pnl_reproduce/hsplit/ilist_choices.get_selected_items()[0]);

func _on_Organism_energy_changed(energy):
	$EnergyBar.update_energy_allocation(energy);
	refresh_visible_options();

func _on_Organism_resources_changed(cfp_resources, mineral_resources):
	refresh_visible_options();

func _on_pnl_ph_filter_update_seqelm_coloration(compare_type):
	for g in orgn.get_all_genes(true):
		g.color_comparison(compare_type, ph_filter_panel.get_slider_value());

func _on_AutoContinue_timeout():
	_on_btn_nxt_pressed();

func _on_ViewMap_pressed():
	emit_signal("switch_to_map")

func _on_btn_bugreport_pressed():
	close_extra_menus($pnl_bugreport);
func _on_btn_load_pressed():
	SaveExports.flag_bug($pnl_bugreport/tbox_bugdesc.text);
	$pnl_bugreport/tbox_bugdesc.text = "";
	close_extra_menus($pnl_bugreport);

func show_map_button():
	$ViewMap.disabled = false;
	$ViewMap.show()

func hide_map_button():
	$ViewMap.disabled = true;
	
	# The cell should always be visible?
	#$ViewMap.hide()
	$ViewMap/Label.hide()
