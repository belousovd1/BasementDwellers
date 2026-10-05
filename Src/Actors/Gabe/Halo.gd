extends Node2D
## The golden halo Gabe wears once Dunkey has blessed him: a thick pixel ring
## over his head with a soft glow, bobbing gently and glinting now and then.
## Hidden until [method appear].

const GOLD := Color("ffd84a")
const LIGHT := Color("fff6c0")
const GLOW := Color(1.0, 0.85, 0.3, 0.16)
## Half the ring's width and height, in art pixels.
const RADIUS := Vector2(9, 3)
## How far above its resting place it starts when it descends.
const DESCENT := 700.0
const GLINT_EVERY := 1.6

var _time := 0.0
var _rest_y := 0.0


func _ready() -> void:
	_rest_y = position.y
	hide()


## Shows the halo, floating down onto his head over [param descend_time]
## seconds, or there at once if that is 0.
func appear(descend_time := 0.0) -> void:
	show()
	if descend_time <= 0.0:
		return
	position.y = _rest_y - DESCENT
	modulate.a = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "position:y", _rest_y, descend_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, descend_time * 0.5)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var bob := Vector2(0, roundf(sin(_time * 2.5)) * PixelArt.SIZE)
	var glow := PackedVector2Array()
	for i in 24:
		var angle := TAU * i / 24
		glow.append(bob + Vector2(cos(angle) * (RADIUS.x + 4), sin(angle) * (RADIUS.y + 3)) * PixelArt.SIZE)
	draw_colored_polygon(glow, GLOW)
	# Two rings, one inside the other, for a thick band. The top left catches
	# the light.
	for ring in [RADIUS, RADIUS - Vector2.ONE]:
		for i in 48:
			var angle := TAU * i / 48
			var lit := angle > PI * 1.05 and angle < PI * 1.6
			PixelArt.dot(self, bob + Vector2(cos(angle) * ring.x, sin(angle) * ring.y) * PixelArt.SIZE,
					LIGHT if lit else GOLD)
	# A glint that runs round the ring now and then.
	var glint := fmod(_time, GLINT_EVERY) / 0.4
	if glint < 1.0:
		var angle := PI + glint * PI
		PixelArt.dot(self, bob + Vector2(cos(angle) * RADIUS.x, sin(angle) * RADIUS.y) * PixelArt.SIZE,
				PixelArt.WHITE, 2)
