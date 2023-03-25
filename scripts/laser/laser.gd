tool
extends Sprite

# === Components and input ===
export(Constants.Spectrum) var spectrum
export(Array, NodePath) var node_paths

# === Properties ===
var _rays: Array

# === Component Nodes ===
onready var _start_ray = get_node(node_paths[0]) as LaserRay
onready var _beam = get_node(node_paths[1]) as Line2D


func _ready() -> void:
	# Disable light_only material in editor
	if Engine.editor_hint:
		set_material(null)
		_beam.set_material(null)

	# Apply spectrum
	_apply_spectrum(spectrum)

	# Add start ray to rays
	_rays.append(_start_ray)


func _physics_process(_delta: float) -> void:
	if _start_ray.is_colliding():
		print("Collider: {}; Shape: {}; Location: {}".format([_start_ray.get_collider(), _start_ray.get_collider_shape(), _start_ray.get_collision_point()], "{}"))
	# Check for intersection
	# var intersected_ray = _start_ray



	# var intersected_ray_index: int
	# var intersected_point: Vector2
	# for ray_index in _rays.size():
	# 	var this_ray_collision = _rays[ray_index].get_collider()
	# 	if this_ray_collision:
	# 		intersected_ray_index = ray_index
	# 		intersected_point = _rays[ray_index].get_collision_point()
	# 		break

	# # Remove latter rays
	# var next_ray = _rays[intersected_ray_index + 1]
	# if next_ray:
	# 	next_ray.delete()

	# # Update laser beam point
	# _beam.set_point_position(intersected_ray_index + 1, intersected_point)


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
func _apply_spectrum(new_spectrum: int) -> void:
	spectrum = new_spectrum
	if _beam:
		# Set colors and light mask
		set_modulate(Constants.STANDARD_COLOR[spectrum])
		_beam.set_default_color(Constants.HIGHLIGHT_COLOR[spectrum])
		_beam.set_light_mask(1 << spectrum)
		_start_ray.set_collision_mask(1 << spectrum)
