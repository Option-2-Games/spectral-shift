extends Node2D
# Spectrum switching device
# UI for controlling the spectrum lamp attached to the player

# === Component Paths ===
export(NodePath) var spectrum_lamp_path
export(NodePath) var cover_path
export(NodePath) var state_label_path

# === Variables ===

# Var: _tweener
# Currently used tween for animating something.
# Unused by other code and is overwritten often.
#
# --- Prototype
# var _tweener: PropertyTweener
# ---
var _tweener: PropertyTweener

# Var: _open_state
# Whether the switcher interface is open for use
#
# --- Prototype
# var _open_state: bool
# ---
var _open_state: bool

# Var: _selecting_spectrum
# The color which is currently set to be excluded by the switcher
#
# --- Prototype
# var _selecting_spectrum: int
# ---
var _selecting_spectrum: int

# Var: _spectrum_spectrum
# The color which is being selected by the user but has not been confirmed
#
# --- Prototype
# var _spectrum_spectrum: int
# ---
var _selected_spectrum: int

# === Components Nodes===
onready var _spectrum_lamp = get_node(spectrum_lamp_path)
onready var _cover: Node2D = get_node(cover_path)
onready var _state_label: Label = get_node(state_label_path)

# === Built-in Functions ===


# Func: _ready
# Called once on startup.
# Used to hide the switcher interface by default and check that a Spectrum Lamp is attached.
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


# Func: _unhandled_input
# Called when an input event is received.
#
# Handles opening and close the switcher, selecting a spectrum to exclude,
# and triggering the appropriate animations.
#
# Parameters:
#	event - The input event. Triggered by the mouse.
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

				_selecting_spectrum = Constants.Spectrum.RED
			elif mouse_angle_degrees >= 90 and mouse_angle_degrees < 180:
				# Selecting GREEN = 270º

				_rotate_to_green()

				_selecting_spectrum = Constants.Spectrum.GREEN
			elif mouse_angle_degrees >= -180 and mouse_angle_degrees < -90:
				# Selecting BLUE = 0º

				_rotate_to_blue()

				_selecting_spectrum = Constants.Spectrum.BLUE
			elif mouse_angle_degrees >= -90 and mouse_angle_degrees < 0:
				# Selecting BASE = 90º

				_rotate_to_base()

				_selecting_spectrum = Constants.Spectrum.BASE
				_state_label.set_text("OFF")

		elif _selecting_spectrum != _selected_spectrum:
			# Mouse is not selecting a spectrum (anymore), reset back to selected spectrum
			match _selected_spectrum:
				Constants.Spectrum.RED:
					_rotate_to_red()
				Constants.Spectrum.GREEN:
					_rotate_to_green()
				Constants.Spectrum.BLUE:
					_rotate_to_blue()
				Constants.Spectrum.BASE:
					_rotate_to_base()
					_state_label.set_text("OFF")

			_selecting_spectrum = _selected_spectrum

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
				_tweener = _create_tween_back_in().tween_property(
					_cover.get_parent(), "scale", Vector2.ZERO, 0.25
				)

				_selected_spectrum = _selecting_spectrum
				_spectrum_lamp.exclude_spectrum(_selected_spectrum)


# === Helper Functions ===


# Func: _create_tween_cubic_out
# Creates a new SceneTreeTween with the default transition set to cubic and the easing set to out.
#
# This is the settings used for rotating the cover and opening the switcher.
func _create_tween_cubic_out() -> SceneTreeTween:
	return get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)


# Func: _create_tween_back_in
# Creates a new SceneTreeTween with the default transition set to back and the easing set to in.
#
# This is the settings used for closing the switcher.
func _create_tween_back_in():
	return get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_IN
	)


# Func: _animate_rotate_cover_to_degree
# Creates a SceneTreeTween for rotating the cover to a specified degree
#
# Parameters:
#	degree - Target the cover should rotate too (in degrees)
func _animate_rotate_cover_to_degree(degree: float):
	return _create_tween_cubic_out().tween_property(
		_cover, "rotation_degrees", degree, 0.1
	)


# Func: _rotate_to_red
# Rotates the cover to the red spectrum
func _rotate_to_red():
	_tweener = _animate_rotate_cover_to_degree(180)


# Func: _rotate_to_green
# Rotates the cover to the green spectrum
#
# Also recalculates the appropriate starting degree to avoid rotating around the long way
func _rotate_to_green():
	var cover_current_rotation = _cover.rotation_degrees
	_tweener = _animate_rotate_cover_to_degree(270).from(
		(
			cover_current_rotation
			if _selecting_spectrum != Constants.Spectrum.BLUE
			else cover_current_rotation + 360
		)
	)


# Func: _rotate_to_blue
# Rotates the cover to the blue spectrum
#
# Also recalculates the appropriate starting degree to avoid rotating around the long way
func _rotate_to_blue():
	var cover_current_rotation = _cover.rotation_degrees
	_tweener = _animate_rotate_cover_to_degree(0).from(
		(
			cover_current_rotation
			if _selecting_spectrum != Constants.Spectrum.GREEN
			else cover_current_rotation - 360
		)
	)


# Func: _rotate_to_base
# Rotates the cover to the base spectrum
func _rotate_to_base():
	_tweener = _animate_rotate_cover_to_degree(90)
