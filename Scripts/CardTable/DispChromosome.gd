extends Control

onready var cmsm = $container/scroll/cmsm setget ,get_cmsm;
var hidden = true;

onready var ChoiceBtnsCtl := $container/ChoiceButtons;
onready var ChoiceBtnsBg : Panel = $container/ChoiceButtons/BackColor;
onready var ChoiceBtnsSizer : Control = $container/ChoiceButtons/Sizer;

onready var BtnCollapse : Button = $container/ChoiceButtons/Sizer/BtnCollapse;
onready var BtnChoose : Button = $container/RightsideSizer/BtnChoose;
onready var LblTitle := $container/ChoiceButtons/Sizer/LblTitle;
onready var CellImg : TextureRect = $container/RightsideSizer/CellImg;

onready var StatusBar := $container/StatusBar;

var linked_cmsm = null setget set_link;

signal elm_clicked(elm);
signal elm_mouse_entered(elm);
signal elm_mouse_exited(elm);

signal cmsm_picked(cmsm);
signal cmsm_hide(cmsm, hide);

signal on_cmsm_changed();

func _propogate_click(elm):
	emit_signal("elm_clicked", elm);

func _propagate_mouse_entered(elm):
	emit_signal("elm_mouse_entered", elm);

func _propagate_mouse_exited(elm):
	emit_signal("elm_mouse_exited", elm);

func _ready():
	CellImg.texture = load("res://Assets/Images/Cells/body/body_%s_large.svg" % Game.current_cell_string);
	StatusBar.add_cmsm(cmsm);
	StatusBar.update();
	upd_size();

func get_cmsm_list():
	return get_parent();

func get_cmsm():
	return cmsm;

func hide_cmsm(h = null, only_two = true):
	if (h == null):
		hidden = !hidden;
	else:
		hidden = h;
	
	StatusBar.visible = hidden;
	$container/scroll.visible = !hidden;
	
	if (hidden):
		BtnCollapse.text = "Show";
	else:
		BtnCollapse.text = "Hide";
	
	if (only_two):
		emit_signal("cmsm_hide", self, hidden);
	
	upd_size();
	var spec = get_parent().get_parent().get_parent().spectrum
	if spec != null: #code breaks if this isn't here, because in loading nothing is initialized. 
		if hidden :
			get_parent().get_parent().get_parent().spectrum.visible = true
			get_parent().get_parent().get_parent().indicators.visible = true
		else:
			get_parent().get_parent().get_parent().spectrum.visible = false
			get_parent().get_parent().get_parent().indicators.visible = false

func show_choice_buttons(show):
	$container/ChoiceButtons.visible = show;
	$container/RightsideSizer.visible = show;
	lock(false);
	if (!show):
		clear_link();
		color_compare();
	upd_size();

func lock(lock):
	BtnChoose.disabled = lock;
	BtnChoose.visible = !lock;
	CellImg.visible = !lock;
	$container/RightsideSizer.mouse_filter = Control.MOUSE_FILTER_IGNORE if lock else Control.MOUSE_FILTER_STOP;

const SIZER_OFFSET = 13;
func upd_size(delay := true):
	if delay:
		$update_delay.start();
	else:
		$container.rect_size.y = 0;
		rect_min_size.y = $container.rect_size.y + $container.rect_position.y;
		if (ChoiceBtnsSizer.visible):
			var sizer_y = $container.rect_size.y + SIZER_OFFSET;
			ChoiceBtnsSizer.rect_size.y = sizer_y;
			
			if (linked_cmsm == null):
				set_sizers_height(sizer_y);
			else:
				upd_link_vis();

func set_sizers_height(h: float) -> void:
	ChoiceBtnsBg.rect_size.y = h;
	CellImg.rect_size.y = h;

func set_title(title: String) -> void:
	LblTitle.text = title;

func upd_link_vis(delay := true):
	if delay:
		$update_link_delay.start();
	else:
		if ChoiceBtnsBg.visible:
			var offset_idx = $container/RightsideSizer.get_index();
			get_last_visible_item(offset_idx).rect_min_size.x = linked_cmsm.get_last_visible_item(offset_idx).rect_size.x;
			set_sizers_height(linked_cmsm.get_global_bottom() - ChoiceBtnsBg.get_global_rect().position.y);
		else:
			linked_cmsm.upd_link_vis();

func get_last_visible_item(before_idx: int) -> Control:
	var contr : HBoxContainer = $container;
	for i in range(before_idx - 1, -1, -1):
		if contr.get_child(i).visible:
			return (contr.get_child(i) as Control);
	return null;

func clear_link():
	if (linked_cmsm != null):
		linked_cmsm.set_link(null);
	set_link(null);

func set_link(cmsm):
	ChoiceBtnsBg.visible = true;
	linked_cmsm = cmsm;
	if (cmsm != null):
		cmsm._child_link(self);
		upd_link_vis();

func _child_link(cmsm):
	ChoiceBtnsBg.visible = false;
	linked_cmsm = cmsm;
	lock(true);
	upd_link_vis();

func get_global_bottom() -> float:
	var r := ChoiceBtnsSizer.get_global_rect();
	return r.position.y + r.size.y;

func _on_update_delay_timeout():
	upd_size(false);

func _on_update_link_delay_timeout():
	upd_link_vis(false);

func _on_cmsm_cmsm_changed():
	emit_signal("on_cmsm_changed");
	StatusBar.update();
	upd_size();

func _on_BtnCollapse_pressed():
	hide_cmsm();

func _on_BtnChoose_pressed():
	emit_signal("cmsm_picked", self);

func color_compare(other_cmsm = null):
	if (other_cmsm == null):
		StatusBar.color_comparison(null);
	else:
		StatusBar.color_comparison(other_cmsm.StatusBar);
