extends "res://main.gd"

# Brief overview of what the changes in this file do...

const YAM_LOG = "MooMoo-Yam" # ! Change `MODNAME` to your actual mod's name


# Extensions
# =============================================================================

func _ready()->void:
	# ! Note that we're *not* calling `.return` here. This is because, unlike
	# ! all other vanilla funcs (eg `get_gold_bag_pos` below), _ready will
	# ! always fire, regardless of your code. In all other cases, we would still
	# ! need to call it

	# ! Note that you won't see this in the log immediately, because main.gd
	# ! doesn't run until you start a run
	ModLoaderUtils.log_info("Ready", YAM_LOG)

	# ! These are custom functions. It will run after vanilla's own _ready is
	# ! finished
	_modname_my_custom_edit_1()
	_modname_my_custom_edit_2()


# This is the name of a func in vanilla
func get_gold_bag_pos()->Vector2:
	# ! This calls vanilla's version of this func. The period (.) before the
	# func lets you call it without triggering an infinite loop. In this case,
	# we're calling the vanilla func to get the original value; then, we can
	# modify it to whatever we like
	var gold_bag_pos = .get_gold_bag_pos()

	# ! If a vanilla func returns something (just as this one returns a Vector2),
	# ! your modded funcs should also return something with the same type
	return gold_bag_pos

func _on_enemy_died(enemy:Enemy, args:Entity.DieArgs)->void :
	RunData.current_living_enemies -= 1

	if _update_stats_on_enemies_changed_timer != null and _update_stats_on_enemies_changed_timer.is_stopped():
		for player_index in RunData.get_player_count():
			if not LinkedStats.update_for_player_on_enemy_change[player_index]:
				continue
			reload_stats(player_index)
		_update_stats_on_enemies_changed_timer.start()

	if not _cleaning_up and args.enemy_killed_by_player:
		if enemy is Boss:
			_nb_bosses_killed_this_wave += 1

			if RunData.current_wave < RunData.nb_of_waves:
				_elite_killed = true

			var double_boss_active = RunData.sum_all_player_effects("double_boss") > 0
			if (_nb_bosses_killed_this_wave >= 2 or not double_boss_active) and RunData.current_wave == RunData.nb_of_waves:

				if RunData.is_endless_run:
					var additional_groups = ZoneService.get_additional_groups(int((RunData.current_wave / 10.0) * 3), 90)
					for i in additional_groups.size():
						additional_groups[i].spawn_timing = _wave_timer.wait_time - _wave_timer.time_left + i
					_wave_manager.add_groups(additional_groups)

				else :
					_wave_timer.wait_time = 0.1
					_wave_timer.start()

		var live_players: = _get_shuffled_live_players()

		for player in live_players:
			var player_index = player.player_index
			var dmg_when_death = RunData.get_player_effect("dmg_when_death", player_index)
			if dmg_when_death.size() > 0:
				var dmg_taken = handle_stat_damages(dmg_when_death, player_index)
				RunData.tracked_item_effects[player_index]["item_cyberball"] += dmg_taken[1]

		for player in live_players:
			var player_index = player.player_index
			var projectiles_on_death = RunData.get_player_effect("projectiles_on_death", player_index)
			for proj_on_death_effect in projectiles_on_death:
				for i in proj_on_death_effect[0]:
					var stats = proj_on_death_effect[1]

					var proj_on_death_stat_cache = _proj_on_death_stat_caches[player_index]
					if proj_on_death_stat_cache.has(i):
						stats = proj_on_death_stat_cache[i]
					else :
						stats = WeaponService.init_ranged_stats(proj_on_death_effect[1], player_index, true)
						proj_on_death_stat_cache[i] = stats

					var auto_target_enemy:bool = proj_on_death_effect[2]
					var from = player
					var spawn_projectile_args: = WeaponServiceSpawnProjectileArgs.new()
					spawn_projectile_args.from_player_index = player_index
					var _projectile = WeaponService.manage_special_spawn_projectile(
						enemy, 
						stats, 
						rand_range( - PI, PI), 
						auto_target_enemy, 
						_entity_spawner, 
						from, 
						spawn_projectile_args
					)
		for player in live_players:
			for plasma_proj in enemy.plasma_procs:
				var player_index = player.player_index
				if plasma_proj["player"] == player_index:
					var stats = plasma_proj["weapon_stats"]

					var proj_on_death_stat_cache = _proj_on_death_stat_caches[player_index]
					if proj_on_death_stat_cache.has(plasma_proj):
						stats = proj_on_death_stat_cache[plasma_proj]
					else :
						stats = WeaponService.init_ranged_stats(plasma_proj["weapon_stats"], player_index, true)
						proj_on_death_stat_cache[plasma_proj] = stats

					var auto_target_enemy:bool = plasma_proj["auto_target_enemy"]
					var from = player
					var spawn_projectile_args: = WeaponServiceSpawnProjectileArgs.new()
					spawn_projectile_args.from_player_index = player_index
					var _projectile = WeaponService.manage_special_spawn_projectile(
						enemy, 
						stats, 
						rand_range( - PI, PI), 
						auto_target_enemy, 
						_entity_spawner, 
						from, 
						spawn_projectile_args
					)
					
		for player in live_players:
			var player_index = player.player_index
			RunData.handle_explode_effect("explode_on_death", enemy.global_position, player_index)
			

		spawn_loot(enemy, EntityType.ENEMY)

		ProgressData.increment_stat("enemies_killed")

# Custom
# =============================================================================

func _modname_my_custom_edit_1()->void: # ! `void` means it doesn't return anything
	pass # ! Using `pass` here allows you to have a empty func without causing errors


func _modname_my_custom_edit_2()->void:
	ModLoaderUtils.log_info("Main.gd has been modified", YAM_LOG)
