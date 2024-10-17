class_name YAMBoomerangReloadOnReturn
extends NullDoubleValueEffect

# Value = Base reload speed, 60.0 == 1 second. Higher number = longer reload
# Value 2 = Multipler, multiplies this value by tier of weapon. Higher number = shorter reload
# Gets fed into Weapon.do_boomerang_reload(value,value2)

# Result = max(BaseReloadSpeed - (WeaponTier * Multiplier), 1)

static func get_id() -> String:
	return "yam_boomerang_reload_on_return"
