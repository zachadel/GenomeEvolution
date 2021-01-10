extends Control

signal gene_clicked;
signal player_done;
signal switch_to_map
signal next_turn(turn_text, round_num);
signal card_stats_screen;

onready var justnow_label : RichTextLabel = $ctl_justnow/lbl_justnow;
onready var orgn = $Organism;
onready var nxt_btn = $button_grid/btn_nxt;
onready var status_bar = $ChromosomeStatus;

onready var energy_bar = get_node("EnergyBar")

onready var ph_filter_panel := $pnl_ph_filter;
onready var justnow_ctl := $ctl_justnow;
onready var temp_filter_panel := $pnl_temp_filter;

var has_gaps = false;
var wait_on_anim = false;
var wait_on_select = false;

var disable_turn_adv = true

func _ready():
	visible = false; # Prevents an auto-turn before the game begins
	orgn.setup(self);
	reset_status_bar();
	$ViewMap.texture_normal = load(Game.get_large_cell_path(Game.current_cell_string))
	
	
	connect("next_turn", orgn, "adv_turn");
	orgn.connect("energy_changed", energy_bar, "_on_Organism_energy_changed")
	
	$RepairTabs.set_tab_title(0, "Repair Breaks");
	$RepairTabs.set_tab_title(1, "Trim Damaged Genes");
	$RepairTabs.set_tab_title(2, "Trim Genes from Breaks");
	$RepairTabs.set_tab_title(3, "Fix Damaged Genes");
	
	$EnergyBar.MAX_ENERGY = orgn.MAX_ENERGY
	#$statsScreen.visible = false;

func reset_status_bar():
	status_bar.clear_cmsms();
	status_bar.add_cmsm(orgn.get_cmsm(0));
	status_bar.add_cmsm(orgn.get_cmsm(1));
	status_bar.update();

func get_cmsm_status():
	return status_bar;

func get_Organism():
	return orgn
# Replication

func show_replicate_opts(show):
	if $pnl_reproduce.visible != show:
		close_extra_menus($pnl_reproduce, true);
	if show:
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
	status_bar.visible = false;
	orgn.replicate(idx);

# Gaps and repairs

const LOCKABLE_REPAIRS = ["collapse_dupes", "copy_pattern"];
const REP_TYPE_TO_IDX = {
	"collapse_dupes": 0,
	"copy_pattern": 1,
	"join_ends": 2
};
var REP_IDX_TO_TYPE := {};
func repair_type_to_idx(type: String) -> int:
	return REP_TYPE_TO_IDX.get(type, -1);
func repair_idx_to_type(idx: int) -> String:
	if REP_IDX_TO_TYPE.empty():
		for k in REP_TYPE_TO_IDX:
			REP_IDX_TO_TYPE[REP_TYPE_TO_IDX[k]] = k;
	
	return REP_IDX_TO_TYPE.get(idx, "join_ends");

func upd_repair_lock_display():
	for rep_type in LOCKABLE_REPAIRS:
		var img_path : String = "res://Assets/Images/icons/" + rep_type;
		if !Unlocks.has_repair_unlock(rep_type):
			img_path += "_locked";
		$RepairTabs/pnl_repair_choices/hsplit/ilist_choices.set_item_icon(REP_TYPE_TO_IDX[rep_type], load(img_path + ".png"));
	
	var num_left_txt = "\n\nThe number of genes you can remove is based on your Disassembly skill.\nYou can remove %d more this turn." % orgn.total_scissors_left;
	var trim_dmg_lbl = $RepairTabs/pnl_rem_dmg/LblInstr;
	trim_dmg_lbl.text = "\n\n";
	if orgn.get_behavior_profile().has_skill("trim_dmg_genes"):
		$RepairTabs.set_tab_icon(1, null);
		trim_dmg_lbl.text += "Click a damaged gene to remove it.";
	else:
		$RepairTabs.set_tab_icon(1, load("res://Assets/Images/icons/padlock_small.png"));
		var needed_skill : Skills.Skill = Skills.get_skill("trim_dmg_genes");
		trim_dmg_lbl.text += "You are lacking the required '%s' %s skill to use this function." % [needed_skill.desc, needed_skill.behavior];
	trim_dmg_lbl.text += num_left_txt;
	
	var trim_end_lbl = $RepairTabs/pnl_rem_sides/LblInstr;
	trim_end_lbl.text = "\n\n";
	if orgn.get_behavior_profile().has_skill("trim_gap_genes"):
		$RepairTabs.set_tab_icon(2, null);
		trim_end_lbl.text += "Click a gene on either ends of a break to remove the gene.";
	else:
		$RepairTabs.set_tab_icon(2, load("res://Assets/Images/icons/padlock_small.png"));
		var needed_skill : Skills.Skill = Skills.get_skill("trim_gap_genes");
		trim_end_lbl.text += "You are lacking the required '%s' %s skill to use this function." % [needed_skill.desc, needed_skill.behavior];
	trim_end_lbl.text += num_left_txt;

