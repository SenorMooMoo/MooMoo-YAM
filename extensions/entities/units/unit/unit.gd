extends "res://entities/units/unit/unit.gd"

var plasma_procs:Array

var plasma_mat = preload("res://mods-unpacked/MooMoo-YAM/content/resources/shaders/plasma_effect/plasma_shader_material.tres")
#var plasma_mat_modifier: float = 0.0

func _on_Hurtbox_area_entered(hitbox:Area2D)->void :
	if not hitbox.active or hitbox.ignored_objects.has(self):
		return 
	var dmg = hitbox.damage
	var dmg_taken = [0, 0]
	var from = hitbox.from if is_instance_valid(hitbox.from) else null
	var from_player_index = from.player_index if (from != null and "player_index" in from) else RunData.DUMMY_PLAYER_INDEX

	if hitbox.deals_damage:
		
		for effect_behavior in effect_behaviors.get_children():
			effect_behavior.on_hurt(hitbox)
		_on_hurt(hitbox)

		var is_exploding = false
		for effect in hitbox.effects:
			if effect is ExplodingEffect:
				if Utils.get_chance_success(effect.chance):
					var args: = WeaponServiceExplodeArgs.new()
					args.pos = global_position
					args.damage = hitbox.damage
					args.accuracy = hitbox.accuracy
					args.crit_chance = hitbox.crit_chance
					args.crit_damage = hitbox.crit_damage
					args.burning_data = hitbox.burning_data
					args.scaling_stats = hitbox.scaling_stats
					args.from_player_index = from_player_index
					args.is_healing = hitbox.is_healing

					var explosion = WeaponService.explode(effect, args)
					if from != null and from.has_method("on_weapon_hit_something"):
						explosion.connect("hit_something", from, "on_weapon_hit_something", [explosion._hitbox])

					is_exploding = true
			elif effect is PlayerHealthStatEffect and effect.key == "stat_damage":
				dmg += effect.get_bonus_damage(from_player_index)

		
		if not is_exploding:
			var args: = TakeDamageArgs.new(from_player_index, hitbox)
			dmg_taken = take_damage(dmg, args)
			if hitbox.burning_data != null and Utils.get_chance_success(hitbox.burning_data.chance) and not hitbox.is_healing and RunData.get_player_effect("can_burn_enemies", from_player_index) > 0:
				apply_burning(hitbox.burning_data)

		if hitbox.projectiles_on_hit.size() > 0:
			for i in hitbox.projectiles_on_hit[0]:
				var weapon_stats:RangedWeaponStats = hitbox.projectiles_on_hit[1]
				var auto_target_enemy:bool = hitbox.projectiles_on_hit[2]
				var args = WeaponServiceSpawnProjectileArgs.new()
				args.from_player_index = from_player_index
				var projectile = WeaponService.manage_special_spawn_projectile(
					self, 
					weapon_stats, 
					rand_range( - PI, PI), 
					auto_target_enemy, 
					_entity_spawner_ref, 
					from, 
					args
				)
				if from != null and from.has_method("on_weapon_hit_something"):
					projectile.connect("hit_something", from, "on_weapon_hit_something", [projectile._hitbox])

				projectile.call_deferred("set_ignored_objects", [self])

		if hitbox.plasma_effect_projectile.size() > 0:
			for i in hitbox.plasma_effect_projectile[0]:
				var weapon_stats:RangedWeaponStats = hitbox.plasma_effect_projectile[1]
				var auto_target_enemy:bool = hitbox.plasma_effect_projectile[2]
				var player: int = hitbox.plasma_effect_projectile[3]
				var new_dict:Dictionary = {
					"weapon_stats":weapon_stats,
					"auto_target_enemy":auto_target_enemy,
					"player":player}
				self.plasma_procs.append(new_dict)
				plasma_glow()
				
		if hitbox.speed_percent_modifier != 0:
			add_decaying_speed((get_base_speed_value_for_pct_based_decrease() * hitbox.speed_percent_modifier / 100.0) as int)

	hitbox.hit_something(self, dmg_taken[1])


func plasma_glow()->void :
	var is_already_glowing = sprite.material == plasma_mat
	if not is_already_glowing:
		_non_flash_material = plasma_mat
		sprite.material = plasma_mat
