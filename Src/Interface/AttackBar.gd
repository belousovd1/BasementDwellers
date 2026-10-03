extends Node2D
## The player's attack: an indicator sweeps back and forth across the bar and
## the player presses accept to stop it. The closer to the centre, the more
## damage the hit does. It starts at the right-hand end, so there is no free
## hit in the middle.
##
## It is drawn in chunky pixels like the rest of the fight: bands that get
## hotter towards the middle, a target marker over it, and an indicator that
## moves a whole pixel at a time with a short trail. Where it stops, the
## indicator and its band flash and the bar rates the hit.

## Emitted once, when the player stops the indicator.
signal struck(damage: int)

const MAX_DAMAGE := 100
## Half the width of the track, in art pixels; the damage falls to zero at its
## ends. Its height, and the space round it inside the frame.
const HALF_WIDTH := 206
const TRACK_HEIGHT := 18
const PADDING := 4
const BORDER := 2
## Seconds for the indicator to sweep from the right-hand end to the left and
## back again: normally, and in a boss's final stage.
const PERIOD := 4.0
const FAST_PERIOD := 2.0
const TRAIL := 3
const OPEN_TIME := 0.12
const FLASH := 0.08
## The bands, from the middle out: the least damage a hit in each does, its
## colour, and what a hit there is called.
const BANDS: Array[Dictionary] = [
	{"damage": 95, "color": Color("fff3b0"), "name": "CRITICAL!"},
	{"damage": 80, "color": Color("ffe14d"), "name": "GREAT"},
	{"damage": 55, "color": Color("ffa000"), "name": "GOOD"},
	{"damage": 25, "color": Color("e8603c"), "name": "OK"},
	{"damage": 0, "color": Color("7a2a3a"), "name": "WEAK"},
]

## Uses the faster sweep from the final stage.
@export var fast := false

var _time := 0.0
var _struck := false
var _strike_time := 0.0
var _band := {}
## The indicator's distance from the middle in pixels, a whole art pixel at a
## time, and where it was over the last few frames.
var _offset := 0.0
var _trail: Array[float] = []

@onready var _rating: Label = $Rating


func _ready() -> void:
	_rating.hide()
	_offset = _sweep(0.0) * HALF_WIDTH * PixelArt.SIZE
	# Open out from a line, like a window.
	scale.y = 0.0
	create_tween().tween_property(self, "scale:y", 1.0, OPEN_TIME)


func _process(delta: float) -> void:
	if _struck:
		_strike_time += delta
		queue_redraw()
		return
	if Input.is_action_pressed("ui_accept"):
		_strike()
		return
	_time += delta
	_trail.push_front(_offset)
	_trail.resize(mini(_trail.size(), TRAIL))
	var reach := HALF_WIDTH * PixelArt.SIZE
	_offset = snappedf(_sweep(_time / (FAST_PERIOD if fast else PERIOD)) * reach, PixelArt.SIZE)
	queue_redraw()


func get_damage() -> int:
	return roundi((1.0 - absf(_offset) / (HALF_WIDTH * PixelArt.SIZE)) * MAX_DAMAGE)


func _strike() -> void:
	_struck = true
	_trail.clear()
	var damage := get_damage()
	_band = _band_for(damage)
	_rating.text = "%s %d" % [_band.name, damage]
	# A little lighter than the band, so even the darkest reads on black.
	_rating.add_theme_color_override("font_color", _band.color.lightened(0.3))
	_rating.reset_size()
	var edge := (HALF_WIDTH + PADDING) * PixelArt.SIZE - _rating.size.x / 2
	_rating.position.x = clampf(_offset, -edge, edge) - _rating.size.x / 2
	_rating.show()
	# Pop in, then settle.
	_rating.pivot_offset = _rating.size / 2
	_rating.scale = Vector2.ONE * 1.5
	create_tween().tween_property(_rating, "scale", Vector2.ONE, 0.15)
	queue_redraw()
	struck.emit(damage)


