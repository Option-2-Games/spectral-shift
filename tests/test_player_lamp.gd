extends GutTest

var scene: Node2D

# === Items in scene ===
var spectrum_lamp = null
var demo_block = null
var demo_block2 = null
var demo_kinematic_body = null

# === Structural Functions ===


# Func: before_all
# Load scene and get items in scene
func before_all():
	# Load scene
	var scene_file = load("res://tests/scenes/spectrum_shifting/player_lamp_test_scene.tscn")
	scene = scene_file.instance()
	add_child(scene)

	# Get access to items
	spectrum_lamp = scene.get_node("DemoCharacter/SpectrumLamp")
	demo_block = scene.get_node("DemoBlock")
	demo_block2 = scene.get_node("DemoBlock2")
	demo_kinematic_body = scene.get_node("DemoKinematicBody")

	# Ensure all items are accessible
	assert_not_null(spectrum_lamp)
	assert_not_null(demo_block)
	assert_not_null(demo_block2)
	assert_not_null(demo_kinematic_body)

	yield(yield_for(0.01, "Wait for physics to happen"), YIELD)


# Func: after_all
# Tear down tests (free scene)
func after_all():
	scene.free()


# === Test Functions ===


# Func: test_exclude_red
# Simulate excluding red spectrum
func test_exclude_red():
	spectrum_lamp.exclude_spectrum(Constants.Spectrum.RED)
	var expected_mask = 15 - (1 << Constants.Spectrum.RED)

	# Checks

	assert_false(demo_block.is_merged(), "Red block should NOT be merged")
	assert_true(demo_block2.is_merged(), "Blue block SHOULD be merged")
	assert_true(demo_kinematic_body.is_merged(), "Green block SHOULD be merged")

	assert_eq(
		demo_block.get_collision_mask(),
		1 << Constants.Spectrum.RED,
		"Red block should only see its own spectrum"
	)
	assert_eq(
		demo_block2.get_collision_mask(),
		expected_mask,
		"Blue block should see everything *except* red"
	)
	assert_eq(
		demo_kinematic_body.get_collision_mask(),
		expected_mask,
		"Green block should see everything *except* red"
	)


# Func: test_exclude_green
# Simulate excluding red spectrum
func test_exclude_green():
	spectrum_lamp.exclude_spectrum(Constants.Spectrum.GREEN)
	var expected_mask = 15 - (1 << Constants.Spectrum.GREEN)

	# Checks

	assert_false(demo_kinematic_body.is_merged(), "Green block should NOT be merged")
	assert_true(demo_block.is_merged(), "Red block SHOULD be merged")
	assert_true(demo_block2.is_merged(), "Blue block SHOULD be merged")

	assert_eq(
		demo_kinematic_body.get_collision_mask(),
		1 << Constants.Spectrum.GREEN,
		"Green block should only see its own spectrum"
	)
	assert_eq(
		demo_block.get_collision_mask(),
		expected_mask,
		"Red block should see everything *except* green"
	)
	assert_eq(
		demo_block2.get_collision_mask(),
		expected_mask,
		"Blue block should see everything *except* green"
	)


# Func: test_exclude_blue
# Simulate excluding blue spectrum
func test_exclude_blue():
	spectrum_lamp.exclude_spectrum(Constants.Spectrum.BLUE)
	var expected_mask = 15 - (1 << Constants.Spectrum.BLUE)

	# Checks

	assert_false(demo_block2.is_merged(), "Blue block should NOT be merged")
	assert_true(demo_block.is_merged(), "Red block SHOULD be merged")
	assert_true(demo_kinematic_body.is_merged(), "Green block SHOULD be merged")

	assert_eq(
		demo_block2.get_collision_mask(),
		1 << Constants.Spectrum.BLUE,
		"Blue block should only see its own spectrum"
	)
	assert_eq(
		demo_block.get_collision_mask(),
		expected_mask,
		"Red block should see everything *except* red"
	)
	assert_eq(
		demo_kinematic_body.get_collision_mask(),
		expected_mask,
		"Green block should see everything *except* red"
	)


# Func: test_use_red
# Simulate using exclusively red spectrum
func test_use_red():
	spectrum_lamp.use_spectrum(Constants.Spectrum.RED)
	var expected_mask = 1 + (1 << Constants.Spectrum.RED)

	# Checks
	assert_true(demo_block.is_merged(), "Red block SHOULD be merged")
	assert_false(demo_block2.is_merged(), "Blue block should NOT be merged")
	assert_false(demo_kinematic_body.is_merged(), "Green block should NOT be merged")

	assert_eq(
		demo_block.get_collision_mask(),
		expected_mask,
		"Red block should be merged with only itself and the base"
	)
	assert_eq(
		demo_block2.get_collision_mask(),
		1 << Constants.Spectrum.BLUE,
		"Blue block should only see its own spectrum"
	)
	assert_eq(
		demo_kinematic_body.get_collision_mask(),
		1 << Constants.Spectrum.GREEN,
		"Green block should only see its own spectrum"
	)


# Func: test_use_green
# Simulate using exclusively green spectrum
func test_use_green():
	spectrum_lamp.use_spectrum(Constants.Spectrum.GREEN)
	var expected_mask = 1 + (1 << Constants.Spectrum.GREEN)

	# Checks
	assert_true(demo_kinematic_body.is_merged(), "Green block SHOULD be merged")
	assert_false(demo_block.is_merged(), "Red block should NOT be merged")
	assert_false(demo_block2.is_merged(), "Blue block should NOT be merged")

	assert_eq(
		demo_kinematic_body.get_collision_mask(),
		expected_mask,
		"Green block should be merged with only itself and the base"
	)
	assert_eq(
		demo_block2.get_collision_mask(),
		1 << Constants.Spectrum.BLUE,
		"Blue block should only see its own spectrum"
	)
	assert_eq(
		demo_block.get_collision_mask(),
		1 << Constants.Spectrum.RED,
		"Red block should only see its own spectrum"
	)


# Func: test_use_blue
# Simulate using exclusively blue spectrum
func test_use_blue():
	spectrum_lamp.use_spectrum(Constants.Spectrum.BLUE)
	var expected_mask = 1 + (1 << Constants.Spectrum.BLUE)

	# Checks
	assert_true(demo_block2.is_merged(), "Blue block SHOULD be merged")
	assert_false(demo_block.is_merged(), "Red block should NOT be merged")
	assert_false(demo_kinematic_body.is_merged(), "Green block should NOT be merged")

	assert_eq(
		demo_block2.get_collision_mask(),
		expected_mask,
		"Blue block should be merged with only itself and the base"
	)
	assert_eq(
		demo_block.get_collision_mask(),
		1 << Constants.Spectrum.RED,
		"Red block should only see its own spectrum"
	)
	assert_eq(
		demo_kinematic_body.get_collision_mask(),
		1 << Constants.Spectrum.GREEN,
		"Green block should only see its own spectrum"
	)
