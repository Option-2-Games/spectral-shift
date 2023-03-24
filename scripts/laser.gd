tool
extends Sprite

# === Components and input ===
export(Constants.Spectrum) var spectrum
export(NodePath) var path_beam

# === Component Nodes ===
onready var _beam = get_node(path_beam) as Line2D


func _ready():
	# Disable light_only material in editor
	if Engine.editor_hint:
		set_material(null)
		_beam.set_material(null)

	# Apply spectrum
	set_modulate(Constants.STANDARD_COLOR[spectrum])
	_beam.set_default_color(Constants.HIGHLIGHT_COLOR[spectrum])
