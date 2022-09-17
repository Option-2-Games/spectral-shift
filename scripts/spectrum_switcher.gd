extends Node2D

export(NodePath) var spectrum_lamp_path
export(NodePath) var cover_path
export(NodePath) var state_label_path

var _tweener: PropertyTweener

var _open_state: bool
var _selecting_color: int
var _selected_color: int

onready var _spectrum_lamp = get_node(spectrum_lamp_path)
onready var _cover: Node2D = get_node(cover_path)
onready var _state_label: Label = get_node(state_label_path)


func _ready():
	# Hide by default
	scale = Vector2.ZERO

	# Verify that the lamp is a SpectrumLamp
	assert(
		(
			_spectrum_lamp.has_method("use_spectrum")
			and _spectrum_lamp.has_method("exclude_spectrum")
		),
		"Attached lamp item is not a SpectrumLamp!"
	)


func _unhandled_input(event):
	if event is InputEventMouseMotion and _open_state:
		# Check if mouse is selecting a spectrum
		var mouse_pos = event.position - global_position
		if mouse_pos.length_squared() >= 16900:
			# Get mouse angle to RED spectrum
			mouse_pos.y *= -1
			var mouse_angle_degrees = rad2deg(
				mouse_pos.angle_to(Vector2(-1, -1))
			)

			_state_label.set_text("ON")
			if mouse_angle_degrees >= 0 and mouse_angle_degrees < 90:
				# Selecting RED = 180º

				_rotate_to_red()

				_selecting_color = Constants.Spectrum.RED
			elif mouse_angle_degrees >= 90 and mouse_angle_degrees < 180:
				# Selecting GREEN = 270º

				_rotate_to_green()

				_selecting_color = Constants.Spectrum.GREEN
			elif mouse_angle_degrees >= -180 and mouse_angle_degrees < -90:
				# Selecting BLUE = 0º

				_rotate_to_blue()

				_selecting_color = Constants.Spectrum.BLUE
			elif mouse_angle_degrees >= -90 and mouse_angle_degrees < 0:
				# Selecting BASE = 90º

				_rotate_to_base()

				_selecting_color = Constants.Spectrum.BASE
				_state_label.set_text("OFF")

		elif _selecting_color != _selected_color:
			# Mouse is not selecting a spectrum (anymore), reset back to selected spectrum
			match _selected_color:
				Constants.Spectrum.RED:
					_rotate_to_red()
				Constants.Spectrum.GREEN:
					_rotate_to_green()
				Constants.Spectrum.BLUE:
					_rotate_to_blue()
				Constants.Spectrum.BASE:
					_rotate_to_base()
					_state_label.set_text("OFF")

			_selecting_color = _selected_color

	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			_open_state = event.is_pressed()
			# Handle opening/closing switcher
			if _open_state:
				global_position = event.position
				_tweener = _create_tween_cubic_out().tween_property(
					_cover.get_parent(), "scale", Vector2.ONE, 0.1
				)

			else:
				_animate_close_switcher_animation()

				_selected_color = _selecting_color
				_spectrum_lamp.exclude_spectrum(_selected_color)


func _create_tween_cubic_out() -> SceneTreeTween:
	return get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)


func _create_tween_back_in():
	return get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_IN
	)


func _animate_rotate_cover_to_degree(degree: float):
	return _create_tween_cubic_out().tween_property(
		_cover, "rotation_degrees", degree, 0.1
	)


func _animate_close_switcher_animation():
	_tweener = _create_tween_back_in().tween_property(
		_cover.get_parent(), "scale", Vector2.ZERO, 0.25
	)


func _rotate_to_red():
	_tweener = _animate_rotate_cover_to_degree(180)


func _rotate_to_green():
	var cover_current_rotation = _cover.rotation_degrees
	_tweener = _animate_rotate_cover_to_degree(270).from(
		(
			cover_current_rotation
			if _selecting_color != Constants.Spectrum.BLUE
			else cover_current_rotation + 360
		)
	)


func _rotate_to_blue():
	var cover_current_rotation = _cover.rotation_degrees
	_tweener = _animate_rotate_cover_to_degree(0).from(
		(
			cover_current_rotation
			if _selecting_color != Constants.Spectrum.GREEN
			else cover_current_rotation - 360
		)
	)


func _rotate_to_base():
	_tweener = _animate_rotate_cover_to_degree(90)
