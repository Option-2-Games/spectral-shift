extends Node2D
## Spectrum switching device
##
## UI for controlling the spectrum switcher (3 merge regions) attached to the player

## Selection signal
signal spectrum_switched(selection)

# === Component Paths ===
export(NodePath) var selection_beam_path
export(NodePath) var status_beam_path
export(NodePath) var status_top_path
export(NodePath) var red_segment_path
export(NodePath) var green_segment_path
export(NodePath) var blue_segment_path

# === Variables ===

## Whether the switcher interface is open for use
var _open_state: bool

## The spectrum which is currently being selected by the player
var _selecting_spectrum: int = Constants.Spectrum.BASE

## The spectrum which is selected in the switcher
var _selected_spectrum: int

# === Components Nodes===
onready var _selection_beam = get_node(selection_beam_path)
onready var _status_beam = get_node(status_beam_path)
onready var _status_top = get_node(status_top_path)
onready var _red_segment = get_node(red_segment_path)
onready var _green_segment = get_node(green_segment_path)
onready var _blue_segment = get_node(blue_segment_path)

var _segments = [_red_segment, _green_segment, _blue_segment]

# === Built-in Functions ===


## Hide the switcher interface by default
func _ready() -> void:
	# Hide by default
	scale = Vector2.ZERO


## Called when an input event is received.
#
## Handles opening and close the switcher, selecting a spectrum,
## and triggering the appropriate animations.
#
# @param event: The input event. Triggered by the mouse.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _open_state:
		# Check if mouse is selecting a spectrum
		var mouse_pos = (event as InputEventMouseMotion).position - global_position
		if mouse_pos.length_squared() >= 16900:
			# Get mouse angle to RED spectrum
			mouse_pos.y *= -1
			var mouse_angle_degrees = rad2deg(
				mouse_pos.angle_to(Vector2(-1, -1))
			)

			if mouse_angle_degrees >= 0 and mouse_angle_degrees < 90 and _selecting_spectrum != Constants.Spectrum.RED:
				# Selecting RED = 90º
				_selecting_red()
			elif mouse_angle_degrees >= 90 and mouse_angle_degrees < 180:
				# Selecting GREEN = 180º
				_select_green()
				_selecting_spectrum = Constants.Spectrum.GREEN
			elif mouse_angle_degrees >= -180 and mouse_angle_degrees < -90:
				# Selecting BLUE = 270º
				_select_blue()
				_selecting_spectrum = Constants.Spectrum.BLUE
			elif mouse_angle_degrees >= -90 and mouse_angle_degrees < 0:
				# Selecting BASE = 0º
				_select_base()
				_selecting_spectrum = Constants.Spectrum.BASE

		elif _selecting_spectrum != _selected_spectrum:
			# Mouse is not selecting a spectrum (anymore), reset back to selected spectrum
			match _selected_spectrum:
				Constants.Spectrum.RED:
					_selecting_red()
				Constants.Spectrum.GREEN:
					_select_green()
				Constants.Spectrum.BLUE:
					_select_blue()
				Constants.Spectrum.BASE:
					_select_base()

			_selecting_spectrum = _selected_spectrum

	elif event is InputEventMouseButton and (event as InputEventMouseButton).button_index == BUTTON_LEFT:
		# Open on mouse down, close otherwise
		_open_state = event.is_pressed()

		# Handle opening/closing switcher
		if _open_state:
			# Move to mouse position
			global_position = (event as InputEventMouseButton).position

			# Open animation
			var _open = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(
				self, "scale", Vector2.ONE, 0.1
			)

		else:
			# Close animation
			var _close = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).tween_property(
				self, "scale", Vector2.ZERO, 0.1
			)

			# Send signal for new selection
			emit_signal("spectrum_switched", _selecting_spectrum)


# === Helper Functions ===


# Func: _create_tween_cubic_out
# Creates a new SceneTreeTween with the default transition set to cubic and the easing set to out.
#
# This is the settings used for rotating the cover and opening the switcher.
func _create_tween_cubic_out() -> SceneTreeTween:
	return create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# Func: _create_tween_back_in
# Creates a new SceneTreeTween with the default transition set to back and the easing set to in.
#
# This is the settings used for closing the switcher.
func _create_tween_back_in():
	return create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)


# Func: _animate_rotate_cover_to_degree
# Creates a SceneTreeTween for rotating the cover to a specified degree
#
# Parameters:
#	degree - Target the cover should rotate too (in degrees)
func _animate_rotate_cover_to_degree(degree: float):
	return create_tween().set_trans(Tween.TRANS_CUBIC).tween_property(
		_selection_beam, "rotation_degrees", degree, 0.1
	)


## Show selecting red spectrum
func _selecting_red() -> void:
	# Highlight red
	var _highlight = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_highlight.tween_property(_red_segment, "scale", Vector2(1.1, 1.1), 0.2)
	_highlight.parallel().tween_property(_red_segment, "modulate", Constants.HIGHLIGHT_COLOR[Constants.Spectrum.RED], 0.2)
	
	# Un-highlight previous segment (if color)
	if _selecting_spectrum != Constants.Spectrum.BASE and _selecting_spectrum != Constants.Spectrum.RED:
		var _unhighlight = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		_unhighlight.tween_property(_segments[_selecting_spectrum], "scale", Vector2.ONE, 0.2)
		_unhighlight.parallel().tween_property(_segments[_selecting_spectrum], "modulate", Constants.STANDARD_COLOR[_selected_spectrum-1], 0.1)
	
	# Set selecting variable
	_selecting_spectrum = Constants.Spectrum.RED

	# Rotate selection beam
	var _rot = create_tween().set_trans(Tween.TRANS_CUBIC).tween_property(_selection_beam, "rotation_degrees", 90, 0.2)

	# Update colors of status and selection beams
	_selection_beam.set_modulate(Constants.STANDARD_COLOR[Constants.Spectrum.RED])
	_status_beam.set_modulate(Constants.STANDARD_COLOR[Constants.Spectrum.RED])
	_status_top.set_modulate(Constants.STANDARD_COLOR[Constants.Spectrum.RED])



# Rotates the cover to the green spectrum
#
# Also recalculates the appropriate starting degree to avoid rotating around the long way
func _select_green():
	var cover_current_rotation = _selection_beam.rotation_degrees
	var _rot = _animate_rotate_cover_to_degree(270).from(
		(
			cover_current_rotation
			if _selecting_spectrum != Constants.Spectrum.BLUE
			else cover_current_rotation + 360
		)
	)


# Rotates the cover to the blue spectrum
#
# Also recalculates the appropriate starting degree to avoid rotating around the long way
func _select_blue():
	var cover_current_rotation = _selection_beam.rotation_degrees
	var _rot = _animate_rotate_cover_to_degree(0).from(
		(
			cover_current_rotation
			if _selecting_spectrum != Constants.Spectrum.GREEN
			else cover_current_rotation - 360
		)
	)


# Rotates the cover to the base spectrum
func _select_base():
	var _rot = _animate_rotate_cover_to_degree(90)
