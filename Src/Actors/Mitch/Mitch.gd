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
## Seconds spent easing into an idle animation instead of snapping to it.
const IDLE_BLEND_TIME := 0.25

var health := MAX_HEALTH
var stage_index := -1
var stage: BossStage
var _idle_animation := "idle"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	for idle in ["idle", "stage3_idle"]:
		animation_player.set_blend_time("hit", idle, IDLE_BLEND_TIME)
	animation_player.set_blend_time("idle", "stage3_idle", IDLE_BLEND_TIME)
	play_idle()


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
		power_up()


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


## Switches Mitch to his final-stage look, which he keeps from then on.
func power_up() -> void:
	_idle_animation = "stage3_idle"
	play_idle()


func play_idle() -> void:
	animation_player.play(_idle_animation)


## Plays the hit animation and returns once it has finished.
func play_hit() -> void:
	animation_player.play("hit")
	await animation_player.animation_finished
