extends Node2D

export(NodePath) var cover_path
export(NodePath) var state_label_path
export(NodePath) var tween_runner_path

var open_state: bool
var selecting_color: int
var selected_color: int

onready var _cover: Sprite = get_node(cover_path)
onready var _state_label: Label = get_node(state_label_path)
onready var _tween_runner: Tween = get_node(tween_runner_path)

func _ready():
	modulate.a = 0


func _unhandled_input(event):
	var tween_state: bool
	if event is InputEventMouseMotion:
		if open_state:
			var mouse_pos = event.position - global_position
			mouse_pos.y *= -1
			var mouse_angle_adjusted = mouse_pos.angle_to(Vector2(-1, -1))
			var mouse_angle_degrees = rad2deg(mouse_angle_adjusted)

			var current_cover_rotation = _cover.rotation
			_state_label.set_text("ON")
			if mouse_angle_degrees >= 0 and mouse_angle_degrees < 90:
				tween_state = _tween_runner.interpolate_property(_cover, "rotation", current_cover_rotation, deg2rad(180), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
				selecting_color = Constants.Spectrum.RED
			elif mouse_angle_degrees >= 90 and mouse_angle_degrees < 180:
				tween_state = _tween_runner.interpolate_property(_cover, "rotation", current_cover_rotation, deg2rad(-90), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
				selecting_color = Constants.Spectrum.GREEN
			elif mouse_angle_degrees >= -90 and mouse_angle_degrees < 0:
				tween_state = _tween_runner.interpolate_property(_cover, "rotation", current_cover_rotation, deg2rad(90), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
				selecting_color = Constants.Spectrum.BASE
				_state_label.set_text("OFF")
			elif mouse_angle_degrees >= -180 and mouse_angle_degrees < -90:
				tween_state = _tween_runner.interpolate_property(_cover, "rotation", current_cover_rotation, 0, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
				selecting_color = Constants.Spectrum.BLUE
			if tween_state:
				tween_state = _tween_runner.start()
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			open_state = event.is_pressed()
			if open_state:
				global_position = event.position
				tween_state = _tween_runner.interpolate_property(_tween_runner.get_parent(), "modulate:a", 0, 1, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			else:
				tween_state = _tween_runner.interpolate_property(_tween_runner.get_parent(), "modulate:a", 1, 0, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
				selected_color = selecting_color
			
			if tween_state:
				tween_state = _tween_runner.start()