class_name Main
extends Node
## A boss fight. Alternates the boss's attack rounds with the player's attack
## bar, plays the dialogue between stages, and handles winning and losing.
##
## Main.tscn fights Mitch; MikeFight.tscn inherits it and sets [member boss_scene]
## to Mike. The boss supplies its own stages, dialogue and music.

const AttackBarScene := preload("res://Src/Interface/AttackBar.tscn")
const DialogueBoxScene := preload("res://Src/Interface/DialogueBox.tscn")
const ATTACK_BAR_POSITION := Vector2(960, 800)
## Fight music made of layers played in sync (an [AudioStreamSynchronized])
## starts on its first layer and evolves into its last as the fight starts:
## after EVOLVE_DELAY seconds it crossfades over EVOLVE_SECONDS.
const EVOLVE_DELAY := 1.0
const EVOLVE_SECONDS := 4.0
## Quieter than this counts as silent.
const SILENT_DB := -80.0

## Music that was already playing when the fight scene was entered, and how far
## into it, so the fight can carry on with it. See [method carry_music].
static var _carried_music: AudioStream
static var _carried_position := 0.0

## The [Boss] to fight. It is added behind the arena when the fight starts.
@export var boss_scene: PackedScene

# The instantiated boss scene is a runtime object; its concrete type is provided by
# the scene that owns this script, so avoid a hard type reference here to prevent
# editor errors when the Boss class is not resolvable in this scope.
var boss

@onready var background: ColorRect = $ColorRect
@onready var player: CharacterBody2D = $Player
@onready var hud: Control = $Interface
@onready var camera: Camera2D = $OnHitCamera
@onready var music: AudioStreamPlayer = $Music
@onready var curtain: AnimationPlayer = $CurtainColorRect/AnimationPlayer


func _ready() -> void:
	DeathMenu.fight_scene = scene_file_path
	boss = boss_scene.instantiate()
	boss.position = boss.fight_position
	boss.scale = boss.fight_scale
	boss.add_to_group("environment")
	background.add_sibling(boss)

	hud.set_max_health(player.max_health)
	curtain.play("fade_in")
	boss.attacks_finished.connect(_player_turn)
	_play_music(boss.music_for_stage(0))
	boss.start_stage(0)
	boss.start_talking()


func _player_turn() -> void:
	boss.stop_talking()
	get_tree().call_group("defense", "hide")
	boss.stage.on_player_turn_started()

	var attack_bar := AttackBarScene.instantiate()
	attack_bar.position = ATTACK_BAR_POSITION
	attack_bar.fast = boss.is_final_stage()
	add_child(attack_bar)
	var damage: int = await attack_bar.struck
	await boss.play_hit()
	attack_bar.queue_free()

	boss.take_damage(damage)
	if boss.is_defeated():
		_end_stage()
		return
	boss.stage.on_player_turn_ended(boss.health)
	get_tree().call_group("defense", "show")
	boss.stage.resume()
	boss.play_idle()
	boss.start_talking()


## The boss has been beaten for this stage: it talks, then the next stage
## starts or it dies.
func _end_stage() -> void:
	get_tree().call_group("defense", "hide")
	boss.play_idle()
	boss.scale = boss.dialogue_scale
	boss.position = boss.dialogue_position
	boss.on_stage_beaten()
	if boss.is_final_stage() or boss.music_for_stage(boss.stage_index + 1):
		music.stop()

	var dialogue: DialogueBox = DialogueBoxScene.instantiate()
	dialogue.dialogue_path = boss.stage_end_dialogues[boss.stage_index]
	add_child(dialogue)
	await dialogue.finished

	if boss.is_final_stage():
		_boss_dies()
	else:
		_next_stage()


func _next_stage() -> void:
	curtain.play("fade_out")
	await curtain.animation_finished
	curtain.play("fade_in")
	boss.scale = boss.fight_scale
	boss.position = boss.fight_position
	get_tree().call_group("defense", "show")
	await get_tree().create_timer(2).timeout
	boss.start_stage(boss.stage_index + 1)
	boss.start_talking()
	var stage_music: AudioStream = boss.music_for_stage(boss.stage_index)
	if stage_music:
		_play_music(stage_music)


func _boss_dies() -> void:
	await boss.die()
	get_tree().change_scene_to_file(boss.next_scene)


## Has the next fight's first music carry on from [param position] in
## [param stream], if that is the music it starts with.
static func carry_music(stream: AudioStream, position: float) -> void:
	_carried_music = stream
	_carried_position = position


func _play_music(stream: AudioStream) -> void:
	var carried := stream == _carried_music
	var layered := stream as AudioStreamSynchronized
	if layered:
		# Music that was carried in may be this one's first layer. Work on a
		# copy, so evolving it doesn't change the shared resource.
		carried = carried or layered.get_sync_stream(0) == _carried_music
		layered = layered.duplicate()
		stream = layered
	music.stop()
	music.stream = stream
	music.play(_carried_position if carried else 0.0)
	_carried_music = null
	if layered:
		_evolve_music(layered)


## Crossfades [param layered] from its first layer into its last.
func _evolve_music(layered: AudioStreamSynchronized) -> void:
	var last := layered.stream_count - 1
	for i in layered.stream_count:
		layered.set_sync_stream_volume(i, 0.0 if i == 0 else SILENT_DB)
	var fade := func(t: float) -> void:
		# Equal power, so the music doesn't dip in the middle.
		layered.set_sync_stream_volume(0, maxf(linear_to_db(cos(t * PI / 2)), SILENT_DB))
		layered.set_sync_stream_volume(last, maxf(linear_to_db(sin(t * PI / 2)), SILENT_DB))
	create_tween().tween_method(fade, 0.0, 1.0, EVOLVE_SECONDS).set_delay(EVOLVE_DELAY)


func _on_player_hit(health: int) -> void:
	camera.shake()
	hud.show_health(health)


func _on_player_died() -> void:
	music.stop()
	get_tree().call_group("environment", "queue_free")


func _on_player_death_animation_finished() -> void:
	get_tree().change_scene_to_file("res://Src/Interface/Menus/DeathMenu.tscn")
