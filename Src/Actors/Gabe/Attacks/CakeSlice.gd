extends Projectile
## A slice of ice cream cake shot out of a whole one: cookie crumb, vanilla,
## strawberry, fudge and whipped cream with a cherry on top. It flies in a
## straight line, wobbling, and frees itself once it is well off the screen.

## The slice, a row of pixels per string, centred on the projectile.
const SHAPE: Array[String] = [
	"     #    ",
	"   ##r#   ",
	" ##wwww## ",
	"#wwwwwwww#",
	"#ffffffff#",
	"#ppPppppp#",
	"#vvvvvvvv#",
	"#bbbbbbbb#",
	" ######## ",
]
## The colours of the cake: # outline, r cherry, w whipped cream, f fudge,
## p strawberry ice cream and P the berries in it, v vanilla ice cream and
## b the cookie crumb base.
const PALETTE := {
	"#": Color.WHITE, "r": Color("dc1e32"), "w": Color("faf8f0"), "f": Color("5a321e"),
	"p": Color("ff96b4"), "P": Color("c8285a"), "v": Color("fff0c8"), "b": Color("8c5f37"),
}
## How far off the screen it can go before it is freed.
const SCREEN_MARGIN := 200.0

@export var speed := 380.0

var direction := Vector2.RIGHT
var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	position += direction.normalized() * speed * delta
	queue_redraw()
	if not get_viewport_rect().grow(SCREEN_MARGIN).has_point(global_position):
		queue_free()


func _draw() -> void:
	var corner := -PixelArt.bitmap_size(SHAPE) / 2
	# A wobble as it flies, mirrored now and then, so it looks to tumble.
	corner.y += roundf(sin(_time * 18.0)) * PixelArt.SIZE / 2
	PixelArt.bitmap(self, SHAPE, corner, PALETTE, fmod(_time, 0.4) < 0.2)
