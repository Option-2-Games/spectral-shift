tool
extends Sprite

# === Components and input ===
export(Constants.Spectrum) var spectrum setget _apply_spectrum
export(PackedScene) var ray_object

# === Components ===
var ray: LaserRay

# === System Functions ===


## Setup emitter
func _init() -> void:
	# Enable light-only material
	if not Engine.editor_hint:
		set_use_parent_material(false)

	# Listen for transform changes
	set_notify_transform(true)


## Setup laser
func _ready():
	_create_ray()


## Notification handler
func _notification(what: int) -> void:
	if ray and what == NOTIFICATION_TRANSFORM_CHANGED:
		# Update position and rotation
		_set_ray_transform()


# === Private Functions ===


## Create the initial ray
func _create_ray() -> void:
	# Create a laser ray
	ray = ray_object.instance()

	# Set ray spectrum and transform (to emitter head)
	ray.spectrum = spectrum
	_set_ray_transform()

	# Add to scene (and at bottom)
	get_tree().get_current_scene().call_deferred("add_child", ray)
	get_tree().get_current_scene().call_deferred("move_child", ray, 0)


## Set ray's position and rotation
func _set_ray_transform() -> void:
	ray.set_global_transform(Transform2D(get_global_rotation(), to_global(Vector2(90, 0))))


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
func _apply_spectrum(new_spectrum: int) -> void:
	spectrum = new_spectrum
	set_modulate(Constants.STANDARD_COLOR[spectrum])
	set_light_mask(1 << spectrum)
