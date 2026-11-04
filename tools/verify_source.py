# Static package checks; game behavior must be verified in Brotato.
from pathlib import Path
import json, zipfile, hashlib, re
root=Path(__file__).resolve().parents[1]
mod=root/'mods-unpacked/Tong-AutoDodge'
manifest=json.loads((mod/'manifest.json').read_text())
assert manifest['namespace']=='Tong'
assert manifest['name']=='AutoDodge'
assert manifest['version_number']=='0.2.0'
assert 'Oudstand-ModOptions' in manifest.get('extra', {}).get('godot', {}).get('optional_dependencies', [])
required=['mod_main.gd','bot/bot_runner.gd','bot/settings.gd','bot/potential_field.gd','bot/shop_strategy.gd','bot/build_profiles.gd','extensions/entities/units/movement_behaviors/player_movement_behavior.gd','extensions/ui/menus/ingame/ingame_main_menu.gd','ui/pause_settings.gd']
for rel in required: assert (mod/rel).is_file(), rel
runner=(mod/'bot/bot_runner.gd').read_text()
settings=(mod/'bot/settings.gd').read_text()
for option in ['auto_move','auto_buy_weapons','auto_buy_items','auto_level_up','auto_crate','auto_reroll','auto_sell_combine','auto_continue','gamepad_pause_button','manual_stick_deadzone','safety_hp_ratio','engage_distance_mult','boss_distance_mult','challenge_mode']:
    assert option in settings, option
for marker in ['_shop_action_allowed','_update_challenge','_update_hud','yield_to_human','KEY_F8','JOY_SELECT','JOY_START','is_human_movement_active']:
    assert marker in runner, marker
assert 'automation_safe' in runner
menu_extension=(mod/'extensions/ui/menus/ingame/ingame_main_menu.gd').read_text()
pause_settings=(mod/'ui/pause_settings.gd').read_text()
assert 'TongAutoDodgeSettingsButton' in menu_extension
assert 'open_for_menu' in pause_settings
assert 'ModLoader/Oudstand-ModOptions/ModOptions' in settings
assert 'current_move_vector = _field.compute_movement' in runner
assert 'BlackTriangle-FullAutoBot' not in ''.join(p.read_text(errors='ignore') for p in mod.rglob('*.gd'))
# Ensure all local preloads resolve inside the ZIP tree.
for p in mod.rglob('*.gd'):
    s=p.read_text()
    for path in re.findall(r'preload\("(res://mods-unpacked/Tong-AutoDodge/[^" ]+)"\)', s):
        assert root.joinpath(path.removeprefix('res://')).is_file(), (p,path)
print('manifest, options, control gates, challenge telemetry, preload paths: OK')
