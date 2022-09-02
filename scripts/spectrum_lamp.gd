extends Area2D
# Spectrum display and communication handler
# Control specturm lamp viewports and communicating with objects affected by lamps

# === Constants ===

# Const: BORDER_ROTATION_SPEED
# How fast the lamp borders rotate
#
# Multiply by delta to get the rotation increment amount
const BORDER_ROTATION_SPEED: int = 2

# Const: BORDER_ROTATION_PATH_RADIUS
# How far out from the center the lamp borders will rotate
const BORDER_ROTATION_PATH_RADIUS: int = 7

# Const: CLOSE_RED_SPECTRUM_ANIMATION_KEY
# Animation key to close the red spectrum
const CLOSE_RED_SPECTRUM_ANIMATION_KEY: String = "close_red_spectrum"

# Const: CLOSE_GREEN_SPECTRUM_ANIMATION_KEY
# Animation key to close the green spectrum
const CLOSE_GREEN_SPECTRUM_ANIMATION_KEY: String = "close_green_spectrum"

# Const: CLOSE_BLUE_SPECTRUM_ANIMATION_KEY
# Animation key to close the blue spectrum
const CLOSE_BLUE_SPECTRUM_ANIMATION_KEY: String = "close_blue_spectrum"

# === Component Paths ===

export var red_lamp_path: NodePath
export var green_lamp_path: NodePath
export var blue_lamp_path: NodePath

export var red_animation_player_path: NodePath
export var green_animation_player_path: NodePath
export var blue_animation_player_path: NodePath

# === Variables ===

# Var: _rotation_progress
# Where in the rotation circle the borders are (in radians)
var _rotation_progress: float

# Var: _lamp_state
# Current state on/off state of the spectrums
#
# Use a binary number to represent the state of each lamp
#
# - 1st bit: base reality, not considered in usage
# - 2nd bit: red spectrum
# - 3rd bit: green spectrum
# - 4th bit: blue spectrum
#
# Default: 1 (only base reality is on)
#
# Example:
# 	- 0b1111 = 15 = all lamps are on (this situation will never happen through gameplay)
# 	- 0b0100 = 4 = only green lamp is on
var _lamp_state: int = 1

# Var: _lamp_display_state
# Current visual state of the lamps
#
# May be different from _lamp_state if the state was just changed and the
# animation has not been applied yet
var _lamp_display_state: int = 1

# === Components Nodes ===

onready var _red_lamp: Light2D = get_node(red_lamp_path)
onready var _green_lamp: Light2D = get_node(green_lamp_path)
onready var _blue_lamp: Light2D = get_node(blue_lamp_path)

onready var _red_animation_player: AnimationPlayer = get_node(red_animation_player_path)
onready var _green_animation_player: AnimationPlayer = get_node(green_animation_player_path)
onready var _blue_animation_player: AnimationPlayer = get_node(blue_animation_player_path)

# === Built-in Functions ===


# Func: _process
# Called every frame. Updates the rotation of the borders.
#
# Parameters:
#   delta - The time since the last frame.
func _process(delta: float):
	if _lamp_state > Constants.Spectrum.BASE:
		# Increment rotation progress
		_rotation_progress += delta * BORDER_ROTATION_SPEED

		# Rotation position
		var forward_rotation = (
			Vector2(cos(_rotation_progress), sin(_rotation_progress))
			* BORDER_ROTATION_PATH_RADIUS
		)
		var backward_rotation = (
			Vector2(cos(-_rotation_progress + PI), sin(-_rotation_progress + PI))
			* BORDER_ROTATION_PATH_RADIUS
		)

		# Rotate red border
		if _is_spectrum_on(Constants.Spectrum.RED):
			_red_lamp.position = forward_rotation

		# Rotate green border (pick direction based on other borders state)
		if _is_spectrum_on(Constants.Spectrum.GREEN):
			if _is_spectrum_on(Constants.Spectrum.RED):
				_green_lamp.position = backward_rotation
			else:
				_green_lamp.position = forward_rotation

		# Rotate blue border
		if _is_spectrum_on(Constants.Spectrum.BLUE):
			_blue_lamp.position = backward_rotation

		# Reset rotation progress if it's greater than 2PI
		if _rotation_progress >= 2 * PI:
			_rotation_progress -= 2 * PI


# Func: _unhandled_input
# Called when an input event is received. Used to manage input events
#
# Parameters:
#   event - The input event.
func _unhandled_input(event: InputEvent):
	if event is InputEventKey:
		if Input.is_action_pressed("exclude_all_spectrums"):
			use_spectrum(Constants.Spectrum.BASE)
		elif Input.is_action_pressed("exclude_red_spectrum"):
			exclude_spectrum(Constants.Spectrum.RED)
		elif Input.is_action_pressed("exclude_green_spectrum"):
			exclude_spectrum(Constants.Spectrum.GREEN)
		elif Input.is_action_pressed("exclude_blue_spectrum"):
			exclude_spectrum(Constants.Spectrum.BLUE)


