@tool
extends Mergable

# === Components and Properties ===
@export var is_on: bool:
	set = enable_emitter
@export var ray_object: PackedScene

# === Components ===
var ray: LaserRay

# === System Functions ===


## Setup emitter
##
## @modifies: notify_transform
## @effects: sets notify_transform to true
func _init() -> void:
	# Listen for transform changes
	set_notify_transform(true)


## Notification handler
##
## @param what: Notification type
func _notification(what: int) -> void:
	if ray and what == NOTIFICATION_TRANSFORM_CHANGED:
		# Update position and rotation
		_set_ray_transform()


# === Private Functions ===


## Create the initial ray
##
## @modifies: ray
## @effects: creates the initial ray object
func _create_ray() -> void:
	# Create a laser ray
	ray = ray_object.instantiate()

	# Set ray spectrum and transform (to emitter head)
	ray.spectrum = spectrum
	_set_ray_transform()

	# Add to scene (and at bottom)
	get_tree().get_current_scene().call_deferred("add_child", ray)
	get_tree().get_current_scene().call_deferred("move_child", ray, 0)


## Set ray's position and rotation
##
## @modifies: ray
## @effects: sets the position and rotation of the ray
func _set_ray_transform() -> void:
	ray.set_global_transform(Transform2D(get_global_rotation(), to_global(Vector2(95, 0))))


## Turn on or off emitter
##
## @param new_state: New on/off state
## @modifies: is_on
## @effects: sets is_on based on state
func enable_emitter(new_state: bool) -> void:
	# Set new state
	is_on = new_state

	# Shortcut exit if not in play mode
	if Engine.is_editor_hint():
		return

	# Create or destroy ray
	if new_state:
		# Use deferred to avoid initialization before the scene is ready
		call_deferred("_create_ray")
	elif ray:
		ray.delete()
