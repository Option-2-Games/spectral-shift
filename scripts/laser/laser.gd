tool
extends Sprite

# === Components and input ===
export(Constants.Spectrum) var spectrum
export(PackedScene) var ray_object

func _ready() -> void:
	# Disable light_only material in editor
	if Engine.editor_hint:
		set_material(null)

	# Create a laser beam ray
	var ray = ray_object.instance()
	ray.spectrum = spectrum
	ray.position.x = 90
	add_child(ray)