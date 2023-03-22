extends Area2D


func entered_merge_region(region_spectrum: int) -> void:
	print("Entered: ", region_spectrum)


func exited_merge_region(region_spectrum: int) -> void:
	print("Exited: ", region_spectrum)
