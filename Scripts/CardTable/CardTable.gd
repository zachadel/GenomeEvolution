extends Control

signal gene_clicked;
signal player_done;
signal switch_to_map
signal next_turn(turn_text, round_num);
signal card_stats_screen;
signal card_event_log;
signal add_card_event_log(content, tags);
signal show_pop_quiz;


onready var justnow_label : RichTextLabel = $ctl_justnow/lbl_justnow;
onready var orgn = $Organism;
onready var nxt_btn = $button_grid/btn_nxt;
onready var status_bar = $Border1/ChromosomeStatus;
onready var map_button = $Border2/button_control/map_image_button
onready var fixAllJoinEnds = $RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer/fixAllBreaksWJoinEnds
onready var fixAllCopyPattern = $RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer/fixAllBreaksWCopyPattern
onready var fixAllCollapseDupes = $RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer/fixAllBreaksWJoinEnds
onready var fixAll = $RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer/fix_all

onready var energy_bar = get_node("EnergyBar")
onready var notifications = get_node("CanvasLayer/Notifications")
onready var ph_filter_panel := $pnl_ph_filter;
onready var justnow_ctl := $ctl_justnow;
onready var temp_filter_panel := $pnl_temp_filter;

var passed_replication = false;
var has_gaps = false;
var wait_on_anim = false;
var wait_on_select = false;
var quiz_counter = 0;
var show_popUp = true;
var disable_turn_adv = true

func _ready():
	visible = false; # Prevents an auto-turn before the game begins
	orgn.setup(self);
	reset_status_bar();
	#$ViewMap.texture_normal = load(Game.get_large_cell_path(Game.current_cell_string))
	orgn.connect("show_warning", self, "_on_show_warning")
	orgn.connect("close_warning", self, "_on_hide_warning")
	
	connect("next_turn", orgn, "adv_turn");
	orgn.connect("energy_changed", energy_bar, "_on_Organism_energy_changed")
	$RepairTabs.set_tab_title(0, "Fix Genes"); #Fix Damaged Genes
	$RepairTabs.set_tab_title(1, "Repair Breaks");
	
	$RepairTabs.set_tab_title(2, "Trim Genes from Breaks");
	$RepairTabs.set_tab_title(3, "Trim Damaged Genes"); #Trim Damaged Genes
	#$RepairTabs.set_tab_icon(0, load("res://Assets/Images/Menus/Q_s.png"))
	$RepairTabs.set_tab_icon(0, load("res://Assets/Images/Menus/Q_s.png"))
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


func enable_serialized_buttons():
	#hide the locks
	$RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer2.visible = false
	$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer2.visible = false
	#Hide the pop up texts
	$RepairTabs/pnl_repair_choices/vbox/joinEndsHidden/Label.visible = false
	$RepairTabs/pnl_repair_choices/vbox/copyPatternHidden/Label.visible = false
	$RepairTabs/pnl_repair_choices/vbox/collapseDupesHidden/Label.visible = false
	$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer/fix_all/fix_all_details/Label.visible = false
	#enable the buttons
	$RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer/fixAllBreaksWJoinEnds.disabled = false
	$RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer/fixAllBreaksWCopyPattern.disabled = false
	$RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer/fixAllBreaksWCollapseDuplicates.disabled = false
	$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer/fix_all.disabled = false
	pass