func show_repair_opts(show):
	if show:
		upd_repair_lock_display();
		$RepairTabs/pnl_bandage_dmg/vbox/scroll/RTLRepairResult.text = "";
		yield(get_tree(), "idle_frame");
		show_repair_tab(0);
	if $RepairTabs.visible != show:
		close_extra_menus($RepairTabs, true);

func _on_Organism_gap_selected(_gap, sel: bool):
	show_repair_types(sel);

func _on_Organism_gene_trimmed(_gene):
	STATS.increment_trimmedTiles()
	_refresh_repair_tab();

func _on_Organism_gene_bandaged(_gene):
	_refresh_repair_tab();

func _refresh_repair_tab():
	upd_repair_lock_display();
	yield(get_tree(), "idle_frame");
	show_repair_tab($RepairTabs.current_tab);

func upd_gap_select_instruction_visibility():
	$RepairTabs/pnl_repair_choices/vbox/LblInstr.visible = orgn.selected_gap == null;

func show_repair_types(show: bool) -> void:
	upd_repair_lock_display();
	var rep_pnl = $RepairTabs/pnl_repair_choices/hsplit;
	rep_pnl.visible = show;
	$RepairTabs/pnl_repair_choices/vbox.visible = !show;
	if show:
		var sel_idx := repair_type_to_idx(orgn.sel_repair_type);
		$RepairTabs/pnl_repair_choices/hsplit/ilist_choices.select(sel_idx);
		upd_repair_desc(sel_idx);

func _on_RepairTabs_tab_changed(idx: int):
	show_repair_tab(idx);

func show_repair_tab(tab_idx: int, upd_locks_disp := true) -> void:
	$RepairTabs.current_tab = tab_idx;
	if upd_locks_disp:
		upd_repair_lock_display();
	
	orgn.clear_repair_elm_selections();
	show_repair_types(false);
	match tab_idx:
		0:
			orgn.highlight_gap_choices();
		1, 2:
			if orgn.total_scissors_left > 0:
				continue;
		1:
			if orgn.get_behavior_profile().has_skill("trim_dmg_genes"):
				orgn.highlight_dmg_genes("scissors");
		2:
			if orgn.get_behavior_profile().has_skill("trim_gap_genes"):
				orgn.highlight_gap_end_genes();
		3:
			orgn.highlight_dmg_genes("bandage");

func _on_Organism_show_repair_opts(show):
	show_repair_opts(show);

func hide_repair_opts():
	close_extra_menus();

const REPAIR_DESC_FORMAT = "Cost:\n%s\n\n%s";
func get_repair_desc(type):
	var action_name = "";
	var tooltip = Tooltips.get_repair_desc(type);
	match (type):
		"collapse_dupes":
			action_name = "repair_cd";
		"copy_pattern":
			action_name = "repair_cp";
		"join_ends":
			action_name = "repair_je";
		var _err_idx:
			return "Error! Picked an invalid repair option (%s)!" % _err_idx;
	return REPAIR_DESC_FORMAT % [orgn.get_cost_string(action_name), tooltip];

func upd_repair_desc(idx):
	var type = repair_idx_to_type(idx);
	var btn = $RepairTabs/pnl_repair_choices/hsplit/vsplit/btn_apply_repair;
	orgn.change_selected_repair(type);
	btn.disabled = !orgn.repair_type_possible[type];
	btn.text = orgn.repair_btn_text[type];
	if btn.text.empty():
		btn.text = "Repair";
	$RepairTabs/pnl_repair_choices/hsplit/vsplit/scroll/lbl_choice_desc.text = get_repair_desc(type);

