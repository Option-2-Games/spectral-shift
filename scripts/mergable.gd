@tool
class_name Mergable
extends CollisionObject2D

## Class definition for objects that can be merged into the base spectrums

# === Properties ===
@export var spectrum: int : set = _apply_spectrum
@export var physics_object_type: Constants.PhysicsObjectType = Constants.PhysicsObjectType.INTERACTABLE

## Keep track of the merged regions
var _merged_regions: Array

# === System ===


func _ready() -> void:
	# Enable light-only material in game and not a child of mergable
	if not Engine.is_editor_hint() and get_parent().get_class() != "Mergable":
		set_use_parent_material(false)

	# Grab parent spectrum if they're mergable
	if get_parent().get_class() == "Mergable":
		var parent = get_parent() as Mergable
		spectrum = parent.spectrum

	# Set light masks and material for children and copy spectrum if also mergable
	for child: CanvasItem in get_children():
		child.set_light_mask(1 << spectrum)
		child.set_use_parent_material(true)


# === Public functions ===


## Called by merge region when object enters
##
## @modifies: collision layer and masks
## @effects: enables the base collision layer and mask of the object's type
func entered_merge_region(region_spectrum: int) -> void:
	# Mark entered a merge region
	_merged_regions.append(region_spectrum)

	# Enable collision layer (of the same type)
	set_collision_layer(get_collision_layer() | physics_object_type << region_spectrum)

	# Enable collision mask (of the same type)
	set_collision_mask(
		(
			get_collision_mask()
			| (
				Constants.PhysicsObjectType.INTERACTABLE << region_spectrum
				| Constants.PhysicsObjectType.GLASS << region_spectrum
			)
		)
	)

	# Also include MOB in mask if not a mob
	if physics_object_type != Constants.PhysicsObjectType.MOB:
		set_collision_mask(
			get_collision_mask() | Constants.PhysicsObjectType.MOB << region_spectrum
		)


## Called by merge region when object exits
##
## @modifies: collision layer and masks
## @effects: removes the base collision layer once all regions are exited
func exited_merge_region(region_spectrum: int) -> void:
	# Mark exited a merge region
	_merged_regions.erase(region_spectrum)

	# Remove spectrum if there are no more merges
	if not region_spectrum in _merged_regions:
		# Disable collision layer
		set_collision_layer(get_collision_layer() & ~(physics_object_type << region_spectrum))

		# Disable collision mask
		set_collision_mask(
			(
				get_collision_mask()
				& ~(
					Constants.PhysicsObjectType.INTERACTABLE << region_spectrum
					| Constants.PhysicsObjectType.GLASS << region_spectrum
				)
			)
		)

		# Also remove MOB in mask if not a mob
		if physics_object_type != Constants.PhysicsObjectType.MOB:
			set_collision_mask(
				get_collision_mask() & ~(Constants.PhysicsObjectType.MOB << region_spectrum)
			)


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
		set_collision_mask(get_collision_mask() | Constants.PhysicsObjectType.MOB << spectrum)