func turn_to_repair():
	#Call the repair all function
	print("I want to be called at repair_dmg")


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
	passed_replication = true
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
		$RepairTabs.set_tab_icon(3, load("res://Assets/Images/Menus/Q_s.png"));
		trim_dmg_lbl.text += "Click a damaged gene to remove it.";
	else:
		$RepairTabs.set_tab_icon(3, load("res://Assets/Images/icons/padlock_small.png"));
		var needed_skill : Skills.Skill = Skills.get_skill("trim_dmg_genes");
		trim_dmg_lbl.text += "You are lacking the required '%s' %s skill to use this function." % [needed_skill.desc, needed_skill.behavior];
	trim_dmg_lbl.text += num_left_txt;
	
	var trim_end_lbl = $RepairTabs/pnl_rem_sides/LblInstr;
	trim_end_lbl.text = "\n\n";
	if orgn.get_behavior_profile().has_skill("trim_gap_genes"):
		$RepairTabs.set_tab_icon(2, load("res://Assets/Images/Menus/Q_s.png"))
		trim_end_lbl.text += "Click a gene on either ends of a break to remove the gene.";
	else:
		$RepairTabs.set_tab_icon(2, load("res://Assets/Images/icons/padlock_small.png"));
		var needed_skill : Skills.Skill = Skills.get_skill("trim_gap_genes");
		trim_end_lbl.text += "You are lacking the required '%s' %s skill to use this function." % [needed_skill.desc, needed_skill.behavior];
	trim_end_lbl.text += num_left_txt;

func show_repair_opts(show):
	if show:
		upd_repair_lock_display();
		#$RepairTabs/pnl_bandage_dmg/vbox/scroll/RTLRepairResult.text = "";
		#$pnl_log_module/VSplitContainer/ScrollContainer/outputLog.text = "";
		yield(get_tree(), "idle_frame");
		show_repair_tab(0);
	if $RepairTabs.visible != show:
		close_extra_menus($RepairTabs, true);

func _on_Organism_gap_selected(_gap, sel: bool):

	if(STATS.get_all_JE_unlocked() and fixAllJoinEnds != null):
		fixAllJoinEnds.disabled = false
		$RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer2/lock1.visible = false
	if(STATS.get_all_CD_unlocked() and fixAllCollapseDupes != null):
		fixAllCollapseDupes.disabled = false;
		$RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer2/lock3.visible = false
	if(STATS.get_all_CPR_unlocked() and fixAllCopyPattern != null):
		fixAllCopyPattern.disabled = false;
		$RepairTabs/pnl_repair_choices/vbox/VBoxContainer/HBoxContainer2/lock2.visible = false
	if(STATS.get_all_fix_damage_genes() and fixAll != null):
		fixAll.disabled = false;
		#$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer2/lock4.expand = true
		$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer2/lock4.visible = false
		#$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer2/lock4.rect_scale = Vector2(1, 1)
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
		1:
			orgn.highlight_gap_choices();
		0, 2:
			if orgn.total_scissors_left > 0:
				continue;
		0:
			orgn.highlight_dmg_genes("bandage");
		2:
			if orgn.get_behavior_profile().has_skill("trim_gap_genes"):
				orgn.highlight_gap_end_genes();
		3:
			if orgn.get_behavior_profile().has_skill("trim_dmg_genes"):
				orgn.highlight_dmg_genes("scissors");

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
	$WarningPopUp/Label.text = text
	emit_signal("add_card_event_log", "\n%s\n" % text, {})

func _on_Organism_gap_close_msg(text):
	var t = "\n%s\n" % text;
	_add_justnow_bbcode(t);
	$WarningPopUp/Label.text = t
	#$WarningPopUp.visible = true;
	#$RepairTabs/pnl_repair_choices/vbox/scroll/RTLRepairResult.text += t;
	emit_signal("add_card_event_log", t,{})
	
func _on_show_warning():
	$WarningPopUp.visible = true
	print("here")

func _on_hide_warning():
	$WarningPopUp.visible = false
	print("Hide warning called")
	


func _on_Organism_clear_gap_msg():
	#$RepairTabs/pnl_repair_choices/vbox/scroll/RTLRepairResult.text = "";
	#emit_signal("add_card_event_log", "clear board", "")
	pass


func _on_Organism_bandage_msg(text):
	#$RepairTabs/pnl_bandage_dmg/vbox/scroll/RTLRepairResult.text += "\n%s\n" % text;
	emit_signal("add_card_event_log", text,{})


