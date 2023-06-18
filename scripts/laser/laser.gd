tool
extends Sprite

# === Components and input ===
export(Constants.Spectrum) var spectrum setget _apply_spectrum
export(PackedScene) var ray_object

func _ready() -> void:
	# Create a laser beam ray
	var ray = ray_object.instance()
	ray.spectrum = spectrum
	ray.position.x = 90
	add_child(ray)


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
func _apply_spectrum(new_spectrum: int) -> void:
	spectrum = new_spectrum
	set_modulate(Constants.STANDARD_COLOR[spectrum])

	set_light_mask(1 << spectrum)
