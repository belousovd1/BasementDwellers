extends Projectile
## A gem on a rhythm game's note highway. Its lane lights up in its colour
## first, blinking, then it drops down the lane and frees itself off the
## screen.

const SHAPE: Array[String] = [
	"   ##########   ",
	"  #cccccccccc#  ",
	" #cccwwwwwwccc# ",
	"#cccwwwwwwwwccc#",
	" #cccwwwwwwccc# ",
	"  #cccccccccc#  ",
	"   ##########   ",
]
## The highway's lane colours, left to right.
const LANE_COLORS: Array[Color] = [
	Color("3cc83c"), Color("e83030"), Color("f7d13c"), Color("2f9bf0"), Color("f5872b"),
]
const SCREEN_MARGIN := 200.0

@export var speed := 750.0
@export var warn_time := 0.8
## How far down the lane lights up, in pixels.
@export var lane_length := 600.0
## Width of the lit lane, in pixels.
@export var lane_width := 100.0
@export var lane := 0

var _time := 0.0

@onready var _hitbox: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	_hitbox.disabled = true


func _process(delta: float) -> void:
	_time += delta
	if _time < warn_time:
		queue_redraw()
		return
	if _hitbox.disabled:
		_hitbox.disabled = false
		queue_redraw()
	position.y += speed * delta
	if not get_viewport_rect().grow(SCREEN_MARGIN).has_point(global_position):
		queue_free()


func _draw() -> void:
	var color := LANE_COLORS[lane % LANE_COLORS.size()]
	if _time < warn_time and fmod(_time, 0.2) < 0.1:
		var beam := Rect2(-lane_width / 2, 0, lane_width, lane_length)
		draw_rect(beam, Color(color, 0.16))
		PixelArt.line(self, beam.position, Vector2(beam.position.x, beam.end.y), color, 1, 3)
		PixelArt.line(self, Vector2(beam.end.x, beam.position.y), beam.end, color, 1, 3)
	if _time >= warn_time:
		PixelArt.bitmap(self, SHAPE, -PixelArt.bitmap_size(SHAPE) / 2,
				{"#": PixelArt.WHITE, "c": color, "w": PixelArt.WHITE})