func _on_Organism_updated_gaps(gaps_exist, gap_text):
	has_gaps = gaps_exist;
	if !$RepairTabs/pnl_repair_choices/vbox/LblInstr.visible:
		upd_gap_select_instruction_visibility();
		print("it got called")
		_on_Organism_gap_close_msg(gap_text);
	check_if_ready();

func _on_ilist_choices_item_activated(idx):
	orgn.apply_repair_choice(idx);
	show_repair_types(false);

# Next Turn button and availability

func upd_turn_display(upd_turn_unlocks: bool = Game.fresh_round, upd_env_markers: bool = Game.fresh_round):
	$lnum_turn.set_num(Game.round_num);
	$lnum_progeny.set_num(orgn.num_progeny);
	if Game.round_num >= STATS.get_rounds():
		STATS.set_Rounds(Game.round_num)
	
	print("game round: " + str(Game.round_num))
	$TurnList.highlight(Game.turn_idx);
	#print("organism thing: " + str(orgn.current_tile))
	
	if upd_turn_unlocks:
		$TurnList.check_unlocks();
	if upd_env_markers && orgn.current_tile.has("hazards"):
		ph_filter_panel.upd_current_ph_marker(orgn.current_tile.hazards["pH"]);

func _on_btn_nxt_pressed():
	$popUp/inputTimer.stop()
	passed_replication = false
	orgn.gene_val_with_temp()
	STATS.set_gc_rep(orgn.get_behavior_profile().get_behavior("Replication"))
	STATS.set_gc_sens(orgn.get_behavior_profile().get_behavior("Sensing"))
	STATS.set_gc_loc(orgn.get_behavior_profile().get_behavior("Locomotion"))
	STATS.set_gc_help(orgn.get_behavior_profile().get_behavior("Helper"))
	STATS.set_gc_man(orgn.get_behavior_profile().get_behavior("Manipulation"))
	STATS.set_gc_comp(orgn.get_behavior_profile().get_behavior("Component"))
	STATS.set_gc_con(orgn.get_behavior_profile().get_behavior("Construction"))
	STATS.set_gc_decon(orgn.get_behavior_profile().get_behavior("Deconstruction"))
	STATS.set_gc_ate(orgn.get_behavior_profile().get_behavior("ate"))
	
	#if STATS.get_rounds() % 2 == 1:
#		$pop_quiz.setup_q(quiz_counter)
#		$pop_quiz.visible = true#
#		quiz_counter += 1
		#We can change the values here to ask biology questions.
	#nxt_btn.add_color_override("font_color",Color(255,255,255,255))
	adv_turn();

func disable_turn(is_disabled: bool = true):
	disable_turn_adv = is_disabled
	
	if disable_turn_adv:
		nxt_btn.disabled = true
	else:
		nxt_btn.disabled = false
		
		

func flash_btn():
	var i = 0
	var iteration = 0
	if(nxt_btn.disabled == false):
		while(nxt_btn.pressed == false and iteration <= 20):
			#print("flash_btn")
			var every_other = 0;
			while(i < 255):
				every_other += 1
				nxt_btn.get_stylebox("Normal").modulate_color = Color(i,i,i,255)
				if(every_other %100 == 0):
					i+=1
			while(i > 0):
				if(every_other % 100 == 0):
					i-=1
				nxt_btn.add_color_override("font_color",Color(i,i,i,255))
				every_other += 1
			iteration += 1
	#print("out of shade fade")

