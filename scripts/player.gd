extends CharacterBody2D

# === Component Paths ===
@export var red_region: MergeRegion
@export var green_region: MergeRegion
@export var blue_region: MergeRegion

# === Variables ===
var _merged_region: MergeRegion

# === Components Nodes ===
var _regions: Array[MergeRegion] = [null, red_region, green_region, blue_region]

# === Signal Handlers ===


## Handle spectrum switcher choosing a new spectrum
##
## @param selection: New spectrum
## @modifies: _merged_region
## @effects: Updates _merged_region to the new spectrum
func _on_SpectrumSwitcher_spectrum_switched(selection: int) -> void:
	# Close merged region
	if _merged_region:
		_merged_region.close()

	# Open (merge) region
	var region = _regions[selection]
	if region:
		_merged_region = region
		_merged_region.open()
