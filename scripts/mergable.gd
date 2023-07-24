tool
class_name Mergable
extends CollisionObject2D

## Class definition for objects that can be merged into the base spectrums

# === Properties ===
export(Constants.Spectrum) var spectrum setget _apply_spectrum
export(Array, NodePath) var visual_node_paths
export(Array, NodePath) var child_collision_node_paths

## Keep track of all regions merged with
var _merges: Array

# === System ===


## Setup material
func _init() -> void:
	# Enable light-only material
	if not Engine.editor_hint:
		set_use_parent_material(false)


# === Public functions


## Called by merge region when object enters
##
## @param region_spectrum: Region's spectrum
## @modifies: collision layer and masks
## @effects: adds the region's spectrum mask to the layers and masks
func entered_merge_region(region_spectrum: int) -> void:
	# Mark entered a region of spectrum
	_merges.append(region_spectrum)

	# Enable spectrum layers (ensure exist on all merged layers)
	var bitmask = get_collision_layer() | 1 << region_spectrum | 1
	set_collision_layer(bitmask)
	set_collision_mask(bitmask)


## Called by merge region when object exits
##
## @param region_spectrum: Region's spectrum
## @modifies: collision layer and masks
## @effects: removes the region's spectrum mask from the layers and masks
func exited_merge_region(region_spectrum: int) -> void:
	# Mark exited one region of spectrum
	_merges.erase(region_spectrum)

	# Remove layer if not merged with spectrum anymore
	if _merges.rfind(region_spectrum) == -1:
		set_collision_layer_bit(region_spectrum, false)
		set_collision_mask_bit(region_spectrum, false)

		# Also update layers and masks for children
		for path in child_collision_node_paths:
			var node = get_node(path)
			node.set_collision_layer_bit(region_spectrum, false)
			node.set_collision_mask_bit(region_spectrum, false)

	# Clear all regions (unmerge) if there are no regions of source spectrum
	if not spectrum in _merges:
		_merges.clear()

	# Reset layers if exited all regions
	if _merges.size() == 0:
		_set_collision_layers_and_masks(1 << spectrum)


## Apply collision layers and masks to self and children
##
## @param mask: Collision mask value
## @modifies: collision layer and masks
## @effects: sets collision layers and masks to a specified value
func _set_collision_layers_and_masks(mask: int) -> void:
	# Set base collision layer and mask
	set_collision_layer(mask)
	set_collision_mask(mask)

	# Also set layers and masks for children
	for path in child_collision_node_paths:
		var node = get_node(path)
		node.set_collision_layer(mask)
		node.set_collision_mask(mask)


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
## @modifies: collision layer and masks
## @effects: applies the spectrum's layer and mask
func _apply_spectrum(new_spectrum: int) -> void:
	# Apply spectrum and modulation
	spectrum = new_spectrum
	set_modulate(Constants.STANDARD_COLOR[spectrum])

	# Set collision masks
	_set_collision_layers_and_masks(1 << spectrum)

	# Set light masks and material for visual nodes
	for path in visual_node_paths:
		var node = get_node(path)
		node.set_light_mask(1 << spectrum)
		node.set_use_parent_material(true)
