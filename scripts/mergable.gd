extends CollisionObject2D
class_name Mergable

func entered_merge_region() -> void:
	self.set_collision_layer_bit(0, true)
	self.set_collision_mask_bit(0, true)

func exited_merge_region() -> void:
	self.set_collision_layer_bit(0, false)
	self.set_collision_mask_bit(0, false)