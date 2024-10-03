extends "res://projectiles/player_projectile.gd"

func set_effects(effects:Array)->void :
	_hitbox.effects = effects

	for effect in effects:
		if effect is ProjectilesOnHitEffect:
			var proj_weapon_stats = WeaponService.init_ranged_stats(effect.weapon_stats, _get_player_index(), true)
			_hitbox.projectiles_on_hit = [effect.value, proj_weapon_stats, effect.auto_target_enemy]
		elif effect is YAMPlasmaEffect:
			var proj_weapon_stats = WeaponService.init_ranged_stats(effect.weapon_stats, _get_player_index(), true)
			_hitbox.plasma_effect_projectile = [effect.value, proj_weapon_stats, effect.auto_target_enemy, _get_player_index()]