func adv_turn():
	orgn.iterate_genes()
	if !disable_turn_adv:
		close_extra_menus();
		var skip_turn = false
		if (Game.get_turn_type() == Game.TURN_TYPES.Recombination):
			print("recombination")
			for g in orgn.gene_selection:
				g.disable(true);
				
		if Game.get_next_turn_type() == Game.TURN_TYPES.Recombination:
			var recombos = orgn.get_recombos_per_turn()
			
			if recombos == 0:
				skip_turn = true
		if(Game.get_turn_type() == Game.TURN_TYPES.RepairDmg and Game.get_next_turn_type() == Game.TURN_TYPES.Recombination):
			print("Step 4->5")
			if orgn.get_cmsm_pair().get_gap_list() != []:
				print("there's damage")
				notifications.emit_signal("notification_needed", "There are still some breaks that you need to mend.")
				$RepairTabs.current_tab = 3
				$RepairTabs/pnl_repair_choices.hide()
				$RepairTabs/pnl_bandage_dmg.show()
				#print("It should have happened.")
				skip_turn = true
			else:
				skip_turn = false
			
		if(Game.get_turn_type() == Game.TURN_TYPES.RepairDmg and Game.get_next_turn_type() == Game.TURN_TYPES.TEJump):
			print(Game.get_turn_type())
			print("here we are all over again.")
			if check_if_any_dmg_in_chromosomes():
				notifications.emit_signal("notification_needed", "There are still some harmed genes left you need to heal.")
				$RepairTabs.current_tab = 3
				$RepairTabs/pnl_repair_choices.hide()
				$RepairTabs/pnl_bandage_dmg.show()
				#print("It should have happened.")
				skip_turn = false
		Game.adv_turn(skip_turn); #What does this do
		upd_turn_display(); #What does this do?
		# updates the display information.
		_add_justnow_bbcode("\n\n%s" % Game.get_turn_txt(), {"color": Color(1, 0.75, 0)});
		emit_signal("add_card_event_log","\n\n%s" % Game.get_turn_txt(), {"color": Color(1, 0.75, 0)})
		
		#moves the game onto the next turn
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

#Replaced with normal button functionality for now
func set_map_btn_texture(texture_path: String) -> void:
#	var tex: Texture = load(texture_path);
#	$ViewMap.texture_normal = tex;
#	$ViewMap.texture_disabled = tex;
#	$ViewMap.texture_pressed = tex;
	pass

func check_if_ready():
	var end_mapturn_on_mapscreen = Game.get_turn_type() == Game.TURN_TYPES.Map && Unlocks.has_turn_unlock(Game.TURN_TYPES.Map);
	
	if is_visible_in_tree():
		if end_mapturn_on_mapscreen && !disable_turn_adv and check_if_any_dmg_in_chromosomes():
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
	print("close extra menus called")
	for p in central_menus:
		if (p == toggle_menu):
			p.visible = !p.visible;
			if !p.visible:
				restore_default = true;
		else:
			p.visible = false;
		
		if p == $RepairTabs:
			if p.visible == true:
			#	$q_s1.visible = true
				$q_s2.visible = true
				if $RepairTabs.get_tab_icon(2) == load("res://Assets/Images/Menus/Q_s.png"):
					$q_s3.visible = true
				if $RepairTabs.get_tab_icon(3) == load("res://Assets/Images/Menus/Q_s.png"):
					$q_s4.visible = true
			else:
	#			$q_s1.visible = false
				$q_s2.visible = false
				$q_s3.visible = false
				$q_s4.visible = false
	if $pnl_dead_overview.visible:
		$q_s2.visible = false
		$q_s3.visible = false
		$q_s4.visible = false
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

func play_replication_animation():
	var slides = load("res://Scenes/CardTable/ReplicationAnimation.tscn").instance()
	add_child(slides)
	slides.start()
	yield(slides, "exit_replication_slides")
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
	PROGENY.new_game()
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
	$Border2.hide()
	$Border1.hide()
	$Border3.hide()
	$Border4.hide()
	$q_s2.hide()
	$q_s2.visible = false;
	#$pnl_dead_overview/HSplitContainer/Panel/LblOverview.text = OVERVIEW_FORMAT % [death_descr, Game.round_num, orgn.num_progeny, gaps_repaired]
	$pnl_dead_overview.visible = true;
	$pnl_dead_overview.update_values();
	

