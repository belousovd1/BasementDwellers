extends Bouncer
## A vinyl record bouncing off the arena walls, spinning: black grooves round a
## coloured label.

## Radius of the record and of its label, in art pixels.
const RADIUS := 9
const LABEL := 3
const SPIN := 5.0
const GROOVES := Color(0.22, 0.22, 0.26)
const SHINE := Color(0.55, 0.55, 0.62)

@export var label_color := Color("e8417a")

var _turn := 0.0


func _init() -> void:
	radius = RADIUS * PixelArt.SIZE


func _moved(delta: float) -> void:
	_turn += SPIN * delta


func _draw() -> void:
	if is_blinked_out():
		return
	for y in range(-RADIUS, RADIUS):
		for x in range(-RADIUS, RADIUS):
			var cell := Vector2(x, y) + Vector2(0.5, 0.5)
			var distance := cell.length()
			if distance > RADIUS:
				continue
			var color: Color
			if distance > RADIUS - 1:
				color = PixelArt.WHITE
			elif distance > LABEL:
				# Grooves, with a glint that turns as the record spins.
				var glint := absf(angle_difference(cell.angle(), _turn)) < 0.25
				color = SHINE if glint else (GROOVES if int(distance) % 2 == 0 else PixelArt.BLACK)
			elif distance > 1:
				color = label_color
			else:
				color = PixelArt.BLACK
			PixelArt.dot(self, cell * PixelArt.SIZE, color)
