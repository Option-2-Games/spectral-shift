extends Area2D
# Spectrum display and communication handler
# Control specturm lamp viewports and communicating with objects affected by lamps

# === Constants ===

# Const: BORDER_ROTATION_SPEED
# How fast the lamp borders rotate
# Multiply by delta to get the rotation increment amount
const BORDER_ROTATION_SPEED: int = 2

# Const: BORDER_ROTATION_PATH_RADIUS
# How far out from the center the lamp borders will rotate
const BORDER_ROTATION_PATH_RADIUS: int = 7

# === Component Paths ===

export var red_lamp_path: NodePath
export var green_lamp_path: NodePath
export var blue_lamp_path: NodePath

export var red_border_path: NodePath
export var green_border_path: NodePath
export var blue_border_path: NodePath

# === Variables ===

# Var: _rotation_progress
# Where in the rotation circle the borders are (in radians)
var _rotation_progress: float

# Var: _lamp_state
# Current state on/off state of the spectrums
# Use a binary number to represent the state of each lamp
#
# 1st bit: base reality, not considered in the binary number
# 2nd bit: red spectrum
# 3rd bit: green spectrum
# 4th bit: blue spectrum
#
# Example:
# 	- 0b1110 = 14 = all lamps are on (this situation will never happen)
# 	- 0b0100 = 4 = only green lamp is on
var _lamp_state: int

# === Components Nodes ===

onready var _red_lamp: Light2D = get_node(red_lamp_path)
onready var _green_lamp: Light2D = get_node(green_lamp_path)
onready var _blue_lamp: Light2D = get_node(blue_lamp_path)
onready var _lamps: Array = [_red_lamp, _green_lamp, _blue_lamp]

onready var _red_border: Sprite = get_node(red_border_path)
onready var _green_border: Sprite = get_node(green_border_path)
onready var _blue_border: Sprite = get_node(blue_border_path)
onready var _borders: Array = [_red_border, _green_border, _blue_border]

# === Built-in Functions ===


# Func: _ready
# Setup the lamp by disabling all spectrums
func _ready():
	reset_to_base()


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
			reset_to_base()
		elif Input.is_action_pressed("exclude_red_spectrum"):
			exclude_spectrum(Constants.Spectrum.RED)
		elif Input.is_action_pressed("exclude_green_spectrum"):
			exclude_spectrum(Constants.Spectrum.GREEN)
		elif Input.is_action_pressed("exclude_blue_spectrum"):
			exclude_spectrum(Constants.Spectrum.BLUE)


# === Access and Lamp-changing Functions ===


# Func: use_spectrum
# Set lamp to a specific spectrum.
# Use <Constants.Spectrum> to define the spectrums to use.
# Does <reset_to_base> if a value outside of the 3 spectrums (that are not BASE) is passed.
#
# Parameters:
#   spectrum - <Constants.Spectrum> to use
func use_spectrum(spectrum: int):
	if spectrum > 0 and spectrum <= 3:
		reset_to_base()
		_enable_spectrum_visualization(spectrum)
		_lamp_state = 1 << spectrum
	else:
		reset_to_base()


# Func: exclude_spectrum
# Set lamp to enable base + two spectrums and exclude one.
# Use <Constants.Spectrum> to define the spectrums to exclude.
# Does <reset_to_base> if a value outside of the 3 spectrums (that are not BASE) is passed.
#
# Parameters:
#   spectrum - <Constants.Spectrum> to exclude
func exclude_spectrum(spectrum: int):
	if spectrum > 0 and spectrum <= 3:
		_enable_spectrum_visualization(Constants.Spectrum.RED)
		_enable_spectrum_visualization(Constants.Spectrum.GREEN)
		_enable_spectrum_visualization(Constants.Spectrum.BLUE)

		_disable_spectrum_visualization(spectrum)
		_lamp_state = 14 - (1 << spectrum)
	else:
		reset_to_base()


# Func: reset_to_base
# Turn off spectrums in lamp (only show base).
func reset_to_base():
	_disable_spectrum_visualization(Constants.Spectrum.RED)
	_disable_spectrum_visualization(Constants.Spectrum.GREEN)
	_disable_spectrum_visualization(Constants.Spectrum.BLUE)
	_lamp_state = Constants.Spectrum.BASE


# === Helper Functions ===


# Func: _disable_spectrum_visualization
# Turn off visualization of a spectrum.
func _disable_spectrum_visualization(spectrum: int):
	_lamps[spectrum - 1].energy = 0
	_borders[spectrum - 1].visible = false


# Func: _enable_spectrum_visualization
# Turn on visualization of a spectrum.
func _enable_spectrum_visualization(spectrum: int):
	_lamps[spectrum - 1].energy = 1
	_borders[spectrum - 1].visible = true


# Func: _is_spectrum_on
# Check if a spectrum is set to be on
#
# Parameters:
#   spectrum - <Constants.Spectrum> to check
func _is_spectrum_on(spectrum: int) -> bool:
	return (_lamp_state & 1 << spectrum) >> spectrum == 1


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
