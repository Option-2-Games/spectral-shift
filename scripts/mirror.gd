tool
extends Mergable

export(NodePath) var mirror_body_path

onready var _mirror_body = get_node(mirror_body_path) as Node2D


func _process(_delta) -> void:
	set_global_transform(_mirror_body.get_global_transform())
