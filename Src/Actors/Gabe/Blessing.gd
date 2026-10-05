extends Node2D
## Dunkey's blessing, at the end of Gabe's entrance: a pillar of golden light
## opens down onto [member target] with sparkles falling through it, his halo
## floats down onto his head, then a flash, a chime, he glows gold and
## "BLESSED BY DUNKEY" slams in. The pillar closes, and [signal finished] is
## emitted before it frees itself. Drawn in screen space.

signal finished

const GOLD := Color("ffd84a")
const LIGHT := Color("fff6c0")
const BEAM := Color(1.0, 0.85, 0.3, 0.2)
const CORE := Color(1.0, 0.96, 0.75, 0.22)
const TITLE := "[center][rage level=4 slam=2.5 size=96][color=#ffd84a]BLESSED BY DUNKEY[/color][/rage][/center]"
## How wide the pillar opens, in pixels.
const BEAM_WIDTH := 240.0
## When each part happens, in seconds from the start.
const OPEN_TIME := 0.6
const HALO_AT := 0.4
const HALO_TIME := 1.3
const FLASH_AT := 1.8
const FLASH_TIME := 0.45
const CLOSE_AT := 3.0
const END_AT := 3.6
## Sparkles started per second, and how long each lasts.
const SPARKLE_RATE := 16.0
const SPARKLE_LIFE := 1.4
## How brightly he glows at the flash, as a modulate.
const GLOW := Color(1.9, 1.6, 0.8)

## The Gabe being blessed.
var target: Gabe

var _time := 0.0
var _sparkles: Array[Dictionary] = []
var _owed := 0.0
var _beam_x := 0.0
var _beam_bottom := 0.0
var _halo_started := false
var _flashed := false

@onready var _chime: AudioStreamPlayer = $Chime
@onready var _title: RichTextLabel = $Title


func _ready() -> void:
	# From the top of the screen down to his feet.
	_beam_x = target.global_position.x
	_beam_bottom = target.global_position.y + 240 * target.scale.y
	_title.install_effect(RageEffect.new())
	_title.hide()


func _process(delta: float) -> void:
	_time += delta
	if _time >= HALO_AT and not _halo_started:
		_halo_started = true
		target.bless(HALO_TIME)
	if _time >= FLASH_AT and not _flashed:
		_flashed = true
		_flash()
	if _time >= END_AT:
		finished.emit()
		queue_free()
		return
	_update_sparkles(delta)
	queue_redraw()


func _flash() -> void:
	_chime.play()
	_title.text = TITLE
	_title.show()
	var glow := create_tween()
	glow.tween_property(target, "modulate", GLOW, 0.15)
	glow.tween_property(target, "modulate", Color.WHITE, 0.9)
	var title := create_tween()
	title.tween_interval(CLOSE_AT - FLASH_AT)
	title.tween_property(_title, "modulate:a", 0.0, END_AT - CLOSE_AT)


func _update_sparkles(delta: float) -> void:
	if _time < CLOSE_AT:
		_owed += SPARKLE_RATE * delta
	while _owed >= 1.0:
		_owed -= 1.0
		_sparkles.append({
			"at": Vector2(_beam_x + randf_range(-0.45, 0.45) * BEAM_WIDTH, randf_range(0, _beam_bottom * 0.7)),
			"fall": randf_range(40, 90),
			"age": 0.0,
		})
	for sparkle in _sparkles:
		sparkle.age += delta
		sparkle.at.y += sparkle.fall * delta
	_sparkles = _sparkles.filter(func(s: Dictionary) -> bool: return s.age < SPARKLE_LIFE)


## How open the pillar is, from 0 to 1.
func _openness() -> float:
	if _time < OPEN_TIME:
		return ease(_time / OPEN_TIME, 0.4)
	if _time > CLOSE_AT:
		return 1.0 - ease(minf((_time - CLOSE_AT) / (END_AT - CLOSE_AT), 1.0), 2.0)
	return 1.0


func _draw() -> void:
	var width := BEAM_WIDTH * _openness()
	if width >= PixelArt.SIZE:
		var beam := Rect2(_beam_x - width / 2, 0, width, _beam_bottom)
		PixelArt.fill(self, beam, BEAM)
		PixelArt.fill(self, beam.grow_individual(-width * 0.3, 0, -width * 0.3, 0), CORE)
		# Streaks of light pouring down it.
		for i in 7:
			var x := _beam_x + (fposmod(i * 0.37, 1.0) - 0.5) * width * 0.8
			var y := fposmod(_time * 520 + i * 157, _beam_bottom + 80) - 80
			PixelArt.fill(self, Rect2(x, y, PixelArt.SIZE, 64), Color(LIGHT, 0.35))
		PixelArt.line(self, beam.position, Vector2(beam.position.x, beam.end.y), GOLD)
		PixelArt.line(self, Vector2(beam.end.x, 0), beam.end, GOLD)
	for sparkle in _sparkles:
		_draw_sparkle(sparkle)
	if _time >= FLASH_AT and _time < FLASH_AT + FLASH_TIME:
		var fade := 1.0 - (_time - FLASH_AT) / FLASH_TIME
		draw_rect(get_viewport_rect(), Color(1, 1, 1, 0.75 * fade))


## A twinkling plus: a bright middle with arms that grow and shrink.
func _draw_sparkle(sparkle: Dictionary) -> void:
	var at: Vector2 = sparkle.at
	var life: float = sparkle.age / SPARKLE_LIFE
	var arm := roundi(sin(life * PI) * 2.0)
	PixelArt.dot(self, at, LIGHT)
	for i in range(1, arm + 1):
		for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			PixelArt.dot(self, at + direction * i * PixelArt.SIZE, GOLD)