func _on_btn_apply_repair_pressed():
	$pnl_saveload.new_save(SaveExports.get_save_str(self));
	orgn.auto_repair();
	show_repair_types(false);

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

func _on_Organism_gap_close_msg(text):
	var t = "\n%s\n" % text;
	_add_justnow_bbcode(t);
	$RepairTabs/pnl_repair_choices/vbox/scroll/RTLRepairResult.text += t;

func _on_Organism_clear_gap_msg():
	$RepairTabs/pnl_repair_choices/vbox/scroll/RTLRepairResult.text = "";

func _on_Organism_bandage_msg(text):
	$RepairTabs/pnl_bandage_dmg/vbox/scroll/RTLRepairResult.text += "\n%s\n" % text;

func _on_Organism_updated_gaps(gaps_exist, gap_text):
	has_gaps = gaps_exist;
	if !$RepairTabs/pnl_repair_choices/vbox/LblInstr.visible:
		upd_gap_select_instruction_visibility();
		_on_Organism_gap_close_msg(gap_text);
	check_if_ready();

func _on_ilist_choices_item_activated(idx):
	orgn.apply_repair_choice(idx);
	show_repair_types(false);

# Next Turn button and availability

func upd_turn_display(upd_turn_unlocks: bool = Game.fresh_round, upd_env_markers: bool = Game.fresh_round):
	$lnum_turn.set_num(Game.round_num);
	$lnum_progeny.set_num(orgn.num_progeny);
	STATS.set_Rounds(Game.round_num)
	$TurnList.highlight(Game.turn_idx);
	
	if upd_turn_unlocks:
		$TurnList.check_unlocks();
	if upd_env_markers && orgn.current_tile.has("hazards"):
		ph_filter_panel.upd_current_ph_marker(orgn.current_tile.hazards["pH"]);

func _on_btn_nxt_pressed():
	STATS.set_gc_rep(orgn.get_behavior_profile().get_behavior("Replication"))
	STATS.set_gc_sens(orgn.get_behavior_profile().get_behavior("Sensing"))
	STATS.set_gc_loc(orgn.get_behavior_profile().get_behavior("Locomotion"))
	STATS.set_gc_help(orgn.get_behavior_profile().get_behavior("Helper"))
	STATS.set_gc_man(orgn.get_behavior_profile().get_behavior("Manipulation"))
	STATS.set_gc_comp(orgn.get_behavior_profile().get_behavior("Component"))
	STATS.set_gc_con(orgn.get_behavior_profile().get_behavior("Construction"))
	STATS.set_gc_decon(orgn.get_behavior_profile().get_behavior("Deconstruction"))
	STATS.set_gc_ate(orgn.get_behavior_profile().get_behavior("ate"))
	
	adv_turn();

func disable_turn(is_disabled: bool = true):
	disable_turn_adv = is_disabled
	
	if disable_turn_adv:
		nxt_btn.disabled = true
	else:
		nxt_btn.disabled = false

func adv_turn():
	orgn.iterate_genes()
	if !disable_turn_adv:
		close_extra_menus();
		var skip_turn = false
		if (Game.get_turn_type() == Game.TURN_TYPES.Recombination):
			for g in orgn.gene_selection:
				g.disable(true);
				
		if Game.get_next_turn_type() == Game.TURN_TYPES.Recombination:
			var recombos = orgn.get_recombos_per_turn()
			
			if recombos == 0:
				skip_turn = true
				
		
		Game.adv_turn(skip_turn);
		upd_turn_display();
		
		_add_justnow_bbcode("\n\n%s" % Game.get_turn_txt(), {"color": Color(1, 0.75, 0)});
		
		emit_signal("next_turn", Game.round_num, Game.turn_idx);
		$pnl_saveload.new_save(SaveExports.get_save_str(self));

func _on_animating_changed(state):
	wait_on_anim = state;
	check_if_ready();

func _on_Organism_doing_work(working):
	wait_on_select = working;
	check_if_ready();

