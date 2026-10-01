extends Path2D


# Declare member variables here. Examples:
# var a = 2
@onready var path = $PathFollow2D
var speed = 400
var noise = FastNoiseLite.new()
var time = 0
@onready var malocchio = $PathFollow2D/Malocchio
@onready var player = $"../../../Player"
var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Match Godot 3 OpenSimplexNoise defaults
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 1.0 / 64.0
	noise.fractal_octaves = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if not attacking:
		follow_path(delta)



func follow_path(delta):
	$PathFollow2D/Malocchio/AnimationPlayer.play("float")
	var max_dis = 50
	malocchio.rotate(3.5 * delta)
	path.progress += delta * speed
	path.v_offset = noise.get_noise_1d(delta * 20) * max_dis


func shoot_laser():
	attacking = true
	var line_of_sight = player.global_position - malocchio.global_position
	var turn = line_of_sight.angle() - malocchio.global_rotation
	malocchio.rotate(turn + PI)
	$PathFollow2D/Malocchio/AnimationPlayer.play("look")
	$PathFollow2D/Malocchio/LaserBeam/AnimationPlayer.play("firelaser")

func shoot_fast_laser():
	attacking = true
	var line_of_sight = player.global_position - malocchio.global_position
	var turn = line_of_sight.angle() - malocchio.global_rotation
	malocchio.rotate(turn + PI)
	$PathFollow2D/Malocchio/AnimationPlayer.play("look")
	$PathFollow2D/Malocchio/LaserBeam/AnimationPlayer.play("FasterFireLaser")

func stop_attacking():
	attacking = false
	
func rapid_fire():
	$Timer.set_wait_time(3)
	$Timer.disconnect("timeout", Callable(self, "shoot_laser"))
	var _err = $Timer.connect("timeout", Callable(self, "shoot_fast_laser"))