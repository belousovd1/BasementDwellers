extends WarningZone
## Blender's loop cut: a dashed yellow preview line, then the cut itself, a
## thick line that hurts. The line runs along the zone's longer side.


func _draw() -> void:
	var half := size / 2
	var from := Vector2(-half.x, 0) if size.x >= size.y else Vector2(0, -half.y)
	if not is_active():
		# The preview blinks faster as the cut nears.
		var blink := lerpf(0.25, 0.08, phase_progress())
		if fmod(_time, blink * 2) < blink:
			PixelArt.line(self, from, -from, PixelArt.YELLOW, 1, 3)
		return
	var thickness := roundi(minf(size.x, size.y) / PixelArt.SIZE)
	var color := PixelArt.WHITE if phase_progress() < 0.3 else PixelArt.YELLOW
	PixelArt.line(self, from, -from, color, thickness)
