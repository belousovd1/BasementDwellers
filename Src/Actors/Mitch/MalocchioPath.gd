extends Path2D


# Declare member variables here. Examples:
# var a = 2
onready var path = $PathFollow2D
var speed = 400
var noise = OpenSimplexNoise.new()
var time = 0
onready var malocchio = $PathFollow2D/Malocchio
onready var player = $"../../../Player"
var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if not attacking:
		follow_path(delta)



func follow_path(delta):
	$PathFollow2D/Malocchio/AnimationPlayer.play("float")
	var max_dis = 50
	malocchio.rotate(3.5 * delta)
	path.set_offset(path.get_offset() + delta * speed)
	path.v_offset = noise.get_noise_1d(delta * 20) * max_dis


func shoot_laser():
	attacking = true
	var line_of_sight = player.global_position - malocchio.global_position
	var turn = line_of_sight.angle() - malocchio.global_rotation
	malocchio.rotate(turn + PI)
	$PathFollow2D/Malocchio/AnimationPlayer.play("look")
	$PathFollow2D/Malocchio/LaserBeam/AnimationPlayer.play("firelaser")


func stop_attacking():
	attacking = false
	
