extends Node2D

export(NodePath) var cover_path
export(NodePath) var state_text_path
export(NodePath) var tween_runner_path

onready var cover = get_node(cover_path)
onready var state_text = get_node(state_text_path)
onready var tween_runner = get_node(tween_runner_path)