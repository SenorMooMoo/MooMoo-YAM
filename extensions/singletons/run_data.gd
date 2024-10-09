extends "res://singletons/run_data.gd"

func add_stat(stat_name: String, value: int, player_index: int)->void :
	if not stat_name.begins_with("item_"):
		assert (Utils.is_stat_key(stat_name), "%s is not a stat key" % stat_name)
		.add_stat(stat_name, value, player_index)
	else:
		var item = ItemService.get_item_from_id(stat_name)
		for i in value:
			add_item(item, player_index)
