extends Path2D
## Malocchio circling the arena. Each time the fire timer runs out it turns to
## face the player and fires its laser, then flies on once the beam ends.

@export var speed := 400.0
@export var max_wobble := 50.0
## Seconds between lasers after [method rapid_fire].
@export var rapid_fire_interval := 3.0

var _firing := false
var _rapid := false
var _noise := FastNoiseLite.new()

@onready var _follow: PathFollow2D = $PathFollow2D
@onready var _malocchio: Node2D = $PathFollow2D/Malocchio
@onready var _fire_timer: Timer = $Timer


func _ready() -> void:
	# Match Godot 3's OpenSimplexNoise defaults.
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.frequency = 1.0 / 64.0
	_noise.fractal_octaves = 3
	_malocchio.laser.armed = true
	_malocchio.laser.finished.connect(_on_laser_finished)


func _process(delta: float) -> void:
	if not _firing:
		_fly(delta)


## Stops the laser countdown, e.g. during the player's turn.
func stop_firing() -> void:
	_fire_timer.stop()


## Restarts the laser countdown from the full interval.
func start_firing() -> void:
	_fire_timer.start()


## Fires the faster laser more often for the rest of the stage.
func rapid_fire() -> void:
	_rapid = true
	_fire_timer.wait_time = rapid_fire_interval


func _fly(delta: float) -> void:
	_malocchio.animation_player.play("float")
	_malocchio.rotate(3.5 * delta)
	_follow.progress += delta * speed
	# Sampled with delta rather than elapsed time, so the wobble stays almost
	# constant. Kept as-is to preserve the original movement.
	_follow.v_offset = _noise.get_noise_1d(delta * 20) * max_wobble


func _on_fire_timer_timeout() -> void:
	_firing = true
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var line_of_sight := player.global_position - _malocchio.global_position
	_malocchio.rotate(line_of_sight.angle() - _malocchio.global_rotation + PI)
	_malocchio.animation_player.play("look")
	_malocchio.laser.get_node("AnimationPlayer").play("FasterFireLaser" if _rapid else "firelaser")


func _on_laser_finished() -> void:
	_firing = false
