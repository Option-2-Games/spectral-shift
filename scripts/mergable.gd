tool
class_name Mergable
extends CollisionObject2D

## Class definition for objects that can be merged into the base spectrums

export(Constants.Spectrum) var spectrum setget _apply_spectrum

## Keep track of all regions merged with
var _merges: Array


func entered_merge_region(region_spectrum: int) -> void:
	# Mark entered a region of spectrum
	_merges.append(region_spectrum)

	# Enable spectrum layers (ensure exist on all merged layers)
	var bitmask = get_collision_layer() | 1 << region_spectrum | 1
	self.set_collision_layer(bitmask)
	self.set_collision_mask(bitmask)


func exited_merge_region(region_spectrum: int) -> void:
	# Mark exited one region of spectrum
	_merges.remove(_merges.rfind(region_spectrum))

	# Remove layer if not merged with spectrum anymore
	if _merges.rfind(region_spectrum) == -1:
		self.set_collision_layer_bit(region_spectrum, false)
		self.set_collision_mask_bit(region_spectrum, false)

	# Reset layers if exited all regions
	if _merges.size() == 0:
		self.set_collision_layer(1 << spectrum)
		self.set_collision_mask(1 << spectrum)


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
func _apply_spectrum(new_spectrum: int) -> void:
	spectrum = new_spectrum
	set_modulate(Constants.STANDARD_COLOR[spectrum])
