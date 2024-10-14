extends "res://weapons/weapon.gd"

func do_boomerang_reload():
	_current_cooldown = 0.0
	reset_cooldown()
