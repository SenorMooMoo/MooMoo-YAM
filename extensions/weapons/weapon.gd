extends "res://weapons/weapon.gd"

func do_boomerang_reload():
	_current_cooldown = 60
	reset_cooldown()
