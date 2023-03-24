extends KinematicBody2D

# === Component Paths ===
export(Array, NodePath) var node_paths

# === Variables ===
var _merged_region: MergeRegion

# === Components Nodes ===
onready var _red_region = get_node(node_paths[0])
onready var _green_region = get_node(node_paths[1])
onready var _blue_region = get_node(node_paths[2])

## Regions as an array
onready var _regions = [null, _red_region, _green_region, _blue_region]


func _on_SpectrumSwitcher_spectrum_switched(selection: int) -> void:
	# Close merged region
	if _merged_region:
		_merged_region.close()

	# Open (merge) region
	var region = _regions[selection]
	if region:
		_merged_region = region
		_merged_region.open()
