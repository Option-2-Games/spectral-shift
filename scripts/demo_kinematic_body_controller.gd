extends KinematicBody2D


func on_lamp_entered(color):
	print(name + " entered lamp of color " + color)


func on_lamp_exited(color):
	print(name + " exited lamp of color " + color)
