class_name YAMDelayedParticleAcceleratorProjectile
extends DelayedPlayerProjectile

onready var end_container = $EndContainer
onready var start_container = $StartContainer
onready var contents = $Contents

onready var animation_player = $AnimationPlayer


func init()->void :
	animation_player.playback_speed = 2
	var sprite_w = _sprite.texture.get_width()
	var base_scale_x = max(1.0, float(weapon_stats.max_range) / float(sprite_w))
	var hitbox_scale_x = max(1.0, (weapon_stats.max_range + sprite_w * 2.0) / sprite_w)

	_sprite.scale.x = base_scale_x
	_hitbox.scale.x = hitbox_scale_x
	_hitbox.position.x = - sprite_w
	end_container.position.x = weapon_stats.max_range + sprite_w
	contents.position.x = sprite_w
	start_container.position.x = 0
