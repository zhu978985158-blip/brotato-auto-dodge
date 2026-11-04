# GPL-3.0. Adds a controller-friendly settings entry to the in-game pause menu.
extends "res://ui/menus/ingame/ingame_main_menu.gd"

const PANEL_SCRIPT = preload("res://mods-unpacked/Tong-AutoDodge/ui/pause_settings.gd")

var _tong_settings_panel = null


func _ready() -> void:
	._ready()
	call_deferred("_tong_install_settings_entry")


func _tong_install_settings_entry() -> void:
	var buttons = get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer/ButtonsLeft")
	if buttons == null or buttons.get_node_or_null("TongAutoDodgeSettingsButton") != null:
		return
	var button := Button.new()
	button.name = "TongAutoDodgeSettingsButton"
	button.text = "自动战斗设置"
	button.rect_min_size = Vector2(300, 58)
	button.focus_mode = Control.FOCUS_ALL
	buttons.add_child(button)
	button.connect("pressed", self, "_tong_open_settings")

	var menu_parent = get_parent()
	if menu_parent == null:
		return
	_tong_settings_panel = PANEL_SCRIPT.new()
	_tong_settings_panel.name = "TongAutoDodgeSettingsPanel"
	menu_parent.add_child(_tong_settings_panel)
	_tong_settings_panel.setup()
	_tong_settings_panel.visible = false


func _tong_open_settings() -> void:
	if _tong_settings_panel == null:
		return
	visible = false
	_tong_settings_panel.open_for_menu(self)
