tool
class_name MergeRegion
extends Area2D

# === Spectrum and Component Paths ===
export(Constants.Spectrum) var spectrum setget _apply_spectrum
export(Array, NodePath) var node_paths

# === Components ===
onready var border = get_node(node_paths[0]) as Sprite
onready var region = get_node(node_paths[1]) as Light2D

# === System ===


func _ready() -> void:
	# Spin animation (only in-game)
	if not Engine.editor_hint:
		var spin_direction = 1 if randi() % 2 == 0 else -1
		var spin = create_tween().set_loops()
		spin.tween_property(self, "rotation_degrees", spin_direction * 360, 3).from(0.0)

	# Apply spectrum
	_apply_spectrum(spectrum)


# === Public Functions ===


## Open this region
func open() -> void:
	var open = create_tween().set_trans(Tween.TRANS_BACK)
	open.tween_property(self, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)


## Close this region
func close() -> void:
	var close = create_tween().set_trans(Tween.TRANS_CUBIC)
	close.tween_property(self, "scale", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN)


# === Private Functions ===


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
## @modifies: spectrum
## @effects: Updates spectrum based on input
func _apply_spectrum(new_spectrum: int) -> void:
	spectrum = new_spectrum

	# Set collision masks and modulate border
	if border:
		set_collision_mask(1 + (1 << spectrum))
		region.set_item_cull_mask(1 << spectrum)
		border.set_modulate(Constants.STANDARD_COLOR[spectrum])


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


# === Signal Handlers ===


func _on_area_entered(area: Area2D) -> void:
	_handle_entered(area)


func _on_area_exited(area: Area2D) -> void:
	_handle_exited(area)


func _on_body_entered(body: Node2D) -> void:
	_handle_entered(body)


func _on_body_exited(body: Node2D) -> void:
	_handle_exited(body)
