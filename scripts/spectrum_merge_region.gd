@tool
class_name MergeRegion
extends Area2D

# === Spectrum and Component Paths ===
@export var spectrum: Constants.Spectrum:
	set = _apply_spectrum
@export var region: PointLight2D

# === System ===


func _ready() -> void:
	# Spin animation (only in-game)
	if not Engine.is_editor_hint():
		var spin_direction = 1 if randi() % 2 == 0 else -1
		var spin = get_tree().create_tween().set_loops()
		spin.tween_property(self, "rotation_degrees", spin_direction * 360, 3).from(0.0)

	# Apply spectrum after nodes load
	_apply_spectrum(spectrum)


# === Public Functions ===


## Open this region
func open() -> void:
	print("Open")
	var open_tween: Tween = create_tween().set_trans(Tween.TRANS_BACK)
	open_tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)


## Close this region
func close() -> void:
	print("Close")
	var close_tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	close_tween.tween_property(self, "scale", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN)


# === Private Functions ===


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
## @modifies: spectrum
## @effects: Updates spectrum based on input
func _apply_spectrum(new_spectrum: Constants.Spectrum) -> void:
	spectrum = new_spectrum

	# Set collision masks and modulate border
	set_collision_mask(Constants.BASE_SPECTRUM_MASK | Constants.BASE_SPECTRUM_MASK << spectrum)
	set_modulate(Constants.STANDARD_COLOR[spectrum])

	if region:
		region.set_item_cull_mask(1 << spectrum)


## Handle objects entering region
##
## Calls the object's `entered_merge_region`
## @param object: object that entered
func _handle_entered(object: Node) -> void:
	if object is Mergable:
		(object as Mergable).entered_merge_region(spectrum)


## Handle objects exiting region
##
## Calls the object's exited_merge_region
## @param object: object that exited
func _handle_exited(object: Node) -> void:
	if object is Mergable:
		(object as Mergable).exited_merge_region(spectrum)


# === Signal Handlers ===


func _on_area_entered(area: Area2D) -> void:
	_handle_entered(area)


func _on_area_exited(area: Area2D) -> void:
	_handle_exited(area)


func _on_body_entered(body: Node2D) -> void:
	_handle_entered(body)


func _on_body_exited(body: Node2D) -> void:
	_handle_exited(body)
