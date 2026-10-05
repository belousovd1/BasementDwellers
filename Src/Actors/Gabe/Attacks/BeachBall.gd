extends Projectile
## The spinning beach ball: a rainbow pinwheel turning in the middle, with arms
## of rainbow dots sweeping round it and fading ghosts trailing behind each arm.
## It fades in harmlessly, hurts while it spins for [member spin_time] seconds,
## then fades out and frees itself.

## The beach ball's colours, round the wheel.
const COLORS: Array[Color] = [
	Color("5ac739"), Color("2f9bf0"), Color("8e4fd6"), Color("e8417a"), Color("f5872b"), Color("f7d13c"),
]
const FADE_TIME := 0.8
## Ghost arms trailing behind each arm, and the angle between them.
const GHOSTS := 3
const GHOST_STEP := 0.14
## Radius of each dot's hitbox, and of the pinwheel, in pixels.
const DOT_RADIUS := 9.0
const WHEEL_RADIUS := 20.0

## Dots in each arm, counting the pinwheel, and the gap between them.
@export var dot_count := 9
@export var spacing := 32.0
## Arms, spaced evenly around the middle.
@export var arms := 1
## Radians per second. Negative turns anticlockwise.
@export var turn_speed := 1.2
@export var spin_time := 6.0

var _angle := 0.0
var _time := 0.0
var _hitboxes: Array[CollisionShape2D] = []

@onready var _sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	for _dot in arms * dot_count:
		var circle := CircleShape2D.new()
		circle.radius = DOT_RADIUS
		var hitbox := CollisionShape2D.new()
		hitbox.shape = circle
		hitbox.disabled = true
		add_child(hitbox)
		_hitboxes.append(hitbox)


func _process(delta: float) -> void:
	var was_spinning := _is_spinning()
	_time += delta
	if _is_spinning():
		_angle += turn_speed * delta
		if not was_spinning:
			_sound.play()
	if _time > FADE_TIME * 2 + spin_time:
		queue_free()
		return
	for arm in arms:
		for i in dot_count:
			var hitbox := _hitboxes[arm * dot_count + i]
			hitbox.position = _dot_position(arm, i, 0.0)
			hitbox.disabled = not _is_spinning()
	queue_redraw()


func _draw() -> void:
	if not _is_spinning():
		# Fading in or out: a dim wheel and dots, blinking.
		if fmod(_time, 0.2) < 0.1:
			for arm in arms:
				for i in range(1, dot_count):
					PixelArt.dot(self, _dot_position(arm, i, 0.0), PixelArt.GREY, 2)
			_draw_wheel(true)
		return
	var behind := -signf(turn_speed) * GHOST_STEP
	for arm in arms:
		for ghost in range(GHOSTS, 0, -1):
			for i in range(1, dot_count):
				var color := _dot_color(arm, i).darkened(0.25 + 0.2 * ghost)
				PixelArt.dot(self, _dot_position(arm, i, behind * ghost), color, 2)
		for i in range(1, dot_count):
			PixelArt.dot(self, _dot_position(arm, i, 0.0), _dot_color(arm, i), 3)
	_draw_wheel(false)


## The pinwheel in the middle, its wedges turning with the arms.
func _draw_wheel(dim: bool) -> void:
	var cells := ceili(WHEEL_RADIUS / PixelArt.SIZE)
	for y in range(-cells, cells):
		for x in range(-cells, cells):
			var at := (Vector2(x, y) + Vector2(0.5, 0.5)) * PixelArt.SIZE
			if at.length() > WHEEL_RADIUS:
				continue
			var wedge := posmod(floori((at.angle() - _angle) / TAU * COLORS.size()), COLORS.size())
			var color := PixelArt.GREY if dim else COLORS[wedge]
			if at.length() > WHEEL_RADIUS - PixelArt.SIZE:
				color = PixelArt.WHITE if not dim else color
			PixelArt.dot(self, at, color)


func _dot_color(arm: int, index: int) -> Color:
	return COLORS[(arm + index) % COLORS.size()]


func _is_spinning() -> bool:
	return _time >= FADE_TIME and _time < FADE_TIME + spin_time


func _dot_position(arm: int, index: int, angle_offset: float) -> Vector2:
	return Vector2.from_angle(_angle + TAU * arm / arms + angle_offset) * spacing * index