# === Access and Lamp-changing Functions ===


# Func: use_spectrum
# Set lamp to a specific spectrum.
#
# Use <Constants.Spectrum> to define the spectrums to use.
# Does <reset_to_base> if a value outside of the 3 spectrums (that are not BASE) is passed.
#
# Parameters:
#   spectrum - <Constants.Spectrum> to use
func use_spectrum(spectrum: int):
	_lamp_state = 1 << spectrum + 1 if spectrum > 0 and spectrum <= 3 else 1
	_run_open_close_animation()


# Func: exclude_spectrum
# Set lamp to enable base + two spectrums and exclude one.
#
# Use <Constants.Spectrum> to define the spectrums to exclude.
# Closes all spectrums if a value outside of the 3 spectrums is passed.
#
# Parameters:
#   spectrum - <Constants.Spectrum> to exclude
func exclude_spectrum(spectrum: int):
	_lamp_state = 15 - (1 << spectrum) if spectrum > 0 and spectrum <= 3 else 1
	_run_open_close_animation()


# === Helper Functions ===


# Func: _run_open_close_animation
# Run the open/close animation for each lamp based on <_lamp_state> and <_lamp_display_state>
func _run_open_close_animation():
	for spectrum in range(1, 4):
		var should_be_on = _is_spectrum_on(spectrum)
		if should_be_on != _is_spectrum_visually_on(spectrum):
			var direction = -1 if should_be_on else 1
			match spectrum:
				Constants.Spectrum.RED:
					_red_animation_player.play(
						CLOSE_RED_SPECTRUM_ANIMATION_KEY, -1, direction, should_be_on
					)
				Constants.Spectrum.GREEN:
					_green_animation_player.play(
						CLOSE_GREEN_SPECTRUM_ANIMATION_KEY, -1, direction, should_be_on
					)
				Constants.Spectrum.BLUE:
					_blue_animation_player.play(
						CLOSE_BLUE_SPECTRUM_ANIMATION_KEY, -1, direction, should_be_on
					)
	_lamp_display_state = _lamp_state


# Func: _is_spectrum_on
# Check if a spectrum is set to be on
#
# Parameters:
#   spectrum - <Constants.Spectrum> to check
func _is_spectrum_on(spectrum: int) -> bool:
	return (_lamp_state & 1 << spectrum) >> spectrum == 1


# Func: _is_spectrum_visually_on
# Same as <_is_spectrum_on> but for the display state
#
# Parameters:
#   spectrum - <Constants.Spectrum> to check
func _is_spectrum_visually_on(spectrum: int) -> bool:
	return (_lamp_display_state & 1 << spectrum) >> spectrum == 1


# Func: _handle_item_entrance
# Called by signal handlers for when an item enters the lamp region.
#
# Parameters:
#	item - item that entered the region (can be Area2D or Node)
func _handle_item_entrance(item):
	if item.has_method("on_lamp_entered"):
		item.on_lamp_entered(get_collision_mask())


# Func: _handle_item_exit
# Called by signal handlers for when an item exits the lamp region.
#
# Parameters:
#	item - item that entered the region (can be Area2D or Node)
func _handle_item_exit(item):
	if item.has_method("on_lamp_exited"):
		item.on_lamp_exited(get_collision_mask())


# === Signal Handlers ===


# Func: _on_SpectrumLamp_area_entered
# Signal receiver for when an Area2D enters the lamp region.
#
# Parameters:
#	area - Area2D that entered the region
func _on_SpectrumLamp_area_entered(area: Area2D):
	_handle_item_entrance(area)


# Func: _on_SpectrumLamp_area_exited
# Signal receiver for when an Area2D exits the lamp region.
#
# Parameters:
#	area - Area2D that exited the region
func _on_SpectrumLamp_area_exited(area: Area2D):
	_handle_item_exit(area)


# Func: _on_SpectrumLamp_body_entered
# Signal receiver for when a Node enters the lamp region.
#
# Parameters:
#	node - Node that entered the region
func _on_SpectrumLamp_body_entered(body: Node):
	_handle_item_entrance(body)


# Func: _on_SpectrumLamp_body_exited
# Signal receiver for when a Node exits the lamp region.
#
# Parameters:
#	node - Node that exited the region
func _on_SpectrumLamp_body_exited(body: Node):
	_handle_item_exit(body)
