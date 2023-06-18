class_name LaserRay
extends RayCast2D

## Handler for a ray in a laser

# === Component Paths ===
export(NodePath) var path_beam

# === Components and properties ===
var next_ray: LaserRay
var spectrum: int

# === Component Nodes ===
onready var _beam = get_node(path_beam) as Line2D


## Initialize a ray in a laser
func _ready() -> void:
	# Set color
	set_modulate(Constants.STANDARD_COLOR[spectrum])

	var spectrum_mask = 1 << spectrum

	# Set collision mask
	set_collision_mask(spectrum_mask)

	# Set beam light mask
	_beam.set_light_mask(spectrum_mask)


## Update laser position and next rays based on cast
func _physics_process(_delta) -> void:
	if is_colliding():
		_beam.set_point_position(1, to_local(get_collision_point()))
	else:
		_beam.set_point_position(1, Vector2.RIGHT * 1000)


## Delete function
##
## Cascades a delete command down the chain
func delete() -> void:
	# Delete next ray first
	if next_ray:
		next_ray.delete()

	# Then delete self
	queue_free()
