class_name LaserRay
extends RayCast2D

## Handler for a ray in a laser

# === Component Paths ===
export(NodePath) var path_beam

# === Components and properties ===
var next_ray: LaserRay
var spectrum: int
var _prev_colliding_object = null

# === Component Nodes ===
onready var _beam = get_node(path_beam) as Line2D

# === System ===


## Initialize a ray in a laser
##
## Sets the color and layer masks based on the spectrum
func _ready() -> void:
	# Set color
	set_modulate(Constants.STANDARD_COLOR[spectrum])

	var spectrum_mask = Constants.PhysicsObjectType.INTERACTABLE << spectrum
	var mob_mask = Constants.PhysicsObjectType.MOB << spectrum

	# Set collision mask
	set_collision_mask(spectrum_mask | mob_mask)

	# Set beam light mask
	_beam.set_light_mask(spectrum_mask)


## Update laser position and next rays based on cast
##
## @modifies: next_ray
## @effects: updates the position and rotation of the next ray or deletes it
func _physics_process(_delta) -> void:
	if is_colliding():
		# Update beam extent to the collision point
		_beam.set_point_position(1, to_local(get_collision_point()))

		# Update next ray transform
		if next_ray:
			_update_next_ray_transform()

		# Shortcut exit if colliding object is same
		if _prev_colliding_object and _prev_colliding_object == get_collider():
			return

		# Un-collide with previous object first if needed
		if _prev_colliding_object and _prev_colliding_object != get_collider():
			_handle_leave_object_collision()

		# Handle new colliding object
		_handle_enter_object_collision()
		_prev_colliding_object = get_collider()
	else:
		# Extend beam to the full extent of the ray
		_beam.set_point_position(1, get_cast_to())

		# Remove next ray
		if next_ray:
			next_ray.delete()

		# Shortcut exit if there was no colliding object
		if not _prev_colliding_object:
			return

		# De-interact with colliding object
		_handle_leave_object_collision()


# === Public Functions ===


## Delete segment
##
## Cascades a delete command down the chain to future rays
##
## @modifies: self, next_ray
## @effects: deletes next ray and then deletes self
func delete() -> void:
	# Delete next ray first
	if next_ray:
		next_ray.delete()

	# Then delete self
	queue_free()


# === Private Functions ===


## Handle enter object collision
func _handle_enter_object_collision() -> void:
	var collision_object = get_collider()
	if collision_object.has_method("receiver_hit"):
		# Is colliding with a laser receiver
		collision_object.receiver_hit(self)
	if collision_object.is_in_group("mirror_reflector"):
		next_ray = duplicate(7)
		next_ray.spectrum = spectrum

		_update_next_ray_transform()

		get_tree().get_current_scene().call_deferred("add_child", next_ray)
		get_tree().get_current_scene().call_deferred("move_child", next_ray, 0)


## Handle leave object collision
##
## @modifies: _prev_colliding_object
## @effects: sets _prev_colliding_object to null
func _handle_leave_object_collision() -> void:
	if _prev_colliding_object.has_method("receiver_leave"):
		# Un-collide with a laser receiver
		_prev_colliding_object.receiver_leave(self)
	# Reset colliding object
	_prev_colliding_object = null


func _update_next_ray_transform() -> void:
	var incident_vector = Vector2(1, 0).rotated(get_rotation())
	var reflected_vector = incident_vector.bounce(get_collision_normal())
	next_ray.set_global_transform(
		Transform2D(reflected_vector.angle(), get_collision_point() + reflected_vector * 5)
	)
