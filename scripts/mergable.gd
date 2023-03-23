class_name Mergable
extends CollisionObject2D

## Class definition for objects that can shift spectrums (merge)

## Number of regions that is merging this object
var _merges_count: int = 0

## This object's region as a bitwise int
onready var _my_spectrum = get_collision_layer()


func entered_merge_region(region_spectrum: int) -> void:
	# Only affect matching spectrums
	if region_spectrum != _my_spectrum:
		return

	# Merge
	_merges_count += 1
	if _merges_count == 1:
		self.set_collision_layer_bit(0, true)
		self.set_collision_mask_bit(0, true)


func exited_merge_region(region_spectrum: int) -> void:
	# Only affect matching spectrums
	if region_spectrum != _my_spectrum:
		return

	if _merges_count > 0:
		_merges_count -= 1
	if _merges_count == 0:
		self.set_collision_layer_bit(0, false)
		self.set_collision_mask_bit(0, false)
