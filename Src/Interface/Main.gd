extends Node
## The boss fight. Alternates Mitch's attack rounds with the player's attack
## bar, plays the dialogue between stages, and handles winning and losing.

const AttackBarScene := preload("res://Src/Interface/AttackBar.tscn")
const DialogueBoxScene := preload("res://Src/Interface/DialogueBox.tscn")
const DeathEffectScene := preload("res://Assets/Shaders/BodySprites.tscn")

## Dialogue played when each stage is beaten.
const STAGE_END_DIALOGUES: Array[String] = [
	"res://Src/CutScenes/dialogues/Mitch/IntoStage2Convo.json",
	"res://Src/CutScenes/dialogues/Mitch/IntoStage3Convo.json",
	"res://Src/CutScenes/dialogues/Mitch/MitchDeathConvo.json",
]
const FINAL_STAGE_MUSIC := "res://Assets/Sound/OST/Stage3Mitch.ogg"
const MITCH_DEATH_SOUND := "res://Assets/Sound/SFX/426318__mtjohnson__rocks-falling.wav"

# Mitch is drawn larger and lower while he talks between stages.
const FIGHT_POSITION := Vector2(960, 336)
const FIGHT_SCALE := Vector2(1.8, 1.8)
const DIALOGUE_POSITION := Vector2(950, 535)
const DIALOGUE_SCALE := Vector2(3, 3)
const ATTACK_BAR_POSITION := Vector2(960, 800)

@onready var mitch: Mitch = $Mitch
@onready var player: CharacterBody2D = $Player
@onready var hud: Control = $Interface
@onready var camera: Camera2D = $OnHitCamera
@onready var music: AudioStreamPlayer = $Music
@onready var curtain: AnimationPlayer = $CurtainColorRect/AnimationPlayer


func _ready() -> void:
	hud.set_max_health(player.max_health)
	curtain.play("fade_in")
	mitch.attacks_finished.connect(_player_turn)
	mitch.start_stage(0)


func _player_turn() -> void:
	get_tree().call_group("defense", "hide")
	mitch.stage.on_player_turn_started()

	var attack_bar := AttackBarScene.instantiate()
	attack_bar.position = ATTACK_BAR_POSITION
	attack_bar.fast = mitch.is_final_stage()
	add_child(attack_bar)
	var damage: int = await attack_bar.struck
	await mitch.play_hit()
	attack_bar.queue_free()

	mitch.take_damage(damage)
	if mitch.is_defeated():
		_end_stage()
		return
	mitch.stage.on_player_turn_ended(mitch.health)
	get_tree().call_group("defense", "show")
	mitch.stage.resume()
	mitch.play_idle()


## Mitch has been beaten for this stage: he talks, then the next stage starts
## or he dies.
func _end_stage() -> void:
	get_tree().call_group("defense", "hide")
	mitch.play_idle()
	mitch.scale = DIALOGUE_SCALE
	mitch.position = DIALOGUE_POSITION
	if mitch.stage_index == 1:
		music.stop()
		mitch.animation_player.play("stage3_idle")
	elif mitch.is_final_stage():
		mitch.end_stage()
		music.stop()

	var dialogue: DialogueBox = DialogueBoxScene.instantiate()
	dialogue.dialogue_path = STAGE_END_DIALOGUES[mitch.stage_index]
	add_child(dialogue)
	await dialogue.finished

	if mitch.is_final_stage():
		_mitch_dies()
	else:
		_next_stage()


func _next_stage() -> void:
	curtain.play("fade_out")
	await curtain.animation_finished
	curtain.play("fade_in")
	mitch.scale = FIGHT_SCALE
	mitch.position = FIGHT_POSITION
	get_tree().call_group("defense", "show")
	await get_tree().create_timer(2).timeout
	mitch.start_stage(mitch.stage_index + 1)
	if mitch.is_final_stage():
		_play_music(load(FINAL_STAGE_MUSIC))


func _mitch_dies() -> void:
	await mitch.play_hit()
	var effect := DeathEffectScene.instantiate()
	effect.scale = Vector2(3.5, 3.3)
	effect.position = Vector2(984, 440)
	mitch.hide()
	add_child(effect)
	effect.emitting = true
	_play_music(load(MITCH_DEATH_SOUND))
	await get_tree().create_timer(4).timeout
	get_tree().change_scene_to_file("res://Src/Interface/Menus/ToBeContinued.tscn")


func _play_music(stream: AudioStream) -> void:
	music.stop()
	music.stream = stream
	music.play()


func _on_player_hit(health: int) -> void:
	camera.shake()
	hud.show_health(health)


func _on_player_died() -> void:
	music.stop()
	get_tree().call_group("environment", "queue_free")


func _on_player_death_animation_finished() -> void:
	get_tree().change_scene_to_file("res://Src/Interface/Menus/DeathMenu.tscn")
