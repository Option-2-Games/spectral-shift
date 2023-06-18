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


func _physics_process(_delta):
	if is_colliding():
		_beam.set_point_position(1, get_collision_point() - global_position)
	else:
		_beam.set_point_position(1, Vector2.ZERO)


## Delete function
##
## Cascades a delete command down the chain
func delete() -> void:
	# Delete next ray first
	if next_ray:
		next_ray.delete()

	# Then delete self
	queue_free()
