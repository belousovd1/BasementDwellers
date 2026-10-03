class_name MikeStage
extends ArenaStage
## One of Mike's stages, with helpers that spawn his attacks in arena space.

const WireCubeScene := preload("res://Src/Actors/Mike/Attacks/WireCube.tscn")
const EdgeWallScene := preload("res://Src/Actors/Mike/Attacks/EdgeWall.tscn")
const LoopCutScene := preload("res://Src/Actors/Mike/Attacks/LoopCut.tscn")
const ExtrudeScene := preload("res://Src/Actors/Mike/Attacks/Extrude.tscn")
const RenderTileScene := preload("res://Src/Actors/Mike/Attacks/RenderTile.tscn")
## How far edge rows and loop cuts reach past the arena walls.
const OVERHANG := 30.0
const CUT_THICKNESS := 12.0


## A default cube flying from [param at] along [param direction].
func spawn_cube(at: Vector2, direction: Vector2, speed := 250.0) -> void:
	var cube := WireCubeScene.instantiate()
	cube.position = at
	cube.direction = direction
	cube.speed = speed
	arena.add_child(cube)


## A row of vertices spanning the arena that sweeps from [param at] along
## [param direction], with [param gap_size] edges missing from edge
## [param gap_index]. Edges count from the left, or from the top for a row
## sweeping sideways; the end edges reach past the walls, so leave gaps inside.
func spawn_edge_wall(at: Vector2, direction: Vector2, gap_index: int, gap_size := 1,
		speed := 200.0) -> void:
	var wall := EdgeWallScene.instantiate()
	var sideways := direction.x != 0
	wall.position = at
	wall.direction = direction
	wall.speed = speed
	wall.gap_index = gap_index
	wall.gap_size = gap_size
	wall.rotation = PI / 2 if sideways else 0.0
	wall.length = ((ARENA_HALF_SIZE.y if sideways else ARENA_HALF_SIZE.x) + OVERHANG) * 2
	wall.vertex_count = 7 if sideways else 9
	arena.add_child(wall)


## A loop cut across the arena: a level line [param offset] pixels below the
## middle, or with [param vertical], an upright line that far to the right.
func spawn_loop_cut(offset: float, vertical := false, warn_time := 0.8) -> void:
	var cut := LoopCutScene.instantiate()
	if vertical:
		cut.position = Vector2(offset, 0)
		cut.size = Vector2(CUT_THICKNESS, (ARENA_HALF_SIZE.y + OVERHANG) * 2)
	else:
		cut.position = Vector2(0, offset)
		cut.size = Vector2((ARENA_HALF_SIZE.x + OVERHANG) * 2, CUT_THICKNESS)
	cut.warn_time = warn_time
	arena.add_child(cut)


## [param count] loop cuts at once, evenly spaced, leaving lanes between them.
func spawn_loop_cuts(count: int, vertical := false, warn_time := 0.9) -> void:
	var half := ARENA_HALF_SIZE.x if vertical else ARENA_HALF_SIZE.y
	for i in count:
		spawn_loop_cut(lerpf(-half, half, (i + 1.0) / (count + 1)), vertical, warn_time)


## A face extruded out of the [param wall] side of the arena (such as
## [constant Vector2.LEFT]), [param along] pixels from the middle of that wall.
func spawn_extrude(wall: Vector2, along: float, width := 160.0, depth := 300.0) -> void:
	var extrude := ExtrudeScene.instantiate()
	var across := Vector2(wall.y, wall.x).abs()
	extrude.position = wall * ARENA_HALF_SIZE + across * along
	extrude.rotation = (-wall).angle() - PI / 2
	extrude.width = width
	extrude.depth = depth
	arena.add_child(extrude)


## Renders [param tile] of a grid of [param tiles] laid over the arena.
func spawn_render_tile(tile: Vector2i, tiles: Vector2i, warn_time := 0.7) -> void:
	var render := RenderTileScene.instantiate()
	var size := ARENA_HALF_SIZE * 2 / Vector2(tiles)
	render.size = size
	render.position = -ARENA_HALF_SIZE + size * (Vector2(tile) + Vector2(0.5, 0.5))
	render.warn_time = warn_time
	arena.add_child(render)
