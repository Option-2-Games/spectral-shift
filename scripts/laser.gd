tool
extends Sprite

# === Components and input ===
export(Constants.Spectrum) var spectrum
export(Array, NodePath) var node_paths

# === Component Nodes ===
onready var _start_ray = get_node(node_paths[0]) as RayCast2D
onready var _beam = get_node(node_paths[1]) as Line2D


func _ready():
	# Disable light_only material in editor
	if Engine.editor_hint:
		set_material(null)
		_beam.set_material(null)

	# Apply spectrum
	_apply_spectrum(spectrum)


## Apply spectrum setting
##
## @param new_spectrum: Selected spectrum
func _apply_spectrum(new_spectrum: int) -> void:
	spectrum = new_spectrum
	if _beam:
		# Set colors and light mask
		set_modulate(Constants.STANDARD_COLOR[spectrum])
		_beam.set_default_color(Constants.HIGHLIGHT_COLOR[spectrum])
		_beam.set_light_mask(1 << spectrum)
