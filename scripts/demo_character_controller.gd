extends Sprite

# Constant: SPEED
# Player movement speed
const SPEED = 500


# Func: _ready
# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Func: _input
# Detect one-off input events.
#
# Parameters:
#  event - triggered event
func _input(event):
	if event.is_action_pressed("ui_accept"):
		scale *= 1.1


# Func: _process
# Called every frame.
#
# Parameters:
#	delta - Different in time between frames
func _process(delta):
	if Input.is_action_pressed("ui_left"):
		position.x -= SPEED * delta
	if Input.is_action_pressed("ui_right"):
		position.x += SPEED * delta
	if Input.is_action_pressed("ui_up"):
		position.y -= SPEED * delta
	if Input.is_action_pressed("ui_down"):
		position.y += SPEED * delta


# Func: _handle_item_entrance
# Called by signal handlers for when an item enters the lamp region.
#
# Parameters:
#	item - item that entered the region (can be Area2D or Node)
func _handle_item_entrance(item):
	if item.has_method("on_lamp_entered"):
		item.on_lamp_entered("1-2")


# Func: _handle_item_exit
# Called by signal handlers for when an item exits the lamp region.
#
# Parameters:
#	item - item that entered the region (can be Area2D or Node)
func _handle_item_exit(item):
	if item.has_method("on_lamp_exited"):
		item.on_lamp_exited("1-2")


# Func: _on_LampArea_area_entered
# Signal receiver for when an Area2D enters the lamp region.
#
# Parameters:
#	area - Area2D that entered the region
func _on_LampArea_area_entered(area: Area2D):
	_handle_item_entrance(area)


# Func: _on_LampArea_area_exited
# Signal receiver for when an Area2D exits the lamp region.
#
# Parameters:
#	area - Area2D that exited the region
func _on_LampArea_area_exited(area: Area2D):
	_handle_item_exit(area)


# Func: _on_LampArea_body_entered
# Signal receiver for when a Node enters the lamp region.
#
# Parameters:
#	node - Node that entered the region
func _on_LampArea_body_entered(body: Node):
	_handle_item_entrance(body)


# Func: _on_LampArea_body_exited
# Signal receiver for when a Node exits the lamp region.
#
# Parameters:
#	node - Node that exited the region
func _on_LampArea_body_exited(body: Node):
	_handle_item_exit(body)
