class_name BossStage
extends Node2D
## One phase of Mitch's fight.
##
## A stage plays a scripted round of attacks and then emits
## [signal attacks_finished] so the player can take their turn. Main calls
## [method resume] afterwards to start the next round.
##
## Projectiles are spawned as children of the stage, which is a child of Mitch,
## so their positions are in Mitch's coordinate space.

signal attacks_finished

const BoomerangScene := preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBullet.tscn")
const BoomerangRowScene := preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBulletRow.tscn")
const BoomerangSweepScene := preload("res://Src/Actors/Mitch/PaintBrushBullets/PaintBrushBoomerangAttack.tscn")
const LegAttackScene := preload("res://Src/Actors/Mitch/Mitch_LegAttacks.tscn")


func _ready() -> void:
	start()


## The stage's opening. By default it is just the first round of attacks.
func start() -> void:
	resume()


## Plays one round of attacks, ending with [signal attacks_finished].
func resume() -> void:
	pass


## Called when the player's attack bar appears.
func on_player_turn_started() -> void:
	pass


## Called after the player's attack, before [method resume], if Mitch survived.
func on_player_turn_ended(_boss_health: int) -> void:
	pass


## Waits [param seconds]. The timer is a child of the stage, so if the stage is
## freed mid-round the waiting attack sequence is simply dropped.
func wait(seconds: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = seconds
	add_child(timer)
	timer.start()
	await timer.timeout
	timer.queue_free()


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