func _draw() -> void:
	var pixel := PixelArt.SIZE
	var track := Rect2(-HALF_WIDTH, -TRACK_HEIGHT / 2.0, HALF_WIDTH * 2, TRACK_HEIGHT)
	var panel := track.grow(PADDING + BORDER)

	# The frame: black, with a white border and its corners cut off.
	_fill(panel, PixelArt.BLACK)
	for ring in BORDER:
		PixelArt.outline(self, _px(panel.grow(-ring)), PixelArt.WHITE)
	for corner in [panel.position, Vector2(panel.end.x - 1, panel.position.y),
			Vector2(panel.position.x, panel.end.y - 1), panel.end - Vector2.ONE]:
		_clear(corner)

	# The bands, outermost first, each lit on top and shaded underneath, with a
	# notch between neighbours.
	for i in range(BANDS.size() - 1, -1, -1):
		var band: Dictionary = BANDS[i]
		var half := roundi((1.0 - band.damage / float(MAX_DAMAGE)) * HALF_WIDTH) if i < BANDS.size() - 1 else HALF_WIDTH
		var rect := Rect2(-half, track.position.y, half * 2, TRACK_HEIGHT)
		var color: Color = band.color
		if _struck and band == _band and fmod(_strike_time, FLASH * 2) < FLASH:
			color = color.lightened(0.35)
		_fill(rect, color)
		_fill(Rect2(rect.position, Vector2(rect.size.x, 2)), color.lightened(0.3))
		_fill(Rect2(rect.position + Vector2(0, TRACK_HEIGHT - 3), Vector2(rect.size.x, 3)), color.darkened(0.35))
		if i < BANDS.size() - 1:
			for side in [-1, 1]:
				_fill(Rect2(side * half - (1 if side > 0 else 0), track.position.y, 1, TRACK_HEIGHT), PixelArt.BLACK)
				# Ticks above and below the track.
				_fill(Rect2(side * half - (1 if side > 0 else 0), track.position.y - 2, 1, 1), PixelArt.WHITE)
				_fill(Rect2(side * half - (1 if side > 0 else 0), track.end.y + 1, 1, 1), PixelArt.WHITE)

	# Target arrows pointing at the middle from above and below.
	for row in 3:
		_fill(Rect2(-(3 - row), track.position.y - 4 + row, (3 - row) * 2, 1), PixelArt.WHITE)
		_fill(Rect2(-(3 - row), track.end.y + 3 - row, (3 - row) * 2, 1), PixelArt.WHITE)

	# The indicator's trail, then the indicator: a white bar outlined in black,
	# reaching past the track, flashing once it has stopped.
	for i in _trail.size():
		var shade := Color(PixelArt.WHITE, 0.45 - 0.13 * i)
		_fill(Rect2(_trail[i] / pixel - 1, track.position.y, 2, TRACK_HEIGHT), shade)
	var x := _offset / pixel
	var bar := Rect2(x - 1, track.position.y - 3, 2, TRACK_HEIGHT + 6)
	_fill(bar.grow(1), PixelArt.BLACK)
	var bar_color := PixelArt.WHITE
	if _struck and fmod(_strike_time, FLASH * 2) >= FLASH:
		bar_color = _band.color
	_fill(bar, bar_color)


## Goes 1 → -1 → 1 as [param t] goes from 0 to 1, in straight lines: from the
## right-hand end to the left and back.
func _sweep(t: float) -> float:
	var phase := fposmod(t, 1.0)
	if phase < 0.5:
		return 1 - phase * 4
	return -1 + (phase - 0.5) * 4


func _band_for(damage: int) -> Dictionary:
	for band in BANDS:
		if damage >= band.damage:
			return band
	return BANDS[-1]


## Fills [param rect], given in art pixels.
func _fill(rect: Rect2, color: Color) -> void:
	draw_rect(_px(rect), color)


## Cuts the art pixel at [param cell] out of the frame, back to the background.
func _clear(cell: Vector2) -> void:
	draw_rect(_px(Rect2(cell, Vector2.ONE)), PixelArt.BLACK)


func _px(rect: Rect2) -> Rect2:
	return Rect2(rect.position * PixelArt.SIZE, rect.size * PixelArt.SIZE)