func _on_Organism_died(org, reason):
	nxt_btn.visible = false;
	$button_grid/btn_qtmenu.visible = false;
	$button_grid/btn_nxt.visible = false;
	death_descr = reason;
	show_death_screen();

func show(enable_other_stuff: bool = true):
	.show();
	
	if enable_other_stuff:
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
	
	if is_visible_in_tree():
		if end_mapturn_on_mapscreen && !disable_turn_adv:
			nxt_btn.disabled = false;
		else:
			nxt_btn.disabled = orgn.is_dead() || wait_on_anim || wait_on_select || has_gaps || disable_turn_adv;
	else:
		nxt_btn.disabled = true;
	
	var auto_continue := true;
	match Game.get_turn_type():
		Game.TURN_TYPES.Recombination:
			auto_continue = false;
		Game.TURN_TYPES.RepairDmg:
			auto_continue = !orgn.has_damaged_genes();
	
	# Continue automatically if we can and should
	if !nxt_btn.disabled && auto_continue && !disable_turn_adv:
		$AutoContinue.start();

onready var central_menus := [$pnl_saveload, ph_filter_panel, $pnl_bugreport, temp_filter_panel, justnow_ctl, $RepairTabs, $pnl_reproduce];
onready var default_menu : Control = justnow_ctl;
func close_extra_menus(toggle_menu: Control = null, make_default := false) -> void:
	var restore_default = toggle_menu == null;
	for p in central_menus:
		if (p == toggle_menu):
			p.visible = !p.visible;
			if !p.visible:
				restore_default = true;
		else:
			p.visible = false;
	if make_default:
		if toggle_menu.visible:
			default_menu = toggle_menu;
		else:
			default_menu = justnow_ctl;
	if restore_default:
		default_menu.visible = true;

func show_chaos_anim():
	close_extra_menus($pnl_chaos);
	$pnl_chaos/Anim.play("show");

func hide_chaos_anim():
	$pnl_chaos/Anim.play("hide");

func _on_chaos_anim_finished(anim_name: String):
#	if anim_name == "hide":
#		show_replicate_opts(true);
	pass;

func play_recombination_slides():
	var slides = load("res://Scenes/CardTable/Recombination.tscn").instance()
	add_child(slides)
	slides.start()
	yield(slides, "exit_recombination_slides")
	remove_child(slides)
	slides.queue_free()
	pass

func play_mitosis_slides():
	var slides = load("res://Scenes/CardTable/Mitosis.tscn").instance()
	add_child(slides)
	slides.start()
	yield(slides, "exit_mitosis_slides")
	remove_child(slides)
	slides.queue_free()
	pass
	
func play_meiosis_slides():
	var slides = load("res://Scenes/CardTable/Meiosis.tscn").instance()
	add_child(slides)
	slides.start()
	yield(slides, "exit_meiosis_slides")
	remove_child(slides)
	slides.queue_free()
	pass

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

func _on_quit_to_menu_check_yes():
	STATS._reset_game()
	Game.restart_game()
	Settings.reset()
	get_tree().change_scene("res://Scenes/MainMenu/TitleScreen.tscn")

func _on_quit_to_menu_check_no():
	$pnl_quit_check.visible = false

func quit_to_menu():
	$pnl_quit_check.visible = true

const OVERVIEW_FORMAT = "Your organism %s.\n\nYou survived for %d rounds.\nYou produced %d progeny.\nYou repaired %d gaps.";
var death_descr := "died";
func show_death_screen():
	var gaps_repaired := 0;
	for rtype in ["repair_cp", "repair_cd", "repair_je"]:
		gaps_repaired += Unlocks.get_count(rtype);
	$ph_button.hide()
	$Temp_Button.hide()
	#$pnl_dead_overview/HSplitContainer/Panel/LblOverview.text = OVERVIEW_FORMAT % [death_descr, Game.round_num, orgn.num_progeny, gaps_repaired]
	$pnl_dead_overview.visible = true;
	$pnl_dead_overview.update_values();
	

func _on_Organism_finished_replication():
	reset_status_bar();
	status_bar.visible = true;

func refresh_visible_options():
	if ($RepairTabs/pnl_repair_choices/hsplit.visible):
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

