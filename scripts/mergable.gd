class_name Mergable
extends CollisionObject2D

## Class definition for objects that can shift spectrums (merge)

## Number of regions that is merging this object
var _merges_count: int = 0


func entered_merge_region(spectrum: int) -> void:
	_merges_count += 1
	if _merges_count == 1:
		self.set_collision_layer_bit(0, true)
		self.set_collision_mask_bit(0, true)


func exited_merge_region(spectrum: int) -> void:
	if _merges_count > 0:
		_merges_count -= 1
	if _merges_count == 0:
		self.set_collision_layer_bit(0, false)
		self.set_collision_mask_bit(0, false)
