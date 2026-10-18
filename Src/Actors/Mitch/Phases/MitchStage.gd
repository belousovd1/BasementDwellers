class_name MitchStage
extends BossStage
## One of Mitch's stages, with helpers that spawn his attacks.

const BoomerangScene := preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBullet.tscn")
const BoomerangRowScene := preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBulletRow.tscn")
const BoomerangSweepScene := preload("res://Src/Actors/Mitch/PaintBrushBullets/PaintBrushBoomerangAttack.tscn")
const KidneyStoneScene := preload("res://Src/Actors/Mitch/Attacks/KidneyStone.tscn")


func spawn_boomerang(at: Vector2, direction: Vector2, speed := 300.0, size := Vector2.ONE) -> void:
	var boomerang := BoomerangScene.instantiate()
	boomerang.position = at
	boomerang.direction = direction
	boomerang.speed = speed
	boomerang.scale = size
	add_child(boomerang)


func spawn_boomerang_row(gap_index: int, at := Vector2.ZERO, direction := Vector2.DOWN,
		angle_degrees := 0.0, speed := 200.0) -> void:
	var row := BoomerangRowScene.instantiate()
	row.position = at
	row.rotation_degrees = angle_degrees
	row.direction = direction
	row.gap_index = gap_index
	row.speed = speed
	add_child(row)


## Two paintbrushes swinging out and back from Mitch's hands.
func spawn_boomerang_sweep() -> void:
	add_child(BoomerangSweepScene.instantiate())


## One of Mitch's kidney stones, dropped onto [param at] in arena space (the
## middle of the arena is the origin). It lands [param warn_time] seconds after
## its shadow appears, and with [param shatter] bursts into shards.
func spawn_kidney_stone(at: Vector2, shatter := false, warn_time := 1.0) -> void:
	var stone := KidneyStoneScene.instantiate()
	# On the screen rather than in Mitch's scaled-up space, so its pixels match.
	stone.top_level = true
	stone.position = ArenaStage.ARENA_CENTER + at
	stone.shatter = shatter
	stone.warn_time = warn_time
	add_child(stone)


## Where the player is, in arena space.
func player_position() -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	return player.global_position - ArenaStage.ARENA_CENTER


## Has Mitch say [param line], cutting off whatever he was saying.
func call_out(line: String) -> void:
	(get_parent() as Boss).say(line, true)
