# GPL-3.0. Compact controller-friendly settings panel shown from the pause menu.
extends PanelContainer

const RUNNER_PATH := "ModLoader/Tong-AutoDodge/TongCombatRunner"

var _runner = null
var _return_menu = null
var _controls = {}
var _value_labels = {}
var _updating := false


func setup() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	_runner = get_tree().get_root().get_node_or_null(RUNNER_PATH)
	_tong_layout()


func _tong_layout() -> void:
	anchor_left = 0.08
	anchor_top = 0.06
	anchor_right = 0.92
	anchor_bottom = 0.94
	margin_left = 0
	margin_top = 0
	margin_right = 0
	margin_bottom = 0

	var margin := MarginContainer.new()
	margin.add_constant_override("margin_left", 24)
	margin.add_constant_override("margin_top", 18)
	margin.add_constant_override("margin_right", 24)
	margin.add_constant_override("margin_bottom", 18)
	add_child(margin)
	var root_box := VBoxContainer.new()
	margin.add_child(root_box)

	var title := Label.new()
	title.text = "自动战斗设置（暂停期间修改，手柄可直接导航）"
	title.rect_min_size = Vector2(0, 42)
	root_box.add_child(title)
	var hint := Label.new()
	hint.text = "默认手选成长：只自动走位；关闭的项目会停留在对应界面。"
	root_box.add_child(hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.add_child(scroll)
	var options_box := VBoxContainer.new()
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(options_box)

	_add_dropdown(options_box, "预设", "preset", ["手选成长", "半自动构筑", "全自动"])
	_add_toggle(options_box, "启用自动战斗 Mod", "enabled")
	_add_toggle(options_box, "自动走位与躲避", "auto_move")
	_add_toggle(options_box, "自动购买武器", "auto_buy_weapons")
	_add_toggle(options_box, "自动购买道具", "auto_buy_items")
	_add_toggle(options_box, "自动选择升级", "auto_level_up")
	_add_toggle(options_box, "自动选择宝箱", "auto_crate")
	_add_toggle(options_box, "自动重随", "auto_reroll")
	_add_toggle(options_box, "自动出售与合成", "auto_sell_combine")
	_add_toggle(options_box, "自动进入下一波", "auto_continue")
	_add_dropdown(options_box, "手柄自动控制开关", "gamepad_pause_button", ["View/Share", "Start/Menu", "关闭"])
	_add_slider(options_box, "手柄临时接管死区", "manual_stick_deadzone", 0.1, 0.5, 0.05)
	_add_slider(options_box, "低血量保命阈值", "safety_hp_ratio", 0.1, 0.8, 0.05)
	_add_slider(options_box, "常规安全距离倍率", "engage_distance_mult", 0.7, 1.8, 0.05)
	_add_slider(options_box, "Boss 安全距离倍率", "boss_distance_mult", 1.0, 2.5, 0.05)
	_add_dropdown(options_box, "挑战记录", "challenge_mode", ["无", "无伤波次", "单武器族提醒", "不重随记录", "Boss 波记录"])
	_add_toggle(options_box, "显示状态 HUD", "show_hud")
	_add_toggle(options_box, "显示走位原因", "show_reason")

	var close_button := Button.new()
	close_button.text = "返回暂停菜单"
	close_button.rect_min_size = Vector2(0, 54)
	close_button.focus_mode = Control.FOCUS_ALL
	close_button.connect("pressed", self, "close_panel")
	root_box.add_child(close_button)
	_controls["_close"] = close_button


func _add_toggle(parent: VBoxContainer, label_text: String, id: String) -> void:
	var control := CheckButton.new()
	control.text = label_text
	control.pressed = bool(_read_value(id, false))
	control.focus_mode = Control.FOCUS_ALL
	control.connect("toggled", self, "_on_toggle", [id])
	parent.add_child(control)
	_controls[id] = control


func _add_dropdown(parent: VBoxContainer, label_text: String, id: String, choices: Array) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.rect_min_size = Vector2(300, 42)
	row.add_child(label)
	var control := OptionButton.new()
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.focus_mode = Control.FOCUS_ALL
	var selected := 0
	for i in range(choices.size()):
		control.add_item(str(choices[i]))
		if str(choices[i]) == str(_read_value(id, choices[0])):
			selected = i
	control.select(selected)
	control.connect("item_selected", self, "_on_dropdown", [id, choices])
	row.add_child(control)
	parent.add_child(row)
	_controls[id] = control


func _add_slider(parent: VBoxContainer, label_text: String, id: String, min_value: float, max_value: float, step_value: float) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.rect_min_size = Vector2(300, 42)
	row.add_child(label)
	var control := HSlider.new()
	control.min_value = min_value
	control.max_value = max_value
	control.step = step_value
	control.value = float(_read_value(id, min_value))
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.focus_mode = Control.FOCUS_ALL
	row.add_child(control)
	var value_label := Label.new()
	value_label.text = "%.2f" % control.value
	value_label.rect_min_size = Vector2(70, 42)
	row.add_child(value_label)
	control.connect("value_changed", self, "_on_slider", [id, value_label])
	parent.add_child(row)
	_controls[id] = control
	_value_labels[id] = value_label


func _read_value(id: String, fallback):
	if _runner != null and _runner.has_method("get_setting_value"):
		return _runner.get_setting_value(id, fallback)
	return fallback


func _write_value(id: String, value) -> void:
	if _runner != null and _runner.has_method("set_setting_value"):
		_runner.set_setting_value(id, value)


func _on_toggle(value: bool, id: String) -> void:
	if not _updating:
		_write_value(id, value)


func _on_dropdown(index: int, id: String, choices: Array) -> void:
	if _updating or index < 0 or index >= choices.size():
		return
	_write_value(id, choices[index])
	if id == "preset":
		_sync_controls()


func _on_slider(value: float, id: String, value_label: Label) -> void:
	value_label.text = "%.2f" % value
	if not _updating:
		_write_value(id, value)


func _sync_controls() -> void:
	_updating = true
	for id in ["enabled", "auto_move", "auto_buy_weapons", "auto_buy_items", "auto_level_up", "auto_crate", "auto_reroll", "auto_sell_combine", "auto_continue", "show_hud", "show_reason"]:
		if _controls.has(id):
			_controls[id].pressed = bool(_read_value(id, false))
	for id in ["preset", "gamepad_pause_button", "challenge_mode"]:
		if not _controls.has(id):
			continue
		var control = _controls[id]
		for i in range(control.get_item_count()):
			if control.get_item_text(i) == str(_read_value(id, "")):
				control.select(i)
	for id in ["manual_stick_deadzone", "safety_hp_ratio", "engage_distance_mult", "boss_distance_mult"]:
		if _controls.has(id):
			_controls[id].value = float(_read_value(id, _controls[id].value))
			_value_labels[id].text = "%.2f" % _controls[id].value
	_updating = false


func open_for_menu(menu) -> void:
	_return_menu = menu
	_runner = get_tree().get_root().get_node_or_null(RUNNER_PATH)
	_sync_controls()
	visible = true
	if _controls.has("preset"):
		_controls["preset"].grab_focus()


func close_panel() -> void:
	visible = false
	if is_instance_valid(_return_menu):
		_return_menu.visible = true
		var button = _return_menu.get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer/ButtonsLeft/TongAutoDodgeSettingsButton")
		if button != null:
			button.grab_focus()


func _input(event) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		close_panel()
		get_tree().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_1:
		close_panel()
		get_tree().set_input_as_handled()
