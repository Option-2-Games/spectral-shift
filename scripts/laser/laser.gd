tool
extends Sprite

# === Components and input ===
export(Constants.Spectrum) var spectrum setget _apply_spectrum
export(PackedScene) var ray_object


## Initialize laser emitter
func _ready() -> void:
	# Create a laser ray
	var ray = ray_object.instance()

	# Set ray spectrum, offset ray to emitter head, and set rotation
	ray.spectrum = spectrum
	ray.set_global_position(to_global(Vector2(90, 0)))
	ray.set_global_rotation(get_global_rotation())

	# Add to scene (and at bottom)
	get_tree().get_current_scene().call_deferred("add_child", ray)
	get_tree().get_current_scene().call_deferred("move_child", ray, 0)


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
func _apply_spectrum(new_spectrum: int) -> void:
	spectrum = new_spectrum
	set_modulate(Constants.STANDARD_COLOR[spectrum])
	set_light_mask(1 << spectrum)
