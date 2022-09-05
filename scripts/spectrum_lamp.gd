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

# Const: OPEN_SPECTRUM_ANIMATION_KEYS
# Animation keys to close each spectrum
const OPEN_SPECTRUM_ANIMATION_KEYS: Array = [
	"open_red_spectrum", "open_green_spectrum", "open_blue_spectrum"
]

# Const: ROTATE_LAMP_ANIMATION_KEYS
# Animation keys to rotate each lamp
const ROTATE_LAMP_ANIMATION_KEYS: Array = [
	"rotate_red_lamp", "rotate_green_lamp", "rotate_blue_lamp"
]

# === Component Paths ===

# Spectrum animation players
export var red_animation_player_path: NodePath
export var green_animation_player_path: NodePath
export var blue_animation_player_path: NodePath

# === Variables ===

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

# Var: _animation_players
# Array of animation players for each spectrum
onready var _animation_players: Array = [
	get_node(red_animation_player_path),
	get_node(green_animation_player_path),
	get_node(blue_animation_player_path)
]

# === Built-in Functions ===


# Func: _ready
# Called once on startup. Used to initialize random number generator
func _ready():
	randomize()


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
		elif Input.is_action_pressed("use_red_spectrum"):
			use_spectrum(Constants.Spectrum.RED)
		elif Input.is_action_pressed("use_green_spectrum"):
			use_spectrum(Constants.Spectrum.GREEN)
		elif Input.is_action_pressed("use_blue_spectrum"):
			use_spectrum(Constants.Spectrum.BLUE)


# === Access and Lamp-changing Functions ===


# Func: use_spectrum
# Set lamp to a specific spectrum.
#
# Use <Spectrum> to define the spectrums to use.
# Closes all 3 spectrums if one of the 3 color spectrums is not passed.
#
# Parameters:
#   spectrum - <Spectrum> to use
func use_spectrum(spectrum: int):
	_lamp_state = 1 << spectrum if spectrum > 0 and spectrum <= 3 else 1
	_run_open_close_animation()


# Func: exclude_spectrum
# Set lamp to enable base + two spectrums and exclude one.
#
# Use <Spectrum> to define the spectrums to exclude.
# Closes all spectrums if a value outside of the 3 spectrums is passed.
#
# Parameters:
#   spectrum - <Spectrum> to exclude
func exclude_spectrum(spectrum: int):
	_lamp_state = 15 - (1 << spectrum) if spectrum > 0 and spectrum <= 3 else 1
	_run_open_close_animation()


# === Helper Functions ===


# Func: _run_open_close_animation
# Run the open/close animation for each lamp based on <_lamp_state> and <_lamp_display_state>
func _run_open_close_animation():
	# Loop through each spectrum
	for spectrum in range(3):
		var should_be_on = _is_spectrum_on(spectrum + 1)
		var is_visually_on = _is_spectrum_visually_on(spectrum + 1)
		var animation_player = _animation_players[spectrum]
		var open_spectrum_animation_key = OPEN_SPECTRUM_ANIMATION_KEYS[spectrum]

		if should_be_on and !is_visually_on:
			# Open and start rotating
			animation_player.play(open_spectrum_animation_key)
			animation_player.play(ROTATE_LAMP_ANIMATION_KEYS[spectrum], 1, rand_range(-1, 1))
		elif !should_be_on and is_visually_on:
			# Close
			animation_player.stop()
			animation_player.play_backwards(open_spectrum_animation_key, 1)
	_lamp_display_state = _lamp_state


# Func: _is_spectrum_on
# Check if a spectrum is set to be on
#
# Parameters:
#   spectrum - <Spectrum> to check
func _is_spectrum_on(spectrum: int) -> bool:
	return (_lamp_state & 1 << spectrum) >> spectrum == 1


# Func: _is_spectrum_visually_on
# Same as <_is_spectrum_on> but for the display state
#
# Parameters:
#   spectrum - <Spectrum> to check
func _is_spectrum_visually_on(spectrum: int) -> bool:
	return (_lamp_display_state & 1 << spectrum) >> spectrum == 1


# Func: _handle_item_entrance
# Called by signal handlers for when an item enters the lamp region.
#
# Parameters:
#	item - item that entered the region (can be Area2D or Node)
func _handle_item_entrance(item):
	if item.has_method("on_lamp_entered"):
		item.on_lamp_entered(_lamp_state)


# Func: _handle_item_exit
# Called by signal handlers for when an item exits the lamp region.
#
# Parameters:
#	item - item that entered the region (can be Area2D or Node)
func _handle_item_exit(item):
	if item.has_method("on_lamp_exited"):
		item.on_lamp_exited(_lamp_state)


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
