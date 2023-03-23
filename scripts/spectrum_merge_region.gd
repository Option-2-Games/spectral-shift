extends Area2D


## Start spin animation
func _ready() -> void:
	var spin_direction = 1 if randi() % 2 == 0 else -1
	var _spin = create_tween().set_loops().tween_property(self, "rotation_degrees", spin_direction * 360, 3).from_current()


## Open this region
func open() -> void:
	var _open = create_tween().set_trans(Tween.TRANS_BACK).tween_property(self, "scale", Vector2.ONE, 0.2).set_ease(
		Tween.EASE_OUT
	)


## Close this region
func close() -> void:
	var _close = self.create_tween().set_trans(Tween.TRANS_CUBIC).tween_property(self, "scale", Vector2.ZERO, 0.1).set_ease(
		Tween.EASE_IN
	)


## Handle objects entering region
##
## Calls the object's `entered_merge_region`
## @param object: object that entered
func _handle_entered(object) -> void:
	if object.has_method("entered_merge_region"):
		object.entered_merge_region()


## Handle objects exiting region
##
## Calls the object's exited_merge_region
## @param object: object that exited
func _handle_exited(object) -> void:
	if object.has_method("exited_merge_region"):
		object.exited_merge_region()


func _on_area_entered(area: Area2D) -> void:
	_handle_entered(area)


func _on_area_exited(area: Area2D) -> void:
	_handle_exited(area)


func _on_body_entered(body: Node2D) -> void:
	_handle_entered(body)


func _on_body_exited(body: Node2D) -> void:
	_handle_exited(body)
