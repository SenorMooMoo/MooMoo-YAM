extends Area2D

onready var _collision: = $Hitbox as CollisionShape2D

var active = false
var bounce_target_list: Array = []

func set_range(range_stat) -> void:
	var shape = CircleShape2D.new()
	shape.radius = range_stat
	_collision.set_shape(shape)

func _on_BounceTargeterHitbox_body_entered(body) -> void:
	bounce_target_list.push_back(body)

func get_target_list():
	return bounce_target_list

func get_new_target(ignore_unit):
	for i in bounce_target_list:
		if i.dead == true:
			bounce_target_list.erase(i)
	var unit = _get_new_target(bounce_target_list, ignore_unit)
	return unit
	
func _get_new_target(list:Array, ignore_unit:Node2D = null):
	if list.size() <= 0 or (list.size() <= 1 and ignore_unit != null):
		return null
		
	var unit = Utils.get_rand_element(list)

	if ignore_unit != null and list.size() > 1:
		while unit == ignore_unit or unit.dead == true:
			unit = Utils.get_rand_element(list)

	return unit



