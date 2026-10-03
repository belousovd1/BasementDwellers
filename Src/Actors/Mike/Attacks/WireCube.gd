extends Projectile
## Blender's default cube as a spinning wireframe, flying in a straight line.
## The far edges are dimmer and the near corners are lit like selected
## vertices. It frees itself once it is well off the screen.

## Corners of a cube two units across, and the pairs of corners joined by edges.
const CORNERS: Array[Vector3] = [
	Vector3(-1, -1, -1), Vector3(1, -1, -1), Vector3(1, 1, -1), Vector3(-1, 1, -1),
	Vector3(-1, -1, 1), Vector3(1, -1, 1), Vector3(1, 1, 1), Vector3(-1, 1, 1),
]
const EDGES: Array[Vector2i] = [
	Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3), Vector2i(3, 0),
	Vector2i(4, 5), Vector2i(5, 6), Vector2i(6, 7), Vector2i(7, 4),
	Vector2i(0, 4), Vector2i(1, 5), Vector2i(2, 6), Vector2i(3, 7),
]
## How far off the screen it can go before it is freed.
const SCREEN_MARGIN := 200.0

@export var speed := 250.0
## Half the length of an edge, in pixels. The hitbox is a circle this big.
@export var half_size := 24.0
## Radians per second around the x, y and z axes.
@export var spin := Vector3(1.7, 2.3, 0.4)

var direction := Vector2.DOWN
var _angles := Vector3(randf() * TAU, randf() * TAU, 0.0)


func _ready() -> void:
	($CollisionShape2D.shape as CircleShape2D).radius = half_size


func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	_angles += spin * delta
	queue_redraw()
	if not get_viewport_rect().grow(SCREEN_MARGIN).has_point(global_position):
		queue_free()


func _draw() -> void:
	var turn := Basis.from_euler(_angles)
	var corners: Array[Vector3] = []
	for corner in CORNERS:
		corners.append(turn * corner * half_size)
	# Far edges first, so the near ones are drawn over them.
	var edges := EDGES.duplicate()
	edges.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return corners[a.x].z + corners[a.y].z < corners[b.x].z + corners[b.y].z)
	for edge in edges:
		var near := corners[edge.x].z + corners[edge.y].z > 0
		PixelArt.line(self, _flat(corners[edge.x]), _flat(corners[edge.y]),
				PixelArt.WHITE if near else PixelArt.GREY)
	for corner in corners:
		if corner.z > 0:
			PixelArt.dot(self, _flat(corner), PixelArt.ORANGE, 2)


func _flat(point: Vector3) -> Vector2:
	return Vector2(point.x, point.y)
