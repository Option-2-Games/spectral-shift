tool
class_name LaserReceiver
extends Mergable

# === Signals ===
signal receiver_hit(state)

# === Properties ===
var incident_rays: Array

# === Public Functions ===


func _init():
	print(spectrum)


## Function called by LaserRay when incident on a receiver
##
## @param from_ray: LaserRay that is incident
## @modifies: incident_rays
## @effects: adds from_ray to incident_rays if it does not exist
func hit(from_ray: LaserRay) -> void:
	# Notify about new hit
	emit_signal("receiver_hit", true)

	# Add incident ray if it does not exist
	if !incident_rays.has(from_ray):
		incident_rays.append(from_ray)


## Function called by LaserRay when a ray is no longer incident on a receiver
##
## @param from_ray: LaserRay that is no longer incident
## @modifies: incident_rays
## @effects: removes from_ray from incident_rays if it exists
func leave(from_ray: LaserRay) -> void:
	# Notify about laser leaving
	emit_signal("receiver_hit", false)

	# Remove incident ray if it exists
	if incident_rays.has(from_ray):
		incident_rays.erase(from_ray)
