class_name Mitch
extends Node2D
## The boss. Owns his health, his animations and the active [BossStage].

## Emitted whenever the current stage finishes a round of attacks.
signal attacks_finished

const STAGES: Array[PackedScene] = [
	preload("res://Src/Actors/Mitch/Phases/Stage1.tscn"),
	preload("res://Src/Actors/Mitch/Phases/Stage2.tscn"),
	preload("res://Src/Actors/Mitch/Phases/Stage3.tscn"),
]
const MAX_HEALTH := 100

var health := MAX_HEALTH
var stage_index := -1
var stage: BossStage

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("idle")


## Replaces the current stage with stage [param index] (0-based) at full health.
func start_stage(index: int) -> void:
	if stage:
		stage.queue_free()
	stage_index = index
	health = MAX_HEALTH
	stage = STAGES[index].instantiate()
	stage.attacks_finished.connect(attacks_finished.emit)
	add_child(stage)
	if is_final_stage():
		animation_player.play("stage3_idle")


## Removes the stage, along with everything it spawned.
func end_stage() -> void:
	stage.queue_free()
	stage = null


func is_final_stage() -> bool:
	return stage_index == STAGES.size() - 1


func take_damage(amount: int) -> void:
	health -= amount


func is_defeated() -> bool:
	return health <= 0


func play_idle() -> void:
	animation_player.play("idle")


## Plays the hit animation and returns once it has finished.
func play_hit() -> void:
	animation_player.play("hit")
	await animation_player.animation_finished
