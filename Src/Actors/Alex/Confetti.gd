extends Node2D
## Confetti for the encore: bursts of coloured paper fluttering down around
## their parent. Call [method start] to set it going.

const COLORS: Array[Color] = [
	Color("e8417a"), Color("f7d13c"), Color("5fcde4"), Color("99e550"), Color("f5872b"), Color.WHITE,
]

## Seconds between bursts, pieces per burst, and how long a piece falls.
@export var interval := 0.6
@export var burst := 14
@export var lifetime := 2.2
## Where bursts go off, in the parent's coordinates.
@export var area := Rect2(-260, -280, 520, 160)
@export var fall_speed := 110.0

var running := false
var _pieces: Array[Dictionary] = []
var _until_next := 0.0


func start() -> void:
	running = true


func _process(delta: float) -> void:
	if not running:
		return
	_until_next -= delta
	if _until_next <= 0:
		_until_next = interval
		_burst()
	for piece in _pieces:
		piece.age += delta
		piece.at += Vector2(sin(piece.age * 5 + piece.phase) * 40, fall_speed) * delta
	_pieces = _pieces.filter(func(piece: Dictionary) -> bool: return piece.age < lifetime)
	queue_redraw()


func _draw() -> void:
	for piece in _pieces:
		var fade := clampf((lifetime - piece.age) / 0.5, 0, 1)
		# Pieces flip as they flutter: wide, then tall.
		var size := Vector2(2, 1) if int(piece.age * 8 + piece.phase) % 2 == 0 else Vector2(1, 2)
		draw_rect(Rect2(piece.at, size * PixelArt.SIZE), Color(piece.color, fade))


func _burst() -> void:
	var middle := area.position + Vector2(randf() * area.size.x, randf() * area.size.y)
	for _piece in burst:
		_pieces.append({
			"at": middle + Vector2(randf_range(-40, 40), randf_range(-30, 30)),
			"age": 0.0,
			"phase": randf() * TAU,
			"color": COLORS.pick_random(),
		})
