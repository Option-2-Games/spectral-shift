extends GutTest

var _scene: Node2D

# === Items in scene ===
var _spectrum_lamp = null
var _spectrum_switcher = null

var _sender = null

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


# Func: after_each
# Clear InputSender between tests
func after_each():
	_sender.clear()


# Func: after_all
# Tear down tests (free scene)
func after_all():
	_scene.free()


# === Test Functions ===


# Func: test_switch_open_close
# Test that the switcher opens when the mouse is pressed and closes when released.
#
# Also checks that the selected value does not change
func test_switch_open_close():
	var prev_selected = _spectrum_switcher._selected_spectrum

	# Open switcher
	_sender.mouse_left_button_down(Vector2.ZERO)

	# Check switcher is open
	assert_true(
		_spectrum_switcher._open_state, "Switcher should be in an open state"
	)

	# Check if switcher is visible
	yield(yield_to(_spectrum_switcher._tweener, "finished", 1), YIELD)
	assert_eq(
		_spectrum_switcher.scale, Vector2.ONE, "Spectrum switcher should open"
	)

	# Close switcher
	_sender.mouse_left_button_up(Vector2.ZERO)

	# Check switcher is closed
	assert_false(
		_spectrum_switcher._open_state, "Switcher should be in an closed state"
	)

	# Check switcher is not visible (or is closing)
	yield(yield_to(_spectrum_switcher._tweener, "finished", 1), YIELD)
	assert_eq(
		_spectrum_switcher.scale,
		Vector2(0.00001, 0.00001),
		"Spectrum switcher should close"
	)

	# Check selected value has not changed
	assert_eq(
		_spectrum_switcher._selected_spectrum,
		prev_selected,
		"Selected spectrum should not change"
	)


# Func: test_switch_to_red_spectrum
# Test that the switcher switches to the red spectrum when opened and mouse moves to the left
func test_switch_to_red_spectrum():
	# Open switcher and select red spectrum
	var position_offset: Vector2 = Vector2(-200, 0)
	_sender.mouse_left_button_down(Vector2.ZERO)
	_sender.mouse_relative_motion(position_offset)

	# Wait for selection, then close to confirm selection
	yield(yield_frames(1, "Wait for selection to happen"), YIELD)
	_sender.mouse_left_button_up(position_offset)

	# Check that selecting and selected state are correct
	assert_eq(
		_spectrum_switcher._selecting_spectrum,
		Constants.Spectrum.RED,
		"Spectrum switcher should have been selecting red spectrum"
	)
	assert_eq(
		_spectrum_switcher._selected_spectrum,
		Constants.Spectrum.RED,
		"Spectrum switcher should have selected red spectrum"
	)

	# Check that cover rotated
	yield(yield_to(_spectrum_switcher._tweener, "finished", 1), YIELD)
	assert_eq(
		_spectrum_switcher._cover.rotation_degrees,
		180.0,
		"Spectrum switcher cover should be rotated to red"
	)


# Func: test_switch_to_green_spectrum
# Test that the switcher switches to the green spectrum when opened and mouse moves up
func test_switch_to_green_spectrum():
	# Open switcher and select green spectrum
	var position_offset: Vector2 = Vector2(0, -200)
	_sender.mouse_left_button_down(Vector2.ZERO)
	_sender.mouse_relative_motion(position_offset)

	# Wait for selection, then close to confirm selection
	yield(yield_frames(1, "Wait for selection to happen"), YIELD)
	_sender.mouse_left_button_up(position_offset)

	# Check that selecting and selected state are correct
	assert_eq(
		_spectrum_switcher._selecting_spectrum,
		Constants.Spectrum.GREEN,
		"Spectrum switcher should have been selecting green spectrum"
	)
	assert_eq(
		_spectrum_switcher._selected_spectrum,
		Constants.Spectrum.GREEN,
		"Spectrum switcher should have selected green spectrum"
	)

	# Check that cover rotated
	yield(yield_to(_spectrum_switcher._tweener, "finished", 1), YIELD)
	assert_eq(
		_spectrum_switcher._cover.rotation_degrees,
		270.0,
		"Spectrum switcher cover should be rotated to green"
	)


# Func: test_switch_to_blue_spectrum
# Test that the switcher switches to the blue spectrum when opened and mouse moves to the right
func test_switch_to_blue_spectrum():
	# Open switcher and select blue spectrum
	var position_offset: Vector2 = Vector2(200, 0)
	_sender.mouse_left_button_down(Vector2.ZERO)
	_sender.mouse_relative_motion(position_offset)

	# Wait for selection, then close to confirm selection
	yield(yield_frames(1, "Wait for selection to happen"), YIELD)
	_sender.mouse_left_button_up(position_offset)

	# Check that selecting and selected state are correct
	assert_eq(
		_spectrum_switcher._selecting_spectrum,
		Constants.Spectrum.BLUE,
		"Spectrum switcher should have been selecting blue spectrum"
	)
	assert_eq(
		_spectrum_switcher._selected_spectrum,
		Constants.Spectrum.BLUE,
		"Spectrum switcher should have selected blue spectrum"
	)

	# Check that cover rotated
	yield(yield_to(_spectrum_switcher._tweener, "finished", 1), YIELD)
	assert_eq(
		_spectrum_switcher._cover.rotation_degrees,
		0.0,
		"Spectrum switcher cover should be rotated to blue"
	)
