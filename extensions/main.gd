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
	._on_enemy_died(enemy, args)
	
	if _cleaning_up or not args.enemy_killed_by_player:
		return

#
	var live_players: = _get_shuffled_live_players()

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

# Custom
# =============================================================================

func _modname_my_custom_edit_1()->void: # ! `void` means it doesn't return anything
	pass # ! Using `pass` here allows you to have a empty func without causing errors


func _modname_my_custom_edit_2()->void:
	ModLoaderUtils.log_info("Main.gd has been modified", YAM_LOG)
