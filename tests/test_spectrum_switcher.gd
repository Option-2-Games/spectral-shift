extends GutTest

var _scene: Node2D

# === Items in scene ===
var _spectrum_lamp = null
var _spectrum_switcher = null

var _sender = null

# === Properties ===
var _pre_open_selection: int

# === Structural Functions ===

# Func: before_all
# Load scene and get items in scene
func before_all():
	# Load scene
	var scene_file = load(
		"res://tests/scenes/spectrum_shifting/player_lamp_test_scene.tscn"
	)
	_scene = scene_file.instance()
	add_child(_scene)

	# Get access to items
	_spectrum_lamp = _scene.get_node("DemoCharacter/SpectrumLamp")
	_spectrum_switcher = _scene.get_node("DemoCharacter/SpectrumSwitcher")
	_sender = InputSender.new(_spectrum_switcher)

	# Ensure all items are accessible
	assert_not_null(_spectrum_lamp)
	assert_not_null(_spectrum_switcher)
	assert_not_null(_sender)

func after_each():
	_sender.clear()

# Func: after_all
# Tear down tests (free scene)
func after_all():
	_scene.free()

# === Test Functions ===

func test_open_switcher_on_mouse_down():
	# Capture pre-open selection
	_pre_open_selection = _spectrum_switcher._selected_spectrum
	# Open switcher
	_sender.mouse_left_button_down(Vector2.ZERO)

	# Check switcher is open
	assert_true(_spectrum_switcher._open_state, "Switcher should be in an open state")

	# Check if switcher is visible
	yield(yield_frames(1, "Wait for open animation to start"), YIELD)
	assert_ne(_spectrum_switcher.scale.x, 0.00001, "Spectrum switcher should open")
	assert_ne(_spectrum_switcher.scale.y, 0.00001, "Spectrum switcher should open")

func test_close_switcher_on_mouse_up():
	# Raise button
	_sender.mouse_left_button_up(Vector2.ZERO)

	# Check switcher is closed
	assert_false(_spectrum_switcher._open_state, "Switcher should be in an closed state")

	# Check switcher is not visible (or is closing)
	yield(yield_frames(1, "Wait for close animation to start"), YIELD)
	assert_ne(_spectrum_switcher.scale.x, 1.0, "Spectrum switcher should close")
	assert_ne(_spectrum_switcher.scale.y, 1.0, "Spectrum switcher should close")

	# Check that the selection did not change (no spectrum was selected)
	assert_eq(_spectrum_switcher._selected_spectrum, _pre_open_selection, "Spectrum switcher should not change selection")

func test_switch_to_red_spectrum():
	# Open switcher and select red spectrum
	var position_offset: Vector2 = Vector2(-200, 0)
	_sender.mouse_left_button_down(Vector2.ZERO)
	_sender.mouse_relative_motion(position_offset)

	# Wait for selection, then close to confirm selection
	yield(yield_frames(1, "Wait for selection to happen"), YIELD)
	_sender.mouse_left_button_up(position_offset)

	# Check that selecting and selected state are correct
	assert_eq(_spectrum_switcher._selecting_spectrum, Constants.Spectrum.RED, "Spectrum switcher should have been selecting red spectrum")
	assert_eq(_spectrum_switcher._selected_spectrum, Constants.Spectrum.RED, "Spectrum switcher should have selected red spectrum")

func test_switch_to_green_spectrum():
	# Open switcher and select green spectrum
	var position_offset: Vector2 = Vector2(0, -200)
	_sender.mouse_left_button_down(Vector2.ZERO)
	_sender.mouse_relative_motion(position_offset)

	# Wait for selection, then close to confirm selection
	yield(yield_frames(1, "Wait for selection to happen"), YIELD)
	_sender.mouse_left_button_up(position_offset)

	# Check that selecting and selected state are correct
	assert_eq(_spectrum_switcher._selecting_spectrum, Constants.Spectrum.GREEN, "Spectrum switcher should have been selecting green spectrum")
	assert_eq(_spectrum_switcher._selected_spectrum, Constants.Spectrum.GREEN, "Spectrum switcher should have selected green spectrum")

func test_switch_to_blue_spectrum():
	# Open switcher and select blue spectrum
	var position_offset: Vector2 = Vector2(200, 0)
	_sender.mouse_left_button_down(Vector2.ZERO)
	_sender.mouse_relative_motion(position_offset)

	# Wait for selection, then close to confirm selection
	yield(yield_frames(1, "Wait for selection to happen"), YIELD)
	_sender.mouse_left_button_up(position_offset)

	# Check that selecting and selected state are correct
	assert_eq(_spectrum_switcher._selecting_spectrum, Constants.Spectrum.BLUE, "Spectrum switcher should have been selecting blue spectrum")
	assert_eq(_spectrum_switcher._selected_spectrum, Constants.Spectrum.BLUE, "Spectrum switcher should have selected blue spectrum")
