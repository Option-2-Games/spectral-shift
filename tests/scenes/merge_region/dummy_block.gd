extends Area2D


func entered_merge_region() -> void:
	self.set_collision_layer_value(1, true)
	self.set_collision_mask_value(1, true)


func exited_merge_region() -> void:
	self.set_collision_layer_value(1, false)
	self.set_collision_mask_value(1, false)
