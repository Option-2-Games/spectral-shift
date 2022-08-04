extends Area2D


func _on_DemoBlock_area_entered(area: Area2D):
	if area.name == "LampArea":
		print(name + " is visible")


func _on_DemoBlock_area_exited(area: Area2D):
	if area.name == "LampArea":
		print(name + " is not visible")
