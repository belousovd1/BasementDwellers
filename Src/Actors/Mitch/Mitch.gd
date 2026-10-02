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
const SpeechBubbleScene := preload("res://Src/Interface/SpeechBubble.tscn")
## Where the speech bubble's tail points, in the head sprite's own space.
const MOUTH_OFFSET := Vector2(14, -4)

## Lines Mitch says mid-fight (placeholders for now).
@export var banter: Array[String] = [
	"Is that all you got?",
	"Too slow, kid!",
	"You call that dodging?",
	"Taste the sauce!",
	"My paintbrushes never miss. Mostly.",
]
## Seconds between lines, picked at random in this range.
@export var banter_interval := Vector2(5.0, 9.0)

var health := MAX_HEALTH
var stage_index := -1
var stage: BossStage
var _idle_animation := "idle"
var _bubble: SpeechBubble
var _banter_timer := Timer.new()

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_banter_timer.one_shot = true
	_banter_timer.timeout.connect(_on_banter_timer_timeout)
	add_child(_banter_timer)
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


## Starts saying a line from [member banter] every so often.
func start_talking() -> void:
	_schedule_banter()


## Stops the banter and closes any open speech bubble.
func stop_talking() -> void:
	_banter_timer.stop()
	if is_instance_valid(_bubble):
		_bubble.queue_free()


## Shows [param line] in a speech bubble at Mitch's mouth, unless one is up.
func say(line: String) -> void:
	if is_instance_valid(_bubble):
		return
	_bubble = SpeechBubbleScene.instantiate()
	_bubble.speaker = $Parts/Hip/Torso/Head
	_bubble.speaker_offset = MOUTH_OFFSET
	_bubble.finished.connect(_schedule_banter)
	add_child(_bubble)
	_bubble.say(line)


func _schedule_banter() -> void:
	_banter_timer.start(randf_range(banter_interval.x, banter_interval.y))


func _on_banter_timer_timeout() -> void:
	if not banter.is_empty():
		say(banter.pick_random())


## Plays the hit animation and returns once it has finished.
func play_hit() -> void:
	animation_player.play("hit")
	await animation_player.animation_finished
