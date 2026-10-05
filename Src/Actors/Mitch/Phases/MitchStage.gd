class_name MitchStage
extends BossStage
## One of Mitch's stages, with helpers that spawn his attacks.

const BoomerangScene := preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBullet.tscn")
const BoomerangRowScene := preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBulletRow.tscn")
const BoomerangSweepScene := preload("res://Src/Actors/Mitch/PaintBrushBullets/PaintBrushBoomerangAttack.tscn")
const LegAttackScene := preload("res://Src/Actors/Mitch/Mitch_LegAttacks.tscn")


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


func spawn_leg_attack(advanced := false) -> Node2D:
	var legs := LegAttackScene.instantiate()
	legs.position.y = 264
	legs.advanced = advanced
	add_child(legs)
	return legs
