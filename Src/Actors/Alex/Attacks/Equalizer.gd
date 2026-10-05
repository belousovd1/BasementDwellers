extends Projectile
## Equalizer bars standing on the arena floor and jumping to the beat. Each
## step, the next heights show as dashed lines while the bars hold, and then the
## bars jump to them, so every jump is shown a step ahead. The bars hurt; the
## space above them is safe. It frees itself after its last step.
##
## Sits at the middle of the arena floor: bars rise along its local -y axis.

## The meter's colours, from the bottom of a bar to the top.
const LOW := Color("3cc83c")
const MID := Color("f7d13c")
const HIGH := Color("e83030")
## Height of each lit segment of a bar, and the gap between them, in art pixels.
const SEGMENT := 3
const GAP := 1
const JUMP_TIME := 0.06

## Width and greatest height of the meter, in pixels.
@export var width := 548.0
@export var max_height := 460.0
@export var step_time := 1.0

## The heights to jump to, step by step: for each step, one height per bar
## from 0 (flat) to 1 (the full height).
var steps: Array[PackedFloat32Array] = []
var _heights := PackedFloat32Array()
var _step := -1
var _time := 0.0
var _hitboxes: Array[CollisionShape2D] = []

@onready var _thump: AudioStreamPlayer = $Sound


func _ready() -> void:
	_heights.resize(steps[0].size())
	for i in _heights.size():
		var rect := RectangleShape2D.new()
		var hitbox := CollisionShape2D.new()
		hitbox.shape = rect
		hitbox.disabled = true
		add_child(hitbox)
		_hitboxes.append(hitbox)


func _process(delta: float) -> void:
	_time += delta
	var step := floori(_time / step_time)
	if step > steps.size():
		queue_free()
		return
	if step != _step:
		_step = step
		if step > 0:
			_jump_to(steps[step - 1])
	queue_redraw()


func _draw() -> void:
	var column := width / _heights.size()
	for i in _heights.size():
		var left := -width / 2 + column * i + PixelArt.SIZE
		var bar_width := column - 2 * PixelArt.SIZE
		var height := _heights[i] * max_height
		# Lit segments, coloured by how high up the meter they are.
		var segment := (SEGMENT + GAP) * PixelArt.SIZE
		var top := 0.0
		while top + SEGMENT * PixelArt.SIZE <= height:
			var level := (top + segment / 2) / max_height
			var color := LOW if level < 0.45 else (MID if level < 0.7 else HIGH)
			PixelArt.fill(self, Rect2(left, -top - SEGMENT * PixelArt.SIZE, bar_width, SEGMENT * PixelArt.SIZE), color)
			top += segment
		# The next height, shown a step ahead.
		if _step < steps.size() and fmod(_time, 0.2) < 0.14:
			var next := -steps[_step][i] * max_height
			PixelArt.line(self, Vector2(left, next), Vector2(left + bar_width, next), PixelArt.WHITE, 1, 2)


func _jump_to(heights: PackedFloat32Array) -> void:
	var start := _heights.duplicate()
	create_tween().tween_method(func(t: float) -> void:
		for i in _heights.size():
			_heights[i] = lerpf(start[i], heights[i], t)
		_update_hitboxes(), 0.0, 1.0, JUMP_TIME)
	_thump.play()


func _update_hitboxes() -> void:
	var column := width / _heights.size()
	for i in _heights.size():
		var height := _heights[i] * max_height
		var hitbox := _hitboxes[i]
		(hitbox.shape as RectangleShape2D).size = Vector2(column - 2 * PixelArt.SIZE, maxf(height, 1))
		hitbox.position = Vector2(-width / 2 + column * (i + 0.5), -height / 2)
		hitbox.disabled = height < PixelArt.SIZE * 2