func _on_pnl_temp_filter_update_seqelm_coloration(compare_type):
	for g in orgn.get_all_genes(true):
		g.color_comparison(compare_type, temp_filter_panel.get_temp_slider_value());

func _on_AutoContinue_timeout():
	adv_turn();

func _on_ViewMap_pressed():
	emit_signal("switch_to_map")

func _on_btn_bugreport_pressed():
	close_extra_menus($pnl_bugreport);
func _on_btn_load_pressed():
	SaveExports.flag_bug($pnl_bugreport/tbox_bugdesc.text);
	
	var title = $pnl_bugreport/tbox_bugtitle.text
	var description = $pnl_bugreport/tbox_bugdesc.text
	
	get_node("pnl_bugreport")._make_post_request(title, description)
	yield($pnl_bugreport/HTTPRequest, "request_completed")
	var response = get_node("pnl_bugreport").response
	var success = false
	if (response == 201):
		success = true
	
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

func _on_Organism_transposon_activity(active):
	if active:
		show_chaos_anim();
	else:
		hide_chaos_anim();


func _on_stats_screen_pressed():
	STATS.set_gc_rep(orgn.get_behavior_profile().get_behavior("Replication"))
	STATS.set_gc_loc(orgn.get_behavior_profile().get_behavior("Locomotion"))
	STATS.set_gc_help(orgn.get_behavior_profile().get_behavior("Helper"))
	STATS.set_gc_man(orgn.get_behavior_profile().get_behavior("Manipulation"))
	STATS.set_gc_sens(orgn.get_behavior_profile().get_behavior("Sensing"))
	STATS.set_gc_comp(orgn.get_behavior_profile().get_behavior("Component"))
	STATS.set_gc_con(orgn.get_behavior_profile().get_behavior("Construction"))
	STATS.set_gc_decon(orgn.get_behavior_profile().get_behavior("Deconstruction"))
	STATS.set_gc_ate(orgn.get_behavior_profile().get_behavior("ate"))
	

	emit_signal("card_stats_screen")
	pass # Replace with function body.


func _on_Button_pressed():
	emit_signal("card_stats_screen")
	pass # Replace with function body.

func _on_btn_filter_mouse_entered():
	$btn_filter/ph_details.show()
	pass # Replace with function body.


func _on_btn_filter_mouse_exited():
	$btn_filter/ph_details.hide()
	pass # Replace with function body.


func _on_btn_temp_mouse_entered():
	$btn_temp/temp_details.show()
	pass # Replace with function body.


func _on_btn_temp_mouse_exited():
	$btn_temp/temp_details.hide()
	pass # Replace with function body.


func _on_btn_temp_pressed():
	close_extra_menus(temp_filter_panel)


func _on_Temp_Button_mouse_entered():
	$Temp_Button/temp_details.show()
	pass # Replace with function body.

func _on_Temp_Button_mouse_exited():
	$Temp_Button/temp_details.hide()
	pass

func _on_Temp_Button_pressed():
	close_extra_menus(temp_filter_panel)
	pass


func _on_ph_button_mouse_entered():
	$ph_button/ph_details.show()
	pass # Replace with function body.


func _on_ph_button_mouse_exited():
	$ph_button/ph_details.hide()
	pass # Replace with function body.


func _on_ph_button_pressed():
	close_extra_menus(ph_filter_panel);
	pass # Replace with function body.


func _on_btn_qtmenu_pressed():
	STATS._reset_game()
	Game.restart_game()
	Settings.reset()
	get_tree().change_scene("res://Scenes/MainMenu/TitleScreen.tscn")
	$pnl_quit_check.hide()
	$pnl_dead_overview.hide()
	pass # Replace with function body.


func _on_yes_pressed():
	pass # Replace with function body.

#attempting to heal the damage imputed on a single gene all at once. 
func _on_fix_one_pressed():
	var one_fixed = false;
	for i in orgn.get_damaged_genes():
		if(one_fixed == false):
			orgn.bandage_elm(i);
			one_fixed = true;
		#print("damaged gene: "+str(i))
	#print("Fix one function called.")
	
	pass # Replace with function body.


func _on_fix_all_pressed():
	#print("Fix all genes function called")
	for i in orgn.get_damaged_genes():
		orgn.bandage_elm(i);
	pass # Replace with function body.
