class_name YAMBoomerangProjectile
extends Projectile

const PROJECTILE_ADDITIONAL_DISTANCE = 100

export (bool) var enable_physics_process = false
export (int) var rotation_speed = 0


var weapon_stats:Resource
var spawn_position:Vector2

var _hit_max_range:bool

var player_index:int setget _set_player_index, _get_player_index
func _get_player_index()->int:
	return _hitbox.from.player_index
func _set_player_index(_v:int)->void :
	printerr("player_index is readonly")


func init()->void :
	_sprite.modulate.a = ProgressData.settings.projectile_opacity


func _ready()->void :
	set_physics_process(enable_physics_process)


func _get_origin()->Node:
	return _hitbox.from

	
func _physics_process(_delta:float)->void :
	rotation_degrees += rotation_speed
	var add_dist = PROJECTILE_ADDITIONAL_DISTANCE
	
	if ProgressData.is_manual_aim(player_index):
		add_dist = PROJECTILE_ADDITIONAL_DISTANCE / 2.0

	if not _hit_max_range and (global_position - spawn_position).length() > (weapon_stats.max_range + add_dist)*0.7:
		_hitbox.ignored_objects = []
		_hit_max_range = true
	
	if _hit_max_range:
		var lerp_forward = clamp((weapon_stats.projectile_speed - 500) / 20000 + 0.1, 0.4, 0.1)
		var return_target = _get_origin()
		var return_angle = (return_target.global_position - global_position).angle()
		velocity = Vector2.RIGHT.rotated(lerp_angle(velocity.angle(), return_angle, lerp_forward)) * weapon_stats.projectile_speed
		set_knockback_vector(Vector2.ZERO, 0.0, 0.0)
		
		if abs(global_position.distance_to(return_target.global_position)) < 120.0:
			set_to_be_destroyed()
			_do_boomerang_reload()
			



func set_effects(effects:Array)->void :
	_hitbox.effects = effects

	for effect in effects:
		if effect is ProjectilesOnHitEffect:
			var proj_weapon_stats = WeaponService.init_ranged_stats(effect.weapon_stats, _get_player_index(), true)
			_hitbox.projectiles_on_hit = [effect.value, proj_weapon_stats, effect.auto_target_enemy]


func _on_Hitbox_hit_something(thing_hit:Node, damage_dealt:int)->void :
	_hitbox.ignored_objects = [thing_hit]

	if weapon_stats.bounce > 0:
		bounce(thing_hit)
	elif weapon_stats.piercing <= 0:
		_hitbox.disable()
	else :
		_hitbox.enable()
		weapon_stats.piercing -= 1
		if _hitbox.damage > 0:
			_hitbox.damage = max(1, _hitbox.damage - (_hitbox.damage * weapon_stats.piercing_dmg_reduction))

	RunData.manage_life_steal(weapon_stats, _get_player_index())

	emit_signal("hit_something", thing_hit, damage_dealt)


func bounce(thing_hit:Node)->void :
	weapon_stats.bounce -= 1
	var target = thing_hit._entity_spawner_ref.get_rand_enemy()
	var direction = (target.global_position - global_position).angle() if target != null else rand_range( - PI, PI)
	velocity = Vector2.RIGHT.rotated(direction) * velocity.length()
	rotation = velocity.angle()
	weapon_stats.max_range = 99999
	set_knockback_vector(Vector2.ZERO, 0.0, 0.0)
	if _hitbox.damage > 0:
		_hitbox.damage = max(1, _hitbox.damage - (_hitbox.damage * weapon_stats.bounce_dmg_reduction))


func _on_Hitbox_critically_hit_something(_thing_hit:Node, _damage_dealt:int)->void :
	var remove_effects = []

	for effect in _hitbox.effects:
		if effect.key == "bounce_on_crit":

			weapon_stats.bounce += 1
			effect.value -= 1

			if effect.value <= 0:
				remove_effects.push_back(effect)
		elif effect.key == "pierce_on_crit":

			weapon_stats.piercing += 1
			effect.value -= 1

			if effect.value <= 0:
				remove_effects.push_back(effect)

	for effect in remove_effects:
		_hitbox.effects.erase(effect)

func _do_boomerang_reload():
	for effect in _hitbox.effects:
		if effect is YAMBoomerangReloadOnReturn:
			var from: Node = _hitbox.from
			if from is Weapon:
				from.do_boomerang_reload()
			else:
				from._cooldown = 0.0
