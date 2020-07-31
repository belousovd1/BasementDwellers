extends Area2D
var damage = 20

# Declare member variables here. Examples:
var dir = Vector2.ZERO
var speed = 300 
var pound = false 
var side = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if side == "right":
		self.global_position.x -=  speed * delta
	elif side == "left": 
		self.global_position.x +=  speed * delta




func check_side():
	if self.global_position.x > 536:
		side ="right"
	else:
		side = "left"


