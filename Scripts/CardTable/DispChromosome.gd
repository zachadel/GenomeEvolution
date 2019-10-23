extends Control

onready var cmsm = $container/scroll/cmsm setget ,get_cmsm;
var hidden = true;

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
	$container/StatusBar.add_cmsm(cmsm);
	$container/StatusBar.update();
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
	
	$container/StatusBar.visible = hidden;
	$container/scroll.visible = !hidden;
	
	if (hidden):
		$container/BtnCollapse.text = "Show";
	else:
		$container/BtnCollapse.text = "Hide";
	
	if (only_two):
		emit_signal("cmsm_hide", self, hidden);
	upd_size();

func show_choice_buttons(show):
	$container/BtnChoose.visible = show;
	$container/BtnCollapse.visible = show;

func lock(lock):
	$container/BtnChoose.disabled = lock;
	if (lock):
		$container/BtnChoose.text = "";
	else:
		$container/BtnChoose.text = "Keep";

const SCROLL_MAX_WIDTH = 1550;
func upd_size():
	$container.rect_size.y = 0;
	rect_min_size.y = $container.rect_size.y + $container.rect_position.y;
	if ($container/scroll.visible):
		$container/scroll.rect_min_size.x = SCROLL_MAX_WIDTH - $container/scroll.rect_position.x;

func _on_cmsm_cmsm_changed():
	$container/StatusBar.update();
	upd_size();

func _on_BtnCollapse_pressed():
	hide_cmsm();

func _on_BtnChoose_pressed():
	emit_signal("cmsm_picked", self);