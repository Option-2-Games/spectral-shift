extends Node2D

# Properties
var _merge_region_open = true

# Components
onready var _merge_region = $RedRegion


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _merge_region_open:
			_merge_region.close()
		else:
			_merge_region.open()

		_merge_region_open = !_merge_region_open
