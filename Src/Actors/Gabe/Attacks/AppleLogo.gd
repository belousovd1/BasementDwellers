extends Projectile
## An Apple logo flying in a straight line, in white or, with [member rainbow],
## in the old six-stripe rainbow. It frees itself once it is well off the
## screen.

## The logo, a row of pixels per string, centred on the projectile.
const SHAPE: Array[String] = [
	"       ##   ",
	"      ##    ",
	"      #     ",
	"  ###  ###  ",
	" ########## ",
	"##########  ",
	"#########   ",
	"#########   ",
	"#########   ",
	"##########  ",
	"############",
	" ########## ",
	"  ########  ",
	"   ##  ##   ",
]
## The rainbow logo's stripes, top to bottom, and the rows of [constant SHAPE]
## each one covers. The green one takes in the leaf.
const STRIPES: Array[Color] = [
	Color("61bb46"), Color("fdb827"), Color("f5821f"), Color("e03a3e"), Color("963d97"), Color("009ddc"),
]
const STRIPE_ROWS: Array[int] = [5, 2, 2, 2, 2, 1]
## How far off the screen it can go before it is freed.
const SCREEN_MARGIN := 200.0

@export var speed := 260.0
@export var rainbow := false

var direction := Vector2.DOWN


func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	if not get_viewport_rect().grow(SCREEN_MARGIN).has_point(global_position):
		queue_free()


func _draw() -> void:
	var corner := -PixelArt.bitmap_size(SHAPE) / 2
	if not rainbow:
		PixelArt.bitmap(self, SHAPE, corner, {"#": PixelArt.WHITE})
		return
	var row := 0
	for stripe in STRIPES.size():
		var rows := SHAPE.slice(row, row + STRIPE_ROWS[stripe])
		PixelArt.bitmap(self, rows, corner + Vector2(0, row * PixelArt.SIZE), {"#": STRIPES[stripe]})
		row += STRIPE_ROWS[stripe]
