# GPL-3.0. Modified 2026-09-22 from Full Auto Bot by Black Triangle.
extends "res://entities/units/movement_behaviors/player_movement_behavior.gd"
var _tong_runner = null
func get_movement() -> Vector2:
	var human: Vector2 = .get_movement()
	if not is_instance_valid(_tong_runner):
		_tong_runner = get_tree().get_root().get_node_or_null("ModLoader/Tong-AutoDodge/TongCombatRunner")
	if _tong_runner == null or not _tong_runner.active:
		return human
	var human_active := human.length() > 0.05
	if _tong_runner.has_method("is_human_movement_active"):
		human_active = _tong_runner.is_human_movement_active(human)
	if human_active:
		_tong_runner.yield_to_human()
		return human
	return _tong_runner.current_move_vector
