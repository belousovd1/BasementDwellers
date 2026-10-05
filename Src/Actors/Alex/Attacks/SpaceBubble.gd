extends Projectile
## A giant bubble rolling slowly across the arena, like the one a certain band
## rolls over its crowds. It bobs as it goes and frees itself once it is well
## off the screen.

## Radius in art pixels.
const RADIUS := 20
const BOB := 12.0
const SCREEN_MARGIN := 300.0
const SHIMMER: Array[Color] = [Color("5fcde4"), Color("d77bba"), Color("f7d13c"), Color.WHITE]

@export var speed := 140.0

var direction := Vector2.RIGHT
var _path_point := Vector2.ZERO
var _time := 0.0


func _ready() -> void:
	_path_point = position


func _process(delta: float) -> void:
	_time += delta
	_path_point += direction.normalized() * speed * delta
	position = _path_point + Vector2(0, sin(_time * 2.0) * BOB)
	queue_redraw()
	if not get_viewport_rect().grow(SCREEN_MARGIN).has_point(global_position):
		queue_free()


func _draw() -> void:
	var r := RADIUS * PixelArt.SIZE
	draw_circle(Vector2.ZERO, r, Color(1, 1, 1, 0.06))
	# The skin: a ring of pixels shimmering through a few colours.
	var steps := RADIUS * 8
	for i in steps:
		var angle := TAU * i / steps
		var color := SHIMMER[int(i * 4.0 / steps + _time * 3.0) % SHIMMER.size()]
		PixelArt.dot(self, Vector2.from_angle(angle) * (r - PixelArt.SIZE / 2), color)
	# A highlight up on the left.
	for i in 6:
		var angle := PI * 1.1 + i * 0.12
		PixelArt.dot(self, Vector2.from_angle(angle) * (r * 0.72), PixelArt.WHITE)
