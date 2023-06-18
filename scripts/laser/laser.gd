tool
extends Sprite

# === Components and input ===
export(Constants.Spectrum) var spectrum setget _apply_spectrum
export(PackedScene) var ray_object

# === Components ===
var ray: LaserRay

# === Properties ===
var _prev_position: Vector2
var _prev_rotation: float

# === System Functions ===


## Begin listening for transform changes
func _init() -> void:
	set_notify_transform(true)


## Notification handler
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		# Check if the transformation changed anything
		if get_position() != _prev_position or get_rotation() != _prev_rotation:
			# Delete previous ray
			if ray:
				ray.delete()

			# Create replacement
			_create_ray()

			# Update prev values
			_prev_position = get_position()
			_prev_rotation = get_rotation()


# === Private Functions ===


## Create the initial ray
func _create_ray() -> void:
	# Create a laser ray
	ray = ray_object.instance()

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
