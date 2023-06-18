tool
extends Sprite

# === Components and input ===
export(Constants.Spectrum) var spectrum setget _apply_spectrum
export(PackedScene) var ray_object


## Initialize laser emitter
func _ready() -> void:
	# Create a laser beam ray
	var ray = ray_object.instance()
	ray.spectrum = spectrum
	ray.set_global_position(get_global_position() + Vector2(90, 0))
	get_tree().get_current_scene().call_deferred("add_child", ray)


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
func _apply_spectrum(new_spectrum: int) -> void:
	spectrum = new_spectrum
	set_modulate(Constants.STANDARD_COLOR[spectrum])
	set_light_mask(1 << spectrum)
