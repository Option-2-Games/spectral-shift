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
	var scene_file = load("res://tests/scenes/spectrum_shifting/player_lamp_test_scene.tscn")
	scene = scene_file.instance()
	add_child_autofree(scene)

	spectrum_lamp = scene.get_node("DemoCharacter/SpectrumLamp")
	demo_block = scene.get_node("DemoBlock")
	demo_block2 = scene.get_node("DemoBlock2")
	demo_kinematic_body = scene.get_node("DemoKinematicBody")

	assert_not_null(spectrum_lamp)
	assert_not_null(demo_block)
	assert_not_null(demo_block2)
	assert_not_null(demo_kinematic_body)


# === Test Functions ===


func test_exclude_red():
	spectrum_lamp.exclude_spectrum(Constants.Spectrum.RED)

	var excluded_mask = 15 - (1 << Constants.Spectrum.RED)

	assert_false(demo_block.is_merged())
	assert_true(demo_block2.is_merged())
	assert_true(demo_kinematic_body.is_merged())

	assert_eq(demo_block.get_collision_mask(), 1 << Constants.Spectrum.RED)
	assert_eq(demo_block2.get_collision_mask(), excluded_mask)
	assert_eq(demo_kinematic_body.get_collision_mask(), excluded_mask)
