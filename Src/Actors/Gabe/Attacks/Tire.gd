class_name Tire
extends Bouncer
## A loose tyre bouncing off the arena walls, its rim turning as it rolls.

## Radius of the tyre and of its rim, in art pixels.
const RADIUS := 8
const RIM := 4
const SPOKES := 5
const RUBBER := Color(0.1, 0.1, 0.12)
const TREAD := Color(0.3, 0.3, 0.34)
const METAL := Color(0.75, 0.77, 0.82)

var _turn := 0.0


func _init() -> void:
	radius = RADIUS * PixelArt.SIZE


## Roll: the rim turns with the distance travelled sideways.
func _moved(delta: float) -> void:
	_turn += _velocity.x / radius * delta


func _draw() -> void:
	if is_blinked_out():
		return
	for y in range(-RADIUS, RADIUS):
		for x in range(-RADIUS, RADIUS):
			var cell := Vector2(x, y) + Vector2(0.5, 0.5)
			var distance := cell.length()
			if distance > RADIUS:
				continue
			var angle := cell.angle() - _turn
			var color: Color
			if distance > RADIUS - 1:
				color = PixelArt.WHITE
			elif distance > RIM + 1:
				# Tread blocks round the outside.
				var notch := fposmod(angle / TAU * 12, 1.0) < 0.5
				color = TREAD if notch and distance > RADIUS - 2 else RUBBER
			elif distance > RIM:
				color = METAL
			else:
				var spoke := absf(fposmod(angle / TAU * SPOKES + 0.5, 1.0) - 0.5) < 0.12
				color = METAL if spoke or distance < 1.2 else RUBBER
			PixelArt.dot(self, cell * PixelArt.SIZE, color)