func _on_Organism_finished_replication():
	reset_status_bar();
	status_bar.visible = true;

func _unhandled_input(event):
	
	pass


func refresh_visible_options():
	if ($RepairTabs/pnl_repair_choices/hsplit.visible):
		orgn.upd_repair_opts(orgn.sel_repair_gap);
		upd_repair_desc(orgn.sel_repair_idx);
	if ($pnl_reproduce.visible):
		upd_replicate_desc($pnl_reproduce/hsplit/ilist_choices.get_selected_items()[0]);

func _on_Organism_energy_changed(energy):
	$EnergyBar.update_energy_allocation(energy);
	#print("card table energy")
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
	#close_extra_menus($pnl_bugreport);
	$Turns_Check.visible = true
func _on_btn_load_pressed():
	SaveExports.flag_bug($pnl_bugreport/tbox_bugdesc.text);
	
	var title = $pnl_bugreport/tbox_bugtitle.text
	var description = $pnl_bugreport/tbox_bugdesc.text
	
	$pnl_bugreport._make_post_request(title, description)
	yield($pnl_bugreport/HTTPRequest, "request_completed")
	var response = get_node("pnl_bugreport").response
	print(str(response))
	var success = false
	if (response == 201):
		success = true
	
	$pnl_bugreport/tbox_bugdesc.text = "";
	close_extra_menus($pnl_bugreport);

func show_map_button():
	map_button.disabled = false;
	map_button.show()

func hide_map_button():
	map_button.disabled = true;
	
	# The cell should always be visible?
	#$ViewMap.hide()
	#$ViewMap/Label.hide()

func _on_Organism_transposon_activity(active):
	if active:
		show_chaos_anim();
	else:
		hide_chaos_anim();

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
	PROGENY.new_game()
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


func check_if_any_dmg_in_chromosomes():
	var list_dmg_genes = orgn.get_damaged_genes()
	#print("Length of damage genes list: " + str(len(list_dmg_genes)))
	if(len(list_dmg_genes) > 0):
		#print("SCREEEEEECH")
		return true
	return false
func _not_the_button():
	show_repairs()
	$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer/fix_all.disabled = false
	for i in orgn.get_damaged_genes():
		orgn.bandage_elm(i);
		#print("I: " + str(i))
	for i in orgn.get_damaged_genes():
		orgn.bandage_elm(i);
		#("I: " + str(i))
	$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer/fix_all.disabled = true
	show_choices()

func show_repairs():
	$RepairTabs.current_tab = 3

func show_choices():
	$RepairTabs.current_tab = 0

func _on_fix_all_pressed():
	for i in orgn.get_damaged_genes():
		orgn.bandage_elm(i);


func _on_fixAllBreaks_pressed(): #(This was created before the other buttons, therefore by default it is join ends.)
	#the name of this function may be misleading.
	#IT ONLY FIXES BREAKS THAT IT CAN IN FACT FIX WITH THAT TYPE OF CORRECTION
	#("fix all breaks pressed")
	auto_repair_all_breaks_join_end(orgn.get_cmsm_pair());
	pass # Replace with function body.

#this function takes in an array object and a number of choices and returns a new array of the size of the choices given and of a random content of the array passed in.
func auto_choose(objects: Array, num_choices: int = 1 ) -> Array:
	var outputArray =[];
	for i in range(num_choices):
		outputArray.append(objects[randi() % objects.size()])
	return outputArray;


