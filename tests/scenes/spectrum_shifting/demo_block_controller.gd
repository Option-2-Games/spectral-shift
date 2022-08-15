extends Area2D


func on_lamp_entered(spectrums: int):
	print(name + " entered lamp of color " + String(spectrums))


func on_lamp_exited(spectrums: int):
	print(name + " exited lamp of color " + String(spectrums))
