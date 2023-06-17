class_name LaserRay
extends RayCast2D

## Handler for a ray in a laser

# === Component Paths ===

# === Components and properties ===
var next_ray: LaserRay
var beam: Line2D
var beam_endpoint_index: int


## Delete function
##
## Cascades a delete command down the chain
func delete() -> void:
	# Delete next ray first
	if next_ray:
		next_ray.delete()

	# Then delete self
	beam.remove_point(beam_endpoint_index)
	queue_free()
