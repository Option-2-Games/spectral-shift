extends CollisionObject2D

# === Exported Properties ===
export(Constants.Spectrum) var spectrum

# === Variables ===
var _merged: bool = false

# === Spectrum Handling Function ===


# Func: on_lamp_entered
# Handles when item enters the lamp. Called by the lamp.
#
# Parameters:
#	spectrums - The spectrums that the lamp has merged
func on_lamp_entered(spectrums: int):
	if _is_this_spectrum_on(spectrums):
		_merged = true
		set_collision_mask(spectrums)


# Func: on_lamp_exited
# Handles when item exits the lamp's range or is no longer merged
func on_lamp_exited():
	if _merged:
		_merged = false
		set_collision_mask(1 << spectrum)


# Func: on_lamp_state_changed
# Handles when the lamp's state (what it is merging) changes while the item is
# in the lamp's range. Called by the lamp.
#
# Parameters:
#	spectrums - The spectrums that the lamp has merged
func on_lamp_state_changed(spectrums: int):
	if _is_this_spectrum_on(spectrums):
		set_collision_mask(spectrums)
	else:
		on_lamp_exited()


# === Property Accessors ===


# Func: is_merged
# Item merge state (is it merged into the base reality)
#
# Returns:
#	bool - True if the item is merged, false otherwise
func is_merged() -> bool:
	return _merged


# === Helper Functions ===


# Func: _is_this_spectrum_on
# Checks if the spectrum this item is in is on in the given spectrums
#
# Parameters:
#	spectrums - The spectrums to check
#
# Returns:
#	bool - True if the spectrum this item is in is on in the given spectrums
func _is_this_spectrum_on(spectrums: int) -> bool:
	return (spectrums & 1 << spectrum) >> spectrum == 1
