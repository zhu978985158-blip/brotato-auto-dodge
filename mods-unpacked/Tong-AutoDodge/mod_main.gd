# GPL-3.0. Modified 2026-09-22 from Full Auto Bot by Black Triangle.
extends Node

const LOG_NAME = "Tong:AutoDodge"
const RUNNER = preload("res://mods-unpacked/Tong-AutoDodge/bot/bot_runner.gd")

func _init():
	ModLoaderLog.info("Init", LOG_NAME)
	ModLoaderMod.install_script_extension(
		"res://mods-unpacked/Tong-AutoDodge/extensions/entities/units/movement_behaviors/player_movement_behavior.gd"
	)
	ModLoaderMod.install_script_extension(
		"res://mods-unpacked/Tong-AutoDodge/extensions/ui/menus/ingame/ingame_main_menu.gd"
	)

func _ready():
	var runner = RUNNER.new()
	runner.name = "TongCombatRunner"
	add_child(runner)
