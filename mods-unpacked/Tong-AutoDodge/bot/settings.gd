# Modified 2026-09-22 for independent automation controls. GPL-3.0.
# Based on Full Auto Bot by Black Triangle (HelpFreedom).
extends Reference
class_name TongAutoDodgeSettings

const MOD_ID := "Tong-AutoDodge"
const DEFAULTS := {
	"enabled": true,
	"preset": "手选成长",
	"auto_move": true,
	"auto_buy_weapons": false,
	"auto_buy_items": false,
	"auto_level_up": false,
	"auto_crate": false,
	"auto_reroll": false,
	"auto_sell_combine": false,
	"auto_continue": false,
	"gamepad_pause_button": "View/Share",
	"manual_stick_deadzone": 0.18,
	"safety_hp_ratio": 0.35,
	"engage_distance_mult": 1.0,
	"boss_distance_mult": 1.35,
	"challenge_mode": "无",
	"show_hud": true,
	"show_reason": true,
}

const PRESETS := {
	"手选成长": {
		"auto_move": true, "auto_buy_weapons": false, "auto_buy_items": false,
		"auto_level_up": false, "auto_crate": false, "auto_reroll": false,
		"auto_sell_combine": false, "auto_continue": false,
	},
	"半自动构筑": {
		"auto_move": true, "auto_buy_weapons": true, "auto_buy_items": true,
		"auto_level_up": false, "auto_crate": false, "auto_reroll": true,
		"auto_sell_combine": true, "auto_continue": true,
	},
	"全自动": {
		"auto_move": true, "auto_buy_weapons": true, "auto_buy_items": true,
		"auto_level_up": true, "auto_crate": true, "auto_reroll": true,
		"auto_sell_combine": true, "auto_continue": true,
	},
}

var api = null
var values := DEFAULTS.duplicate()
var _last_preset := ""
var _registered := false

func setup() -> void:
	api = _find_api()
	if api != null:
		_register_with_mod_options()
		_refresh_from_api()
	else:
		_load_fallback()
	_last_preset = str(values.get("preset", "手选成长"))

func refresh() -> void:
	if api == null:
		api = _find_api()
		if api != null:
			_register_with_mod_options()
	if api != null:
		_refresh_from_api()
	else:
		_load_fallback_once()
	var preset = str(values.get("preset", "手选成长"))
	if preset != _last_preset and PRESETS.has(preset):
		_apply_preset(preset)
		_last_preset = preset

func get_value(id: String, fallback = null):
	return values.get(id, fallback)

func get_bool(id: String, fallback := false) -> bool:
	return bool(get_value(id, fallback))

func get_float(id: String, fallback := 0.0) -> float:
	return float(get_value(id, fallback))


func set_option(id: String, value) -> void:
	if not DEFAULTS.has(id):
		return
	values[id] = value
	if api != null:
		api.set_value(MOD_ID, id, value)
	if id == "preset" and PRESETS.has(str(value)):
		_apply_preset(str(value))
		_last_preset = str(value)

func _find_api():
	var root = Engine.get_main_loop().get_root() if Engine.get_main_loop() != null else null
	if root == null:
		return null
	# Oudstand's current Mod Options package creates the manager as `ModOptions`.
	# Older builds/documentation called the same API `ModOptionsAPI`, so retain
	# the second path for compatibility with both package revisions.
	var api_node = root.get_node_or_null("ModLoader/Oudstand-ModOptions/ModOptions")
	if api_node != null:
		return api_node
	return root.get_node_or_null("ModLoader/Oudstand-ModOptions/ModOptionsAPI")

func _register_with_mod_options() -> void:
	if _registered:
		return
	var config = {
		"tab_title": "土豆兄弟自动战斗",
		"info_text": "独立控制自动走位、商店、升级和挑战统计。F8 可在战斗中暂停。",
		"options": [
			{"type":"toggle", "id":"enabled", "label":"启用自动战斗 Mod", "default":true},
			{"type":"dropdown", "id":"preset", "label":"预设", "choices":["手选成长","半自动构筑","全自动"], "default":"手选成长"},
			{"type":"toggle", "id":"auto_move", "label":"自动走位与躲避", "default":true},
			{"type":"toggle", "id":"auto_buy_weapons", "label":"自动购买武器", "default":false},
			{"type":"toggle", "id":"auto_buy_items", "label":"自动购买道具", "default":false},
			{"type":"toggle", "id":"auto_level_up", "label":"自动选择升级", "default":false},
			{"type":"toggle", "id":"auto_crate", "label":"自动选择宝箱", "default":false},
			{"type":"toggle", "id":"auto_reroll", "label":"自动重随", "default":false},
			{"type":"toggle", "id":"auto_sell_combine", "label":"自动出售与合成", "default":false},
			{"type":"toggle", "id":"auto_continue", "label":"自动进入下一波", "default":false},
			{"type":"dropdown", "id":"gamepad_pause_button", "label":"手柄自动控制开关", "choices":["View/Share","Start/Menu","关闭"], "default":"View/Share"},
			{"type":"slider", "id":"manual_stick_deadzone", "label":"手柄临时接管死区", "min":0.1, "max":0.5, "step":0.05, "default":0.18, "display_as_integer":false},
			{"type":"slider", "id":"safety_hp_ratio", "label":"低血量保命阈值", "min":0.1, "max":0.8, "step":0.05, "default":0.35, "display_as_integer":false},
			{"type":"slider", "id":"engage_distance_mult", "label":"常规安全距离倍率", "min":0.7, "max":1.8, "step":0.05, "default":1.0, "display_as_integer":false},
			{"type":"slider", "id":"boss_distance_mult", "label":"Boss 安全距离倍率", "min":1.0, "max":2.5, "step":0.05, "default":1.35, "display_as_integer":false},
			{"type":"dropdown", "id":"challenge_mode", "label":"挑战记录", "choices":["无","无伤波次","单武器族提醒","不重随记录","Boss 波记录"], "default":"无"},
			{"type":"toggle", "id":"show_hud", "label":"显示状态 HUD", "default":true},
			{"type":"toggle", "id":"show_reason", "label":"显示走位原因", "default":true},
		]
	}
	api.register_mod_options(MOD_ID, config)
	_registered = true

func _refresh_from_api() -> void:
	for id in DEFAULTS.keys():
		var v = api.get_value(MOD_ID, id)
		if v != null:
			values[id] = v

func _apply_preset(preset: String) -> void:
	var preset_values = PRESETS.get(preset, {})
	for id in preset_values.keys():
		values[id] = preset_values[id]
		if api != null:
			api.set_value(MOD_ID, id, preset_values[id])

var _fallback_loaded := false
func _load_fallback_once() -> void:
	if not _fallback_loaded:
		_load_fallback()

func _load_fallback() -> void:
	_fallback_loaded = true
	var file = File.new()
	var path := "user://tong_auto_dodge_settings.json"
	if not file.file_exists(path):
		return
	if file.open(path, File.READ) != OK:
		return
	var parsed = parse_json(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		for id in DEFAULTS.keys():
			if parsed.has(id): values[id] = parsed[id]
