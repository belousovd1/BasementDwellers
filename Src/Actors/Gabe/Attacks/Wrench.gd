extends Projectile
## A wrench thrown end over end in a straight line: an open jaw at one end and
## a ring at the other. It frees itself once it is well off the screen.

## Where the parts sit along the wrench, in pixels from its middle.
const JAW_AT := 14.0
const JAW_LENGTH := 9.0
const JAW_WIDTH := 6.0
const RING_AT := -18.0
const RING_RADIUS := 6.0
const METAL := Color(0.75, 0.77, 0.82)
## Radians per second it turns.
const SPIN := 11.0
## How far off the screen it can go before it is freed.
const SCREEN_MARGIN := 200.0

@export var speed := 420.0

var direction := Vector2.DOWN
var _turn := 0.0


func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	_turn += SPIN * delta
	queue_redraw()
	if not get_viewport_rect().grow(SCREEN_MARGIN).has_point(global_position):
		queue_free()


## Drawn turned by hand rather than by rotating the node, so its pixels stay on
## the grid.
func _draw() -> void:
	var along := Vector2.from_angle(_turn)
	var across := along.orthogonal()
	var jaw := along * JAW_AT
	PixelArt.line(self, along * RING_AT, jaw, METAL, 2)
	# The open jaw: a crossbar and two prongs.
	PixelArt.line(self, jaw + across * JAW_WIDTH, jaw - across * JAW_WIDTH, PixelArt.WHITE, 2)
	for side in [-1.0, 1.0]:
		var prong: Vector2 = jaw + across * JAW_WIDTH * side
		PixelArt.line(self, prong, prong + along * JAW_LENGTH, PixelArt.WHITE, 2)
	# The ring.
	var ring := along * RING_AT
	for i in 12:
		PixelArt.dot(self, ring + Vector2.from_angle(TAU * i / 12) * RING_RADIUS, PixelArt.WHITE)
