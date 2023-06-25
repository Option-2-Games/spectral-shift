extends Node2D
## Spectrum switching device
##
## UI for controlling the spectrum switcher (3 merge regions) attached to the player

## Selection signal
signal spectrum_switched(selection)

# === Constants ===
const SQ_DISTANCE_TO_SEGMENT = 4225
const TWEEN_DURATION = 0.2
const OFF_COLOR = Color("646464")

# === Component Paths ===
export(NodePath) var path_selection_beam
export(NodePath) var path_red_segment
export(NodePath) var path_green_segment
export(NodePath) var path_blue_segment

# === Variables ===

## Whether the switcher interface is open for use
var _switcher_is_open: bool

## The spectrum which is currently being selected by the player
var _selecting_spectrum: int = Constants.Spectrum.BASE

## The spectrum which is selected in the switcher
var _selected_spectrum: int

# === Component Nodes===
onready var _selection_beam = get_node(path_selection_beam)
onready var _red_segment = get_node(path_red_segment)
onready var _green_segment = get_node(path_green_segment)
onready var _blue_segment = get_node(path_blue_segment)

## Color segments as an array (null offset for base)
onready var _segments = [null, _red_segment, _green_segment, _blue_segment]

# === System ===


## Hide the switcher interface by default
func _ready() -> void:
	scale = Vector2.ZERO


## Called when an input event is received.
#
## Handles opening and close the switcher, selecting a spectrum,
## and triggering the appropriate animations.
#
# @param event: The input event. Triggered by the mouse.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _switcher_is_open:
		# Check if mouse is selecting a spectrum
		var mouse_pos = (event as InputEventMouseMotion).position - global_position
		if mouse_pos.length_squared() >= SQ_DISTANCE_TO_SEGMENT:
			# Get mouse angle to RED spectrum
			mouse_pos.y *= -1
			var mouse_angle_degrees = rad2deg(mouse_pos.angle_to(Vector2(-1, -1)))

			if (
				mouse_angle_degrees >= 0
				and mouse_angle_degrees < 90
				and _selecting_spectrum != Constants.Spectrum.RED
			):
				# Selecting RED = 90º
				_do_selecting_spectrum(Constants.Spectrum.RED)
			elif (
				mouse_angle_degrees >= 90
				and mouse_angle_degrees < 180
				and _selecting_spectrum != Constants.Spectrum.GREEN
			):
				# Selecting GREEN = 180º
				_do_selecting_spectrum(Constants.Spectrum.GREEN)
			elif (
				mouse_angle_degrees >= -180
				and mouse_angle_degrees < -90
				and _selecting_spectrum != Constants.Spectrum.BLUE
			):
				# Selecting BLUE = 270º
				_do_selecting_spectrum(Constants.Spectrum.BLUE)
			elif (
				mouse_angle_degrees >= -90
				and mouse_angle_degrees < 0
				and _selecting_spectrum != Constants.Spectrum.BASE
			):
				# Selecting BASE = 0º
				_do_selecting_spectrum(Constants.Spectrum.BASE)

		elif _selecting_spectrum != _selected_spectrum:
			# Mouse is not selecting a spectrum (anymore), reset back to selected spectrum
			_do_selecting_spectrum(_selected_spectrum)

	elif (
		event is InputEventMouseButton
		and (event as InputEventMouseButton).button_index == BUTTON_LEFT
	):
		# Open on mouse down, close otherwise
		_switcher_is_open = event.is_pressed()

		# Handle opening/closing switcher
		if _switcher_is_open:
			# Move to mouse position
			global_position = (event as InputEventMouseButton).position

			# Open animation
			var _open = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(
				self, "scale", Vector2.ONE, 0.1
			)

		else:
			# Close animation
			var _close = _create_cubic_tween().set_ease(Tween.EASE_IN).tween_property(
				self, "scale", Vector2.ZERO, 0.1
			)

			# Set selected
			_selected_spectrum = _selecting_spectrum

			# Send signal for new selection
			emit_signal("spectrum_switched", _selected_spectrum)


# === Helper Functions ===


## Create a tween object with a cubic easing
func _create_cubic_tween() -> SceneTreeTween:
	return create_tween().set_trans(Tween.TRANS_CUBIC)


## Create a tween to rotate a certain degrees
##
## @param degrees: The degrees to rotate
func _create_rotation_tween(degrees: float) -> PropertyTweener:
	return _create_cubic_tween().tween_property(
		_selection_beam, "rotation_degrees", degrees, TWEEN_DURATION
	)


## Unhighlight the `selecting` segment
##
## Used with `_do_selecting_spectrum` to update switcher selection
func _unhighlight_selecting() -> void:
	var segment = _segments[_selecting_spectrum]
	# Only applicable to colors
	if not segment:
		return

	var _unhighlight = _create_cubic_tween().set_ease(Tween.EASE_IN)
	_unhighlight.tween_property(segment, "scale", Vector2.ONE, TWEEN_DURATION)
	_unhighlight.parallel().tween_property(
		segment, "modulate", Constants.STANDARD_COLOR[_selecting_spectrum], TWEEN_DURATION
	)


## Show selecting spectrum
##
## Does not confirm selection, only animates to show currently highlighted spectrum
##
## @param spectrum: The spectrum to highlight
func _do_selecting_spectrum(spectrum: int) -> void:
	var highlight_color = Constants.HIGHLIGHT_COLOR[spectrum]
	var segment = _segments[spectrum]

	# Highlight spectrum
	if segment:
		var _highlight = _create_cubic_tween().set_ease(Tween.EASE_OUT)
		_highlight.tween_property(segment, "scale", Vector2(1.1, 1.1), TWEEN_DURATION)
		_highlight.parallel().tween_property(segment, "modulate", highlight_color, TWEEN_DURATION)

	# Unhighlight previous segment (if color)
	_unhighlight_selecting()

	# Rotate selection beam
	match spectrum:
		Constants.Spectrum.RED:
			var _rot = _create_rotation_tween(90)
		Constants.Spectrum.GREEN:
			var _rot = _create_rotation_tween(180)
		Constants.Spectrum.BLUE:
			var current_rotation = _selection_beam.get_rotation_degrees()
			var _rot = _create_rotation_tween(270).from(
				(
					current_rotation + 360
					if _selecting_spectrum == Constants.Spectrum.BASE
					else current_rotation
				)
			)
		Constants.Spectrum.BASE:
			var current_rotation = _selection_beam.get_rotation_degrees()
			var _rot = _create_rotation_tween(0).from(
				(
					current_rotation - 360
					if _selecting_spectrum == Constants.Spectrum.BLUE
					else current_rotation
				)
			)

	# Update colors of selection beam
	var _beam = _create_cubic_tween().tween_property(
		_selection_beam,
		"modulate",
		OFF_COLOR if spectrum == Constants.Spectrum.BASE else highlight_color,
		TWEEN_DURATION
	)

	# Set selecting variable
	_selecting_spectrum = spectrum
