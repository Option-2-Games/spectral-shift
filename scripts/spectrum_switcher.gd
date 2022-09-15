extends Node2D

export(NodePath) var cover_path
export(NodePath) var state_label_path

var _tweener: PropertyTweener

var open_state: bool
var selecting_color: int
var selected_color: int

onready var _cover: Node2D = get_node(cover_path)
onready var _state_label: Label = get_node(state_label_path)


func _ready():
	# Hide by default
	scale = Vector2.ZERO


func _unhandled_input(event):
	if event is InputEventMouseMotion and open_state:
		# Check if mouse is selecting a spectrum
		var mouse_pos = event.position - global_position
		if mouse_pos.length_squared() >= 16900:
			# Get mouse angle to RED spectrum
			mouse_pos.y *= -1
			var mouse_angle_degrees = rad2deg(mouse_pos.angle_to(Vector2(-1, -1)))

			_state_label.set_text("ON")
			if mouse_angle_degrees >= 0 and mouse_angle_degrees < 90:
				# Selecting RED = 180º

				_rotate_to_red()

				selecting_color = Constants.Spectrum.RED
			elif mouse_angle_degrees >= 90 and mouse_angle_degrees < 180:
				# Selecting GREEN = 270º

				_rotate_to_green()

				selecting_color = Constants.Spectrum.GREEN
			elif mouse_angle_degrees >= -180 and mouse_angle_degrees < -90:
				# Selecting BLUE = 0º

				_rotate_to_blue()

				selecting_color = Constants.Spectrum.BLUE
			elif mouse_angle_degrees >= -90 and mouse_angle_degrees < 0:
				# Selecting BASE = 90º

				_rotate_to_base()

				selecting_color = Constants.Spectrum.BASE
				_state_label.set_text("OFF")

		elif selecting_color != selected_color:
			# Mouse is not selecting a spectrum (anymore), reset back to selected spectrum
			match selected_color:
				Constants.Spectrum.RED:
					_rotate_to_red()
				Constants.Spectrum.GREEN:
					_rotate_to_green()
				Constants.Spectrum.BLUE:
					_rotate_to_blue()
				Constants.Spectrum.BASE:
					_rotate_to_base()
					_state_label.set_text("OFF")

			selecting_color = selected_color

	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			open_state = event.is_pressed()
			if open_state:
				global_position = event.position
				_tweener = _create_tween_for_scale().tween_property(_cover.get_parent(), "scale", Vector2.ONE, 0.1).set_ease(
					Tween.EASE_OUT
				)
			else:
				_tweener = _create_tween_for_scale().tween_property(_cover.get_parent(), "scale", Vector2.ZERO, 0.25).set_ease(
					Tween.EASE_IN
				)
				selected_color = selecting_color


func _create_tween_for_rotation() -> SceneTreeTween:
	return get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)


func _create_tween_for_scale() -> SceneTreeTween:
	return get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_BACK)


func _rotate_to_red():
	_tweener = _create_tween_for_rotation().tween_property(_cover, "rotation_degrees", 180.0, 0.25)


func _rotate_to_green():
	var cover_current_rotation = _cover.rotation_degrees
	_tweener = _create_tween_for_rotation().tween_property(_cover, "rotation_degrees", 270.0, 0.25).from(
		(
			cover_current_rotation
			if selecting_color != Constants.Spectrum.BLUE
			else cover_current_rotation + 360
		)
	)


func _rotate_to_blue():
	var cover_current_rotation = _cover.rotation_degrees
	_tweener = _create_tween_for_rotation().tween_property(_cover, "rotation_degrees", 0.0, 0.25).from(
		(
			cover_current_rotation
			if selecting_color != Constants.Spectrum.GREEN
			else cover_current_rotation - 360
		)
	)


func _rotate_to_base():
	_tweener = _create_tween_for_rotation().tween_property(_cover, "rotation_degrees", 90.0, 0.25)
