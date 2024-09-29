extends DelayedPlayerProjectile

func _on_SlowHitbox_hit_something(thing_hit:Node, _damage_dealt:int)->void :
	thing_hit.add_decaying_speed( - 250)
