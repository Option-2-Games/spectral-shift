@tool
class_name MergeRegion
extends Area2D

# === Spectrum and Component Paths ===
@export var spectrum: int : set = _apply_spectrum
@export var path_region: NodePath

# === Components ===
@onready var region = get_node(path_region) as PointLight2D

# === System ===


func _ready() -> void:
	# Spin animation (only in-game)
	if not Engine.is_editor_hint():
		var spin_direction = 1 if randi() % 2 == 0 else -1
		var spin = create_tween().set_loops()
		spin.tween_property(self, "rotation_degrees", spin_direction * 360, 3).from(0.0)

	# Apply spectrum after nodes load
	_apply_spectrum(spectrum)


# === Public Functions ===


## Open this region
func open() -> void:
	var open_tween = create_tween().set_trans(Tween.TRANS_BACK)
	open_tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)


## Close this region
func close() -> void:
	var close_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	close_tween.tween_property(self, "scale", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN)


# === Private Functions ===


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
## @modifies: spectrum
## @effects: Updates spectrum based on input
func _apply_spectrum(new_spectrum: int) -> void:
	spectrum = new_spectrum

	# Set collision masks and modulate border
	var base_mask: int = (
		Constants.PhysicsObjectType.INTERACTABLE
		| Constants.PhysicsObjectType.GLASS
		| Constants.PhysicsObjectType.MOB
	)
	set_collision_mask(base_mask | base_mask << spectrum)
	set_modulate(Constants.STANDARD_COLOR[spectrum])

	if region:
		region.set_item_cull_mask(1 << spectrum)


## Handle objects entering region
##
## Calls the object's `entered_merge_region`
## @param object: object that entered
func _handle_entered(object) -> void:
	if object.has_method("entered_merge_region"):
		object.entered_merge_region(spectrum)


## Handle objects exiting region
##
## Calls the object's exited_merge_region
## @param object: object that exited
func _handle_exited(object) -> void:
	if object.has_method("exited_merge_region"):
		object.exited_merge_region(spectrum)


# === Signal Handlers ===


func _on_area_entered(area: Area2D) -> void:
	_handle_entered(area)


func _on_area_exited(area: Area2D) -> void:
	_handle_exited(area)


func _on_body_entered(body: Node2D) -> void:
	_handle_entered(body)


func _on_body_exited(body: Node2D) -> void:
	_handle_exited(body)
