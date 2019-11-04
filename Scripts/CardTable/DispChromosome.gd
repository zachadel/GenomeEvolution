extends Control

onready var cmsm = $container/scroll/cmsm setget ,get_cmsm;
var hidden = true;

onready var ChoiceBtnsCtl = $container/ChoiceButtons;
onready var ChoiceBtnsSizer = $container/ChoiceButtons/zIndexEnforce/BackColor;
onready var BtnCollapse = $container/ChoiceButtons/zIndexEnforce/BackColor/BtnCollapse;
onready var BtnChoose = $container/ChoiceButtons/zIndexEnforce/BackColor/BtnChoose;

onready var StatusBar = $container/StatusBar;

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

func show_choice_buttons(show):
	$container/ChoiceButtons.visible = show;
	lock(false);
	if (!show):
		color_compare();
	upd_size();

func lock(lock):
	BtnChoose.disabled = lock;
	if (lock):
		BtnChoose.text = "";
	else:
		BtnChoose.text = "Keep";

const SIZER_OFFSET = 13;
const SCROLL_MAX_WIDTH = 1550;
func upd_size(delay = true):
	if (delay):
		$update_delay.start();
	else:
		$container.rect_size.y = 0;
		rect_min_size.y = $container.rect_size.y + $container.rect_position.y;
		if ($container/scroll.visible):
			$container/scroll.rect_min_size.x = SCROLL_MAX_WIDTH - $container/scroll.rect_position.x;
		if (ChoiceBtnsSizer.visible):
			ChoiceBtnsSizer.rect_size.y = $container.rect_size.y + SIZER_OFFSET;

func _on_update_delay_timeout():
	upd_size(false);

func _on_cmsm_cmsm_changed():
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
