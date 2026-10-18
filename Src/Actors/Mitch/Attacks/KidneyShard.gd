extends Projectile
## A shard of a shattered kidney stone, flying out from where it landed,
## slowing down and fading out. Top-level, positioned on the screen.

const STONE := PixelArt.GREY
const GLINT := Color(0.72, 0.72, 0.74)
const LIFE := 0.6
## How quickly it slows down, as a fraction of its speed per second.
const DRAG := 2.5

var velocity := Vector2.ZERO
var _age := 0.0


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFE:
		queue_free()
		return
	position += velocity * delta
	velocity *= maxf(1.0 - DRAG * delta, 0.0)
	modulate.a = 1.0 - pow(_age / LIFE, 2)
	queue_redraw()


func _draw() -> void:
	PixelArt.dot(self, Vector2.ZERO, PixelArt.WHITE, 3)
	PixelArt.dot(self, Vector2.ZERO, STONE, 2)
	PixelArt.dot(self, Vector2.ZERO, GLINT)
