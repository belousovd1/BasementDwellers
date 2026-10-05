extends Projectile
## A row of vertices joined by edges that sweeps across the arena, with some
## edges missing for the player to slip through. The row lies along its local
## x axis, so rotate it to sweep sideways. It frees itself once it is well off
## the screen.

## How far off the screen it can go before it is freed.
const SCREEN_MARGIN := 200.0
## Thickness of the hitbox, in pixels.
const THICKNESS := 12.0

@export var speed := 200.0
## Length of the row in pixels, centred on its position.
@export var length := 600.0
@export var vertex_count := 9
## The first missing edge, counting from 0 at the row's left end, or -1 to
## leave none out.
@export var gap_index := -1
## How many edges in a row are missing.
@export var gap_size := 1

var direction := Vector2.DOWN


func _ready() -> void:
	# One hitbox for each unbroken run of edges.
	var runs: Array[Vector2] = []
	if gap_index < 0:
		runs.append(Vector2(0, length))
	else:
		var gap_start := gap_index * _spacing()
		var gap_end := (gap_index + gap_size) * _spacing()
		if gap_start > 0:
			runs.append(Vector2(0, gap_start))
		if gap_end < length:
			runs.append(Vector2(gap_end, length))
	for run in runs:
		var rect := RectangleShape2D.new()
		rect.size = Vector2(run.y - run.x, THICKNESS)
		var hitbox := CollisionShape2D.new()
		hitbox.shape = rect
		hitbox.position.x = (run.x + run.y) / 2 - length / 2
		add_child(hitbox)


func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	if not get_viewport_rect().grow(SCREEN_MARGIN).has_point(global_position):
		queue_free()


func _draw() -> void:
	for i in vertex_count - 1:
		if not _is_missing(i):
			PixelArt.line(self, _vertex(i), _vertex(i + 1), PixelArt.WHITE)
	for i in vertex_count:
		PixelArt.dot(self, _vertex(i), PixelArt.ORANGE, 2)


func _is_missing(edge: int) -> bool:
	return gap_index >= 0 and edge >= gap_index and edge < gap_index + gap_size


func _vertex(index: int) -> Vector2:
	return Vector2(index * _spacing() - length / 2, 0)


func _spacing() -> float:
	return length / (vertex_count - 1)
