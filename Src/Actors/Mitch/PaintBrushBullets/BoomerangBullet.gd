extends "res://Src/objects/Projectiles.gd"


var speed = 300
var dir = Vector2.ZERO
onready var vis_nod = $VisibilityNotifier2D
signal projectile_passed

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(10.5 * delta)
	self.position +=  dir.normalized() * speed * delta

			
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