#this is to automatically repair one break within the chromosome. 
#this also returns whether or not there were any gaps found in the chromosomes. If it is false, there were no gaps.
#if it returns true there were gaps. 
func auto_repair_all_breaks_join_end(cmsm_pair) -> bool:
	var num_gaps_found = 0;
	for i in cmsm_pair.get_all_genes():# gets a list of all the genes and iterates through them. 
		if(i.is_gap() ): #checks if the point is a gap in the chromosome
			num_gaps_found += 1;
			#These are needed to set the conditions for the organism to attempt a repair
			orgn.sel_repair_gap = i; 
			orgn.sel_repair_type = "join_ends";
			orgn.is_ai = true; #the ai option will automate choosing one of the genes to the left and the right of the selected gene.
			# This is needed for the organism to recognize what is an option to it
			orgn.upd_repair_opts(i)
			orgn.sel_repair_type = "join_ends"; #forces it to take the thing I want it to
			#attempts to repair the chromosome
			orgn.auto_repair()
			#updates UI
			show_repair_types(false);
			orgn.is_ai = false;
	if(num_gaps_found == 0):
		return false;
	else:
		return true;


func _on_fixAllBreaksWCollapseDuplicates_pressed():
	#the name of this function may be misleading.
	#IT ONLY FIXES BREAKS THAT IT CAN IN FACT FIX WITH THAT TYPE OF CORRECTION
	auto_repair_all_breaks_collapse_dupes(orgn.get_cmsm_pair())
	pass # Replace with function body.

func auto_repair_all_breaks_collapse_dupes(cmsm_pair) -> bool:
	var repair_priority = [];
	var num_gaps_found = 0;
	if(Unlocks.has_repair_unlock("join_ends")):
		repair_priority.append("join_ends"); #sets the priority of the lowest value in the array to join ends.
	if(Unlocks.has_repair_unlock("collapse_dupes")):
		repair_priority.append("collapse_dupes"); #sets the priority of the lowest value in the array to join ends.
	
	for i in cmsm_pair.get_all_genes():# gets a list of all the genes and iterates through them. 
		if(i.is_gap() ): #checks if the point is a gap in the chromosome
			num_gaps_found += 1;
			#These are needed to set the conditions for the organism to attempt a repair
			orgn.sel_repair_gap = i; 
			orgn.is_ai = true; #the ai option will automate choosing one of the genes to the left and the right of the selected gene.
			# This is needed for the organism to recognize what is an option to it
			var possible_outcome = orgn.default_collapse_dupes(i);
			#print("collapse dupes was: "+ str(possible_outcome))
			if(possible_outcome == true):
				#attempts to repair the chromosome
				orgn.auto_repair()
				show_repair_types(false);
			orgn.is_ai = false;
	if(num_gaps_found == 0):
		return false;
	else:
		return true;

func _on_fixAllBreaksWCopyPattern_pressed():
	#the name of this function may be misleading.
	#IT ONLY FIXES BREAKS THAT IT CAN IN FACT FIX WITH THAT TYPE OF CORRECTION
	auto_repair_all_breaks_copyPattern(orgn.get_cmsm_pair())
	pass # Replace with function body.
func auto_repair_all_breaks_copyPattern(cmsm_pair) -> bool:
	var repair_priority = [];
	var num_gaps_found = 0;
	if(Unlocks.has_repair_unlock("join_ends")):
		repair_priority.append("join_ends"); #sets the priority of the lowest value in the array to join ends.
	if(Unlocks.has_repair_unlock("copy_pattern")):
		repair_priority.append("copy_pattern"); #sets the priority of the lowest value in the array to join ends.
	
	for i in cmsm_pair.get_all_genes():# gets a list of all the genes and iterates through them. 
		if(i.is_gap() ): #checks if the point is a gap in the chromosome
			num_gaps_found += 1;
			#These are needed to set the conditions for the organism to attempt a repair
			orgn.sel_repair_gap = i; 
			orgn.is_ai = true; #the ai option will automate choosing one of the genes to the left and the right of the selected gene.
			# This is needed for the organism to recognize what is an option to it
			var possible_option = orgn.default_copy_pattern(i);
			#attempts to repair the chromosome
			if(possible_option == true):
				orgn.auto_repair()
				show_repair_types(false);
			
			orgn.is_ai = false;
	if(num_gaps_found == 0):
		return false;
	else:
		return true;


