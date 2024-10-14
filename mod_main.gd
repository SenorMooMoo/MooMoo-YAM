extends Node

const YAM_DIR = "MooMoo-YAM/" # name of the folder that this file is in
const YAM_LOG = "MooMoo-YAM" # full ID of your mod (AuthorName-ModName)


var dir = ""
var ext_dir = ""
var trans_dir = ""

func _init() -> void:
	dir = ModLoaderMod.get_unpacked_dir().plus_file(YAM_DIR)
	# Add extensions
	install_script_extensions()
	# Add translations
	add_translations()
	ModLoaderUtils.log_info("Init", YAM_LOG)

	
func install_script_extensions() -> void:
	ext_dir = dir.plus_file("extensions")
	# extensions_dir_path = mod_dir_path.path_join("extensions") # Godot 4

		# ModLoaderMod.install_script_extension(extensions_dir_path.plus_file(...))
	ModLoaderMod.install_script_extension(ext_dir.plus_file("singletons/weapon_service.gd"))


func add_translations() -> void:
	trans_dir = dir.plus_file("translations")
		# ModLoaderMod.add_translation(translations_dir_path.plus_file(...))


func _ready()->void:
	ModLoaderUtils.log_info("Ready", YAM_LOG)

	var ContentLoader = get_node("/root/ModLoader/Darkly77-ContentLoader/ContentLoader")

	# Ranged_Weapons
	ContentLoader.load_data(dir + "/content_data/weapons/ranged/boomerang.tres", YAM_LOG)

	# ! This uses Godot's native `tr` func, which translates a string. You'll
	# ! find this particular string in the example CSV here: translations/modname.csv
	ModLoaderUtils.log_info(str("Translation Demo: ", tr("YAM is ready")), YAM_LOG)
