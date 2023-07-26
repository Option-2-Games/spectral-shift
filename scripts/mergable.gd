tool
class_name Mergable
extends CollisionObject2D

## Class definition for objects that can be merged into the base spectrums

# === Properties ===
export(Constants.Spectrum) var spectrum setget _apply_spectrum
export(Constants.PhysicsObjectType) var physics_object_type = Constants.PhysicsObjectType.INTERACTABLE

## Keep track of the number of regions merged with
var _merge_region_count: int

## Keep track of starting collision layer and mask
var _starting_collision_layer: int
var _starting_collision_mask: int

# === System ===


func _ready() -> void:
	# Enable light-only material in game and not a child of mergable
	if not Engine.editor_hint and get_parent().get_class() != "Mergable":
		set_use_parent_material(false)

	# Grab parent spectrum if they're mergable
	if get_parent().get_class() == "Mergable":
		var parent = get_parent() as Mergable
		spectrum = parent.spectrum

	# Set light masks and material for children and copy spectrum if also mergable
	for child in get_children():
		child.set_light_mask(1 << spectrum)
		child.set_use_parent_material(true)


# === Public functions ===


## Called by merge region when object enters
##
## @modifies: collision layer and masks
## @effects: enables the base collision layer and mask of the object's type
func entered_merge_region() -> void:
	# Mark entered a merge region
	_merge_region_count += 1

	# Enable base collision layer (of the same type)
	set_collision_layer(get_collision_layer() | _starting_collision_layer >> spectrum)

	# Enable base collision mask (of the same type)
	set_collision_mask(get_collision_mask() | _starting_collision_mask >> spectrum)


## Called by merge region when object exits
##
## @modifies: collision layer and masks
## @effects: removes the base collision layer once all regions are exited
func exited_merge_region() -> void:
	# Mark exited a merge region
	_merge_region_count -= 1

	# Reset back to starting layers once all regions are exited
	if _merge_region_count == 0:
		set_collision_layer(_starting_collision_layer)
		set_collision_mask(_starting_collision_mask)


## Override class name to return "Mergable"
##
## @returns: "Mergable" as class type
func get_class() -> String:
	return "Mergable"


# === Private functions ===


## Apply spectrum setting
## Ran once during initialization
##
## @param new_spectrum: Selected spectrum
## @modifies: collision layer and masks
## @effects: applies the spectrum's layer and mask
func _apply_spectrum(new_spectrum: int) -> void:
	# Record spectrum
	spectrum = new_spectrum

	# Apply modulation
	set_modulate(Constants.STANDARD_COLOR[spectrum])

	# Set starting collision layer
	set_collision_layer(physics_object_type << spectrum)

	# Set starting collision mask
	set_collision_mask(
		(
			Constants.PhysicsObjectType.INTERACTABLE << spectrum
			| Constants.PhysicsObjectType.GLASS << spectrum
		)
	)

	# Also include MOB in mask if not a mob
	if physics_object_type != Constants.PhysicsObjectType.MOB:
		collision_mask |= Constants.PhysicsObjectType.MOB << spectrum

	# Remember collision layer and mask for resetting later
	_starting_collision_layer = get_collision_layer()
	_starting_collision_mask = get_collision_mask()
