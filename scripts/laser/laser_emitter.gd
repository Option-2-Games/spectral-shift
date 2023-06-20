tool
extends Mergable

# === Components and Properties ===
export(bool) var is_on setget enable_emitter
export(PackedScene) var ray_object

# === Components ===
var ray: LaserRay

# === System Functions ===


## Setup emitter
func _init() -> void:
	# Listen for transform changes
	set_notify_transform(true)


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
	ray.set_global_transform(Transform2D(get_global_rotation(), to_global(Vector2(95, 0))))


## Turn on or off emitter
func enable_emitter(new_state: bool) -> void:
	is_on = new_state

	# Create or destroy ray
	if new_state:
		# Use deferred to avoid initialization before the scene is ready
		call_deferred("_create_ray")
	elif ray:
		ray.delete()
