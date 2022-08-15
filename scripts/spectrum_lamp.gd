extends Area2D


# Func: use_spectrum
# Set lamp to a specific spectrum (+ base).
# Use <Constants.Spectrum> to define the spectrums to use.
# Does <reset_to_base> if a value outside of the 3 spectrums (that are not BASE) is passed.
#
# Parameters:
#   spectrum - <Constants.Spectrum> to use
func use_spectrum(spectrum: int):
	if spectrum > 0 and spectrum <= 3:
		set_collision_mask((1 << spectrum) + 1)
	else:
		reset_to_base()


# Func: exclude_spectrum
# Set lamp to enable base + two spectrums and exclude one.
# Use <Constants.Spectrum> to define the spectrums to exclude.
# Does <reset_to_base> if a value outside of the 3 spectrums (that are not BASE) is passed.
#
# Parameters:
#   spectrum - <Constants.Spectrum> to exclude
func exclude_spectrum(spectrum: int):
	if spectrum > 0 and spectrum <= 3:
		set_collision_mask(15 - (1 << spectrum))
	else:
		reset_to_base()


# Func: reset_to_base
# Turn off spectrums in lamp (only show base).
func reset_to_base():
	set_collision_mask(1)


# Func: _handle_item_entrance
# Called by signal handlers for when an item enters the lamp region.
#
# Parameters:
#	item - item that entered the region (can be Area2D or Node)
func _handle_item_entrance(item):
	if item.has_method("on_lamp_entered"):
		item.on_lamp_entered(get_collision_mask())


# Func: _handle_item_exit
# Called by signal handlers for when an item exits the lamp region.
#
# Parameters:
#	item - item that entered the region (can be Area2D or Node)
func _handle_item_exit(item):
	if item.has_method("on_lamp_exited"):
		item.on_lamp_exited(get_collision_mask())


# Func: _on_SpectrumLamp_area_entered
# Signal receiver for when an Area2D enters the lamp region.
#
# Parameters:
#	area - Area2D that entered the region
func _on_SpectrumLamp_area_entered(area: Area2D):
	_handle_item_entrance(area)


# Func: _on_SpectrumLamp_area_exited
# Signal receiver for when an Area2D exits the lamp region.
#
# Parameters:
#	area - Area2D that exited the region
func _on_SpectrumLamp_area_exited(area: Area2D):
	_handle_item_exit(area)


# Func: _on_SpectrumLamp_body_entered
# Signal receiver for when a Node enters the lamp region.
#
# Parameters:
#	node - Node that entered the region
func _on_SpectrumLamp_body_entered(body: Node):
	_handle_item_entrance(body)


# Func: _on_SpectrumLamp_body_exited
# Signal receiver for when a Node exits the lamp region.
#
# Parameters:
#	node - Node that exited the region
func _on_SpectrumLamp_body_exited(body: Node):
	_handle_item_exit(body)