func _on_fix_all_mouse_entered():
	if (STATS.get_dmg_genes_error() + STATS.get_dmg_genes_no_error() < 20):
		$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer/fix_all/fix_all_details/Label.text = "You have "+ str(20 - STATS.get_dmg_genes_error() - STATS.get_dmg_genes_no_error())+ " many more gene repairs to perform until this can be unlocked"
	$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer/fix_all/fix_all_details.visible = true;
	pass # Replace with function body.


func _on_fix_all_mouse_exited():
	$RepairTabs/pnl_bandage_dmg/vbox/VBoxContainer/HBoxContainer/fix_all/fix_all_details.visible = false;
	pass # Replace with function body.


func _on_fixAllBreaksWJoinEnds_mouse_entered():
	if(STATS.get_total_JE() < 20):
		$RepairTabs/pnl_repair_choices/vbox/joinEndsHidden/Label.text = "You have "+str(20-STATS.get_total_JE()) + " more join ends to perform until this can be unlocked.";
	
	$RepairTabs/pnl_repair_choices/vbox/joinEndsHidden.visible = true;
	
	pass # Replace with function body.


func _on_fixAllBreaksWJoinEnds_mouse_exited():
	$RepairTabs/pnl_repair_choices/vbox/joinEndsHidden.visible = false;
	pass # Replace with function body.


func _on_fixAllBreaksWCopyPattern_mouse_entered():
	if(STATS.get_total_CPR() < 20):
		$RepairTabs/pnl_repair_choices/vbox/copyPatternHidden/Label.text = "You have "+str(20-STATS.get_total_CPR()) + " more copy repairs to perform until this can be unlocked.";
	$RepairTabs/pnl_repair_choices/vbox/copyPatternHidden.visible = true;
	pass # Replace with function body.


func _on_fixAllBreaksWCopyPattern_mouse_exited():
	$RepairTabs/pnl_repair_choices/vbox/copyPatternHidden.visible = false;
	pass # Replace with function body.


func _on_fixAllBreaksWCollapseDuplicates_mouse_entered():
	if(STATS.get_break_repaired_collapseDuplicates() < 20):
		$RepairTabs/pnl_repair_choices/vbox/collapseDupesHidden/Label.text = "You have "+ str(20-STATS.get_break_repaired_collapseDuplicates()) + " more collapse duplicates to perform until this can be unlocked."
	$RepairTabs/pnl_repair_choices/vbox/collapseDupesHidden.visible = true;
	pass # Replace with function body.


func _on_fixAllBreaksWCollapseDuplicates_mouse_exited():
	$RepairTabs/pnl_repair_choices/vbox/collapseDupesHidden.visible = false;
	pass # Replace with function body.


func _on_showLog_pressed():
	$pnl_log_module.show()
	pass # Replace with function body.


func _on_close_pressed():
	$pnl_log_module.hide()
	pass # Replace with function body.


func _on_btn_viewmap_pressed():
	
	pass # Replace with function body.


func _on_stats_image_button_pressed():
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


func _on_event_image_button_pressed():
	get_tree().paused = true
	emit_signal("card_event_log")
	pass # Replace with function body.


func _on_map_image_button_pressed():
	emit_signal("switch_to_map")
	pass # Replace with function body.


func _on_stats_image_button_mouse_entered():
	$stats_hidden.show()
	pass # Replace with function body.


func _on_stats_image_button_mouse_exited():
	$stats_hidden.hide()
	pass # Replace with function body.


func _on_event_image_button_mouse_entered():
	$diary_hidden.show()
	pass # Replace with function body.


func _on_event_image_button_mouse_exited():
	$diary_hidden.hide()
	pass # Replace with function body.


func _on_map_image_button_mouse_entered():
	$map_hidden.show()
	pass # Replace with function body.


