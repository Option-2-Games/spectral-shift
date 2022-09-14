extends Node2D

export(NodePath) var cover_path
export(NodePath) var state_label_path

var _tweener: PropertyTweener

var open_state: bool
var selecting_color: int
var selected_color: int

onready var _cover: Node2D = get_node(cover_path)
onready var _state_label: Label = get_node(state_label_path)

func _ready():
	# Hide by default
	modulate.a = 0


func _unhandled_input(event):
	if event is InputEventMouseMotion and open_state:
		# Check if mouse is selecting a spectrum
		var mouse_pos = event.position - global_position
		if mouse_pos.length_squared() >= 16900:
			# Get mouse angle to RED spectrum
			mouse_pos.y *= -1
			var mouse_angle_adjusted = mouse_pos.angle_to(Vector2(-1, -1))
			var mouse_angle_degrees = rad2deg(mouse_angle_adjusted)

			_state_label.set_text("ON")
			var cover_current_rotation = deg2rad(_cover.rotation_degrees)
			if mouse_angle_degrees >= 0 and mouse_angle_degrees < 90:
				# Selecting RED = 180º
				_tweener = _create_tween().tween_property(_cover, "rotation", deg2rad(180), 0.25)
				selecting_color = Constants.Spectrum.RED
			elif mouse_angle_degrees >= 90 and mouse_angle_degrees < 180:
				# Selecting GREEN = 270º

				_tweener = _create_tween().tween_property(_cover, "rotation", deg2rad(270), 0.25).from(cover_current_rotation if selecting_color != Constants.Spectrum.BLUE else cover_current_rotation + TAU)
				
				selecting_color = Constants.Spectrum.GREEN
			elif mouse_angle_degrees >= -180 and mouse_angle_degrees < -90:
				# Selecting BLUE = 0º

				_tweener = _create_tween().tween_property(_cover, "rotation", deg2rad(0), 0.25).from(cover_current_rotation if selecting_color != Constants.Spectrum.GREEN else cover_current_rotation - TAU)

				selecting_color = Constants.Spectrum.BLUE
			elif mouse_angle_degrees >= -90 and mouse_angle_degrees < 0:
				# Selecting BASE = 90º
				_tweener = _create_tween().tween_property(_cover, "rotation", deg2rad(90), 0.25)
				selecting_color = Constants.Spectrum.BASE
				_state_label.set_text("OFF")
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			open_state = event.is_pressed()
			if open_state:
				global_position = event.position
				_tweener = _create_tween().tween_property(_cover.get_parent(), "modulate:a", 1.0, 0.1)
			else:
				_tweener = create_tween().tween_property(_cover.get_parent(), "modulate:a", 0.0, 0.25)
				selected_color = selecting_color


func _create_tween() -> SceneTreeTween:
	return get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
