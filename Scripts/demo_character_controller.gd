extends Sprite

# Player movement SPEED
const SPEED = 200


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Detect one-off input events.
func _input(event):
	if event.is_action_pressed("ui_accept"):
		scale *= 1.1


# Called every frame.
func _process(delta):
	if Input.is_action_pressed("ui_left"):
		position.x -= SPEED * delta
	if Input.is_action_pressed("ui_right"):
		position.x += SPEED * delta
	if Input.is_action_pressed("ui_up"):
		position.y -= SPEED * delta
	if Input.is_action_pressed("ui_down"):
		position.y += SPEED * delta
