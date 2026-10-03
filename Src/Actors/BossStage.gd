class_name BossStage
extends Node2D
## One phase of a boss fight.
##
## A stage plays a scripted round of attacks and then emits
## [signal attacks_finished] so the player can take their turn. Main calls
## [method resume] afterwards to start the next round.
##
## Projectiles are spawned as children of the stage, which is a child of the
## boss, so their positions are in the boss's coordinate space.

signal attacks_finished


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


## Called after the player's attack, before [method resume], if the boss survived.
func on_player_turn_ended(_boss_health: int) -> void:
	pass


## Waits [param seconds]. The timer is a child of the stage, so if the stage is
## freed mid-round the waiting attack sequence is simply dropped.
##
## With [param before_update], the timer ticks in the physics step, so the wait
## ends before nodes update that frame and anything spawned next moves and spins
## in that same frame. The row volleys were tuned to that timing: without it
## their spinning paintbrushes cross the arena a frame behind, visibly tilted.
func wait(seconds: float, before_update := false) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = seconds
	if before_update:
		timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	add_child(timer)
	timer.start()
	await timer.timeout
	timer.queue_free()
