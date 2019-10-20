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

func hide_cmsm(h = null):
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
	
	emit_signal("cmsm_hide", self, hidden);
	upd_size();

func show_choice_buttons(show):
	$scroll/container/BtnChoose.visible = show;
	$scroll/container/BtnCollapse.visible = show;

func upd_size():
	$container.rect_size.y = 0;
	rect_min_size.y = $container.rect_size.y + $container.rect_position.y;
	if ($container/scroll.visible):
		$container/scroll.rect_min_size.x = cmsm.rect_size.x;

func _on_cmsm_cmsm_changed():
	$container/StatusBar.update();
	upd_size();

func _on_BtnCollapse_pressed():
	hide_cmsm();

func _on_BtnChoose_pressed():
	emit_signal("cmsm_picked", get_cmsm());
