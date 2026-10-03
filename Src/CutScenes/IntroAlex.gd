extends Control
## Alex's entrance before his fight: a spotlight clunks on in the dark, he
## fades in standing in it, says his piece, then the curtain drops and the
## fight starts. Accept skips to the dialogue.

const DialogueBoxScene := preload("res://Src/Interface/DialogueBox.tscn")
const DIALOGUE := "res://Src/CutScenes/dialogues/Alex/IntroAlex.json"
const FIGHT_SCENE := "res://Src/Interface/AlexFight.tscn"
const BLACK_SECONDS := 1.2
const LIGHT_SECONDS := 0.5
const FADE_SECONDS := 0.8

var _arrival: Tween

@onready var _alex: Node2D = $Alex
@onready var _spotlight: Polygon2D = $Spotlight
@onready var _spotlight_sound: AudioStreamPlayer = $SpotlightSound
@onready var _music: AudioStreamPlayer = $Music
@onready var _curtain: AnimationPlayer = $CurtainColorRect/AnimationPlayer


func _ready() -> void:
	_curtain.play("fade_in")
	_spotlight.hide()
	_alex.modulate.a = 0.0
	_arrival = create_tween()
	_arrival.tween_interval(BLACK_SECONDS)
	_arrival.tween_callback(_spotlight.show)
	_arrival.tween_callback(_spotlight_sound.play)
	_arrival.tween_interval(LIGHT_SECONDS)
	_arrival.tween_property(_alex, "modulate:a", 1.0, FADE_SECONDS)
	await _arrival.finished
	_start_dialogue()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and _arrival.is_running():
		# Handled first, so the dialogue that starts now doesn't see the press.
		get_viewport().set_input_as_handled()
		_arrival.custom_step(BLACK_SECONDS + LIGHT_SECONDS + FADE_SECONDS)


func _start_dialogue() -> void:
	var dialogue: DialogueBox = DialogueBoxScene.instantiate()
	dialogue.dialogue_path = DIALOGUE
	add_child(dialogue)
	await dialogue.finished

	_music.stop()
	_curtain.play("fade_out")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(FIGHT_SCENE)
