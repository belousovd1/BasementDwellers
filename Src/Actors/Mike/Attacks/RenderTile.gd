extends WarningZone
## One tile of a render. While it waits its turn, Blender's tile brackets mark
## its corners; then it fills with render noise, which hurts.

## Length of each bracket arm, in art pixels.
const BRACKET := 5
## Noise pixels scattered over the tile each frame while it renders.
const NOISE_DOTS := 70


func _draw() -> void:
	var rect := Rect2(-size / 2, size)
	if not is_active():
		var color := PixelArt.WHITE if fmod(_time, 0.3) < 0.15 else PixelArt.ORANGE
		_draw_brackets(rect.grow(-PixelArt.SIZE), color)
		return
	PixelArt.fill(self, rect, Color(0.8, 0.8, 0.82))
	for _dot in NOISE_DOTS:
		var at := rect.position + Vector2(randf() * size.x, randf() * size.y)
		PixelArt.dot(self, at, Color.from_hsv(0, 0, randf_range(0.2, 1.0)))
	PixelArt.outline(self, rect, PixelArt.WHITE)


func _draw_brackets(rect: Rect2, color: Color) -> void:
	var arm := BRACKET * PixelArt.SIZE
	for corner in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end,
			Vector2(rect.position.x, rect.end.y)]:
		# Each arm points from the corner towards the middle of the tile.
		var inward: Vector2 = (rect.get_center() - corner).sign()
		PixelArt.line(self, corner, corner + Vector2(inward.x * arm, 0), color)
		PixelArt.line(self, corner, corner + Vector2(0, inward.y * arm), color)
