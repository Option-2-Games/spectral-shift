extends GutTest

# === Components ===
var _scene: Node2D
var _red_block: Area2D
var _spectrum_merge_region: Area2D

# === Setup ===

## Setup test
##
## Load scene and get necessary nodes
func before_all() -> void:
	# Load scene
	var scene_file = load("res://tests/scenes/merge_region/merge_region_tester.tscn") as PackedScene
	_scene = scene_file.instantiate()
	add_child(_scene)
	
	# Get nodes
	_red_block = _scene.get_node("RedBlock")
	_spectrum_merge_region = _scene.get_node("BaseLayer/SpectrumMergeRegion")
	
	# Ensure all items are accessible
	assert_not_null(_red_block)
	assert_not_null(_spectrum_merge_region)
	
	simulate(_scene, 1, .1)

## Cleanup test
func after_all() -> void:
	_scene.free()

# === Test Functions

## Check is merged
func test_is_merged() -> void:
	assert_true(_red_block.get_collision_layer_value(1), "Should be merged")
	assert_true(_red_block.get_collision_mask_value(1), "Should be merged")
