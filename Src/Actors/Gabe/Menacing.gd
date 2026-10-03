extends Node2D
## JoJo's "menacing" ゴゴゴ: purple symbols that pop up in little diagonal runs
## either side of their parent, tremble, and fade. Call [method start] to set
## them going.

## The ゴ symbol, a row of pixels per string.
const GLYPH: Array[String] = [
	"        ## ##",
	"#######  ## ##",
	"#######       ",
	"     ##       ",
	"     ##       ",
	"     ##       ",
	"#######       ",
	"#######       ",
]
const COLOR := Color("b050ff")
## Symbols in each run, the step from one to the next (mirrored on the left)
## and the delay before each one appears.
const RUN_LENGTH := 3
const RUN_STEP := Vector2(30, 40)
const RUN_DELAY := 0.12

## Seconds between runs, and how long each symbol lasts.
@export var interval := 0.5
@export var lifetime := 1.3
## How far out from the middle the runs start, and the band of heights they
## start in, in the parent's coordinates.
@export var reach := Vector2(140, 200)
@export var heights := Vector2(-230, 0)

var running := false
var _symbols: Array[Dictionary] = []
var _until_next := 0.0


func start() -> void:
	running = true


func _process(delta: float) -> void:
	if not running:
		return
	_until_next -= delta
	if _until_next <= 0:
		_until_next = interval
		_start_run()
	for symbol in _symbols:
		symbol.age += delta
	_symbols = _symbols.filter(func(symbol: Dictionary) -> bool: return symbol.age < lifetime)
	queue_redraw()


func _draw() -> void:
	for symbol in _symbols:
		if symbol.age < 0:
			continue
		var fade := clampf((lifetime - symbol.age) / (lifetime * 0.4), 0, 1)
		# Tremble by a pixel.
		var jitter := Vector2(randi_range(-1, 1), randi_range(-1, 1)) * PixelArt.SIZE / 2
		PixelArt.bitmap(self, GLYPH, symbol.at + jitter, {"#": Color(COLOR, fade)})


func _start_run() -> void:
	var side := 1.0 if randf() < 0.5 else -1.0
	var start := Vector2(side * randf_range(reach.x, reach.y), randf_range(heights.x, heights.y))
	if side < 0:
		start.x -= PixelArt.bitmap_size(GLYPH).x
	for i in RUN_LENGTH:
		_symbols.append({"at": start + Vector2(side * RUN_STEP.x, RUN_STEP.y) * i, "age": -RUN_DELAY * i})
