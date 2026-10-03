class_name Boss
extends Node2D
## A boss for Main to fight. Owns its health, its animations, its banter and
## the active [BossStage]; Main takes it through its stages one after another.
##
## A boss scene needs an AnimationPlayer with "idle" and "hit" animations, and
## an AudioStreamPlayer named DeathSound.

## Emitted whenever the current stage finishes a round of attacks.
signal attacks_finished

const MAX_HEALTH := 100
const SpeechBubbleScene := preload("res://Src/Interface/SpeechBubble.tscn")
const DeathEffectScene := preload("res://Assets/Shaders/BodySprites.tscn")
const DEATH_SECONDS := 4.0

## The stages, in the order they are fought.
@export var stages: Array[PackedScene] = []
## Dialogue played when each stage is beaten, one per stage.
@export_file("*.json") var stage_end_dialogues: Array[String] = []
## Music for each stage. A stage without any keeps the previous music playing.
@export var stage_music: Array[AudioStream] = []
## Scene shown once the boss is dead.
@export_file("*.tscn") var next_scene := "res://Src/Interface/Menus/ToBeContinued.tscn"

@export_group("Placement")
## Where the boss is, and how big, while it attacks.
@export var fight_position := Vector2(960, 336)
@export var fight_scale := Vector2.ONE
## Where the boss is, and how big, while it talks between stages.
@export var dialogue_position := Vector2(960, 540)
@export var dialogue_scale := Vector2.ONE

@export_group("Banter")
## Lines said mid-fight.
@export var banter: Array[String] = []
## Seconds between lines, picked at random in this range.
@export var banter_interval := Vector2(5.0, 9.0)
## Node the speech bubble's tail points at, and the offset from it in that
## node's own space.
@export var mouth: Node2D
@export var mouth_offset := Vector2.ZERO

@export_group("Death")
## Image the boss shatters into. Leave empty to keep the effect's own image,
## which is Mitch's sprite sheet.
@export var death_texture: Texture2D
## Centre and scale of the shattering image, in the boss's own space.
@export var death_offset := Vector2.ZERO
@export var death_scale := Vector2.ONE

var health := MAX_HEALTH
var stage_index := -1
var stage: BossStage
var idle_animation := "idle"
var _bubble: SpeechBubble
var _banter_timer := Timer.new()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var _death_sound: AudioStreamPlayer = $DeathSound


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
	stage = stages[index].instantiate()
	stage.attacks_finished.connect(attacks_finished.emit)
	add_child(stage)
	if is_final_stage():
		power_up()


## Removes the stage, along with everything it spawned.
func end_stage() -> void:
	stage.queue_free()
	stage = null


func is_final_stage() -> bool:
	return stage_index == stages.size() - 1


## The music stage [param index] starts, or null if it keeps the music playing.
func music_for_stage(index: int) -> AudioStream:
	return stage_music[index] if index < stage_music.size() else null


func take_damage(amount: int) -> void:
	health -= amount


func is_defeated() -> bool:
	return health <= 0


## Called when the current stage is beaten, before its dialogue. Beating the
## second-to-last stage powers the boss up, so it talks in its final look;
## beating the last one removes it.
func on_stage_beaten() -> void:
	if stage_index == stages.size() - 2:
		power_up()
	elif is_final_stage():
		end_stage()


## Switches the boss to its final-stage look, which it keeps from then on.
func power_up() -> void:
	pass


func play_idle() -> void:
	animation_player.play(idle_animation)


## Plays the hit animation and returns once it has finished.
func play_hit() -> void:
	animation_player.play("hit")
	await animation_player.animation_finished


## Plays the last hit, shatters the boss into pixels, and returns once the
## pixels have fallen away.
func die() -> void:
	await play_hit()
	var effect: GPUParticles2D = DeathEffectScene.instantiate()
	if death_texture:
		var pixels := effect.process_material.duplicate() as ShaderMaterial
		var half_size := death_texture.get_size() / 2
		pixels.set_shader_parameter("sprite", death_texture)
		pixels.set_shader_parameter("emission_box_extents", Vector3(half_size.x, half_size.y, 1))
		effect.process_material = pixels
	effect.position = to_global(death_offset)
	effect.scale = scale * death_scale
	hide()
	get_parent().add_child(effect)
	effect.emitting = true
	_death_sound.play()
	await get_tree().create_timer(DEATH_SECONDS).timeout


## Starts saying a line from [member banter] every so often.
func start_talking() -> void:
	_schedule_banter()


## Stops the banter and closes any open speech bubble.
func stop_talking() -> void:
	_banter_timer.stop()
	if is_instance_valid(_bubble):
		_bubble.queue_free()


## Shows [param line] in a speech bubble at the boss's mouth, unless one is up.
## With [param interrupt], it replaces the line that is up instead.
func say(line: String, interrupt := false) -> void:
	if is_instance_valid(_bubble):
		if not interrupt:
			return
		_bubble.queue_free()
	_bubble = SpeechBubbleScene.instantiate()
	_bubble.speaker = mouth
	_bubble.speaker_offset = mouth_offset
	_bubble.finished.connect(_schedule_banter)
	add_child(_bubble)
	_bubble.say(line)


func _schedule_banter() -> void:
	_banter_timer.start(randf_range(banter_interval.x, banter_interval.y))


func _on_banter_timer_timeout() -> void:
	if not banter.is_empty():
		say(banter.pick_random())
