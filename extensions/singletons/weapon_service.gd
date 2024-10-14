extends "res://singletons/weapon_service.gd"

func init_ranged_stats(from_stats: RangedWeaponStats, player_index: int, is_special_spawn: = false, args: = WeaponServiceInitStatsArgs.new())->RangedWeaponStats:
	var new_stats = .init_ranged_stats(from_stats, player_index, is_special_spawn, args)
	
	var effects = args.effects
	
	for effect in effects:
		if effect is YAMWeaponProjectileSpeedForEveryStat:
			var bonus = RunData.get_scaling_bonus(effect.value, effect.stat_scaled, effect.nb_stat_scaled, effect.perm_stats_only, player_index)
			new_stats.projectile_speed += bonus
	
	return new_stats
