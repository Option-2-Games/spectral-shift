tool
extends Mergable

# === Signals ===

## Called when the receiver state changes
##
## @param state: New state (true for on, false for off)
signal receiver_active(state)

# === Properties ===
var incident_rays: Array

# === Public Functions ===


## Function called by LaserRay when incident on a receiver
##
## @param from_ray: LaserRay that is incident
## @modifies: incident_rays
## @effects: adds from_ray to incident_rays if it does not exist
func receiver_hit(from_ray: LaserRay) -> void:
	# Notify about first hit (is now activated)
	if incident_rays.size() == 0:
		emit_signal("receiver_active", true)

	# Add incident ray if it does not exist
	if not from_ray in incident_rays:
		incident_rays.push_front(from_ray)


## Function called by LaserRay when a ray is no longer incident on a receiver
##
## @param from_ray: LaserRay that is no longer incident
## @modifies: incident_rays
## @effects: removes from_ray from incident_rays if it exists
func receiver_leave(from_ray: LaserRay) -> void:
	# Remove incident ray if it exists
	if from_ray in incident_rays:
		incident_rays.erase(from_ray)

	# Notify about last laser leaving (is now deactivated)
	if incident_rays.size() == 0:
		emit_signal("receiver_active", false)