func _on_map_image_button_mouse_exited():
	$map_hidden.hide()
	pass # Replace with function body.


func _on_lock4_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed : #ok, so here is where I will change the scene from cardtable to my slides. 
		#print("hello")
		var slides = load("res://Scenes/CardTable/fix_damaged_gene_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_fix_damaged_genes_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_lock1_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		#print("boop1")
		var slides = load("res://Scenes/CardTable/join_ends_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_join_ends_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_lock2_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		#print("boop2")
		var slides = load("res://Scenes/CardTable/copy_repair_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_copy_repair_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_lock3_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		#print('boop3')
		var slides = load("res://Scenes/CardTable/collapse_dupes_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_collapse_dupes_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_q_s2_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		#print("boop4")
		var slides = load("res://Scenes/CardTable/fix_damaged_gene_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_fix_damaged_genes_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_q_s3_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		print("boop5")
		var slides = load("res://Scenes/CardTable/trim_ends_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_trim_ends_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_q_s4_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		print("boop5")
		var slides = load("res://Scenes/CardTable/trim_dmg_genes_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_trim_dmg_genes_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_join_end_q_pressed():
	print("boop1")
	var slides = load("res://Scenes/CardTable/join_ends_slides.tscn").instance()
	add_child(slides)
	yield(slides, "exit_join_ends_slides")
	remove_child(slides)
	slides.queue_free()
	pass # Replace with function body.


func _on_copy_pat_q_pressed():
	print("boop2")
	var slides = load("res://Scenes/CardTable/copy_repair_slides.tscn").instance()
	add_child(slides)
	yield(slides, "exit_copy_repair_slides")
	remove_child(slides)
	slides.queue_free()
	pass # Replace with function body.


func _on_collaps_q_pressed():
	print('boop3')
	var slides = load("res://Scenes/CardTable/collapse_dupes_slides.tscn").instance()
	add_child(slides)
	yield(slides, "exit_collapse_dupes_slides")
	remove_child(slides)
	slides.queue_free()
	pass # Replace with function body.




func _on_go_to_survey_pressed():
	OS.shell_open("https://qfreeaccountssjc1.az1.qualtrics.com/jfe/form/SV_1SPZSQMgUxFOwrI")
	$Turns_Check.visible = false
	pass # Replace with function body.


func _on_btn_bugreport_toggled(button_pressed):
	
	pass # Replace with function body.


func _on_inputTimer_timeout():
	#print("Timer ran out")
	if show_popUp:
		$popUp.visible = true;
	pass # Replace with function body.


func _on_Exit_pop_pressed():
	$popUp.visible = false;
	pass # Replace with function body.


func _on_CheckBox_pressed():
	show_popUp = false
	pass # Replace with function body.


func _on_popUp_report_pressed():
	OS.shell_open("https://qfreeaccountssjc1.az1.qualtrics.com/jfe/form/SV_1SPZSQMgUxFOwrI")
	pass # Replace with function body.


func _on_slide_1_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var slides = load("res://Scenes/CardTable/fix_damaged_gene_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_fix_damaged_genes_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_slide_2_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var slides = load("res://Scenes/CardTable/join_ends_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_join_ends_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_slide_3_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var slides = load("res://Scenes/CardTable/copy_repair_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_copy_repair_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_slide_4_gui_input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var slides = load("res://Scenes/CardTable/collapse_dupes_slides.tscn").instance()
		add_child(slides)
		yield(slides, "exit_collapse_dupes_slides")
		remove_child(slides)
		slides.queue_free()
	pass # Replace with function body.


func _on_CardTable_gui_input(event):
	# print("event: " + str(event))
	$popUp/inputTimer.start(30)
	
	
		
	if event.is_action_pressed("mouse_left") :
		#$popUp/inputTimer.set_timer_process_mode(30)
		#print("timer started")
		$popUp/inputTimer.start(30)
	pass # Replace with function body.
