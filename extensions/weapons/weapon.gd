extends "res://weapons/weapon.gd"

func do_boomerang_reload(base_reload_speed, multiplier) -> void:
	_current_cooldown = max(base_reload_speed - (tier * multiplier), 1)
	reset_cooldown()
	if stats.custom_on_cooldown_sprite != null:
		update_sprite(_original_sprite)
