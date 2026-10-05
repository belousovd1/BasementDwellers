extends Projectile
## A car speeding across the arena along a lane. First its headlights light up
## the lane, blinking, while it beeps; then it drives through and frees itself
## once it is well off the screen.

## The car facing right, a row of pixels per string: # outline, r paint,
## w windows, k tyres, h headlight and t tail light.
const SHAPE: Array[String] = [
	"         ########            ",
	"       ##wwww#wwww##         ",
	"     ##wwwww#wwwwwww###      ",
	"  ####################### ## ",
	" #rrrrrrrrrrrrrrrrrrrrrrrrrh#",
	"#trrrrrrrrrrrrrrrrrrrrrrrrrr#",
	"#rrrr####rrrrrrrrrrr####rrrr#",
	" ###.#kk#.###########.#kk#.##",
	"    #kkkk#           #kkkk#  ",
	"     ####             ####   ",
]
const WINDOWS := Color("6e788c")
const HEADLIGHT := Color("fff096")
const TAIL_LIGHT := Color("ff3c3c")
const BEAM := Color(1.0, 0.95, 0.55, 0.16)
## How far off the screen it can go before it is freed.
const SCREEN_MARGIN := 300.0

@export var speed := 900.0
@export var warn_time := 0.9
## How far ahead the headlights light up the lane, in pixels.
@export var lane_length := 1000.0
## 1 to drive right, -1 to drive left.
@export var heading := 1
@export var paint := Color("e83030")

var _time := 0.0

@onready var _hitbox: CollisionShape2D = $CollisionShape2D
@onready var _beep: AudioStreamPlayer = $Sound


func _ready() -> void:
	(_hitbox.shape as RectangleShape2D).size = PixelArt.bitmap_size(SHAPE) - Vector2(12, 12)
	_hitbox.disabled = true
	_beep.play()


func _process(delta: float) -> void:
	_time += delta
	if _time < warn_time:
		queue_redraw()
		return
	if _hitbox.disabled:
		_hitbox.disabled = false
		queue_redraw()
	position.x += heading * speed * delta
	if not get_viewport_rect().grow(SCREEN_MARGIN).has_point(global_position):
		queue_free()


func _draw() -> void:
	var size := PixelArt.bitmap_size(SHAPE)
	if _time < warn_time and fmod(_time, 0.2) < 0.1:
		# The headlights' beam down the lane ahead.
		var start_x := size.x / 2 if heading > 0 else -size.x / 2 - lane_length
		var beam := Rect2(start_x, -size.y / 2 + PixelArt.SIZE, lane_length, size.y - 2 * PixelArt.SIZE)
		draw_rect(beam, BEAM)
		PixelArt.line(self, beam.position, Vector2(beam.end.x, beam.position.y), PixelArt.YELLOW, 1, 3)
		PixelArt.line(self, Vector2(beam.position.x, beam.end.y), beam.end, PixelArt.YELLOW, 1, 3)
	var palette := {"#": PixelArt.WHITE, "r": paint, "w": WINDOWS, "k": PixelArt.BLACK, ".": PixelArt.BLACK,
			"h": HEADLIGHT, "t": TAIL_LIGHT}
	PixelArt.bitmap(self, SHAPE, -size / 2, palette, heading < 0)
