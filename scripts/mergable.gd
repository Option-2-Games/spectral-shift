extends CollisionObject2D
class_name Mergable

var _merges_count: int = 0


func entered_merge_region() -> void:
	_merges_count += 1
	self.set_collision_layer_bit(0, true)
	self.set_collision_mask_bit(0, true)


func exited_merge_region() -> void:
	if _merges_count > 0:
		_merges_count -= 1
	if _merges_count == 0:
		self.set_collision_layer_bit(0, false)
		self.set_collision_mask_bit(0, false)
