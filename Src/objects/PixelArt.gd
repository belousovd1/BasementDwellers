class_name PixelArt
## Draws Mike's attacks out of chunky square pixels, so they match his sprite.
## Each function draws onto [param canvas] in its own coordinates, snapped to a
## grid of [constant SIZE]-pixel squares.

## Size of one art pixel on screen. Mike's sprite is drawn at this scale.
const SIZE := 4.0

const WHITE := Color.WHITE
const GREY := Color(0.42, 0.42, 0.48)
const BLACK := Color.BLACK
## Blender's colours: selected vertices and edges, and the loop cut preview.
const ORANGE := Color("ffa000")
const YELLOW := Color("ffff50")


## A line of pixels [param width] pixels thick. With [param dash], it is drawn
## as dashes [param dash] pixels long with gaps as long between them.
static func line(canvas: CanvasItem, from: Vector2, to: Vector2, color: Color,
		width := 1, dash := 0) -> void:
	var start := (from / SIZE).floor()
	var end := (to / SIZE).floor()
	var steps := int(maxf(absf(end.x - start.x), absf(end.y - start.y)))
	for i in steps + 1:
		@warning_ignore("integer_division")
		if dash > 0 and (i / dash) % 2 == 1:
			continue
		var cell := start.lerp(end, float(i) / maxi(steps, 1)).round()
		_square(canvas, cell, color, width)


## A square [param width] pixels across, on the pixel [param at] falls in.
static func dot(canvas: CanvasItem, at: Vector2, color: Color, width := 1) -> void:
	_square(canvas, (at / SIZE).floor(), color, width)


## A filled rectangle, snapped outwards to whole pixels.
static func fill(canvas: CanvasItem, rect: Rect2, color: Color) -> void:
	var start := (rect.position / SIZE).floor() * SIZE
	var end := (rect.end / SIZE).ceil() * SIZE
	canvas.draw_rect(Rect2(start, end - start), color)


## The outline of a rectangle, one pixel thick, just inside its edges.
static func outline(canvas: CanvasItem, rect: Rect2, color: Color) -> void:
	var inset := Vector2.ONE * SIZE / 2
	var a := rect.position + inset
	var b := rect.end - inset
	line(canvas, a, Vector2(b.x, a.y), color)
	line(canvas, Vector2(b.x, a.y), b, color)
	line(canvas, b, Vector2(a.x, b.y), color)
	line(canvas, Vector2(a.x, b.y), a, color)


## A picture drawn from strings, one per row of pixels. Each character is looked
## up in [param palette] for its colour; characters missing from it, such as
## spaces, are left clear. [param at] is the top-left corner. With
## [param flip], the picture is mirrored left to right.
static func bitmap(canvas: CanvasItem, rows: Array[String], at: Vector2, palette: Dictionary,
		flip := false) -> void:
	var width := 0
	for row in rows:
		width = maxi(width, row.length())
	for y in rows.size():
		var row := rows[y]
		for x in row.length():
			if palette.has(row[x]):
				var column := width - 1 - x if flip else x
				canvas.draw_rect(Rect2(at + Vector2(column, y) * SIZE, Vector2.ONE * SIZE), palette[row[x]])


## The size of a picture drawn by [method bitmap], in screen pixels.
static func bitmap_size(rows: Array[String]) -> Vector2:
	var width := 0
	for row in rows:
		width = maxi(width, row.length())
	return Vector2(width, rows.size()) * SIZE


## Pixel [param cell] covers [code]cell * SIZE[/code] to [code](cell + 1) * SIZE[/code].
## A wider square grows around it, and to the right and down when [param width]
## is even.
static func _square(canvas: CanvasItem, cell: Vector2, color: Color, width: int) -> void:
	var corner := cell - Vector2.ONE * floorf((width - 1) / 2.0)
	canvas.draw_rect(Rect2(corner * SIZE, Vector2.ONE * width * SIZE), color)
