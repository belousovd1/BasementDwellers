extends Projectile
## A music note flying along [member direction], weaving from side to side like
## a melody: a single eighth note or, with [member beamed], a beamed pair. Its
## position is the (left) note head. It frees itself once it is well off the
## screen.

const EIGHTH: Array[String] = [
	"   ##   ",
	"   ###  ",
	"   # ## ",
	"   #  ##",
	"   #   #",
	"   #    ",
	"   #    ",
	"   #    ",
	" ####   ",
	"#####   ",
	"#####   ",
	" ###    ",
]
const BEAMED: Array[String] = [
	"   #########",
	"   #########",
	"   #      # ",
	"   #      # ",
	"   #      # ",
	"   #      # ",
	"   #      # ",
	" ####   ####",
	"#####  #####",
	"#####  #####",
	" ###    ### ",
]
## Where the note head is in the pictures, in art pixels, and where a beamed
## pair's second head is from the first.
const HEAD := Vector2(2.5, 9.5)
const SECOND_HEAD := Vector2(6, 0)
## How far off the screen it can go before it is freed.
const SCREEN_MARGIN := 200.0

@export var speed := 260.0
## How far it weaves to either side of its path, in pixels, and how fast.
@export var wobble := 0.0
@export var wobble_speed := 6.0
@export var beamed := false
@export var color := Color.WHITE

var direction := Vector2.LEFT
var _path_point := Vector2.ZERO
var _time := 0.0


func _ready() -> void:
	_path_point = position
	if beamed:
		var second := CollisionShape2D.new()
		second.shape = $CollisionShape2D.shape
		second.position = SECOND_HEAD * PixelArt.SIZE
		add_child(second)


func _process(delta: float) -> void:
	_time += delta
	_path_point += direction.normalized() * speed * delta
	var side := Vector2(-direction.y, direction.x).normalized()
	position = _path_point + side * sin(_time * wobble_speed) * wobble
	if not get_viewport_rect().grow(SCREEN_MARGIN).has_point(global_position):
		queue_free()


func _draw() -> void:
	PixelArt.bitmap(self, BEAMED if beamed else EIGHTH, -HEAD * PixelArt.SIZE, {"#": color})
