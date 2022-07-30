extends Sprite

# Constant: SPEED
# Player movement speed
const SPEED = 200


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
