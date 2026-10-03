extends Control
## Gabe's entrance before his fight: after a moment of black he drifts in from
## the right like he's parking, the air around him turns menacing, he
## introduces himself, then the curtain drops and the fight starts. Accept
## skips the drift.

const DialogueBoxScene := preload("res://Src/Interface/DialogueBox.tscn")
const DIALOGUE := "res://Src/CutScenes/dialogues/Gabe/IntroGabe.json"
const FIGHT_SCENE := "res://Src/Interface/GabeFight.tscn"
const BLACK_SECONDS := 1.2
const DRIFT_SECONDS := 0.9
## How far off the right edge of the screen he starts.
const START_OFFSET := 400.0

var _arrival: Tween

@onready var _gabe: Gabe = $Gabe
@onready var _music: AudioStreamPlayer = $Music
@onready var _arrival_sound: AudioStreamPlayer = $ArrivalSound
@onready var _curtain: AnimationPlayer = $CurtainColorRect/AnimationPlayer


func _ready() -> void:
	_curtain.play("fade_in")
	var landing := _gabe.position.x
	_gabe.position.x = get_viewport_rect().size.x + START_OFFSET
	_arrival = create_tween()
	_arrival.tween_interval(BLACK_SECONDS)
	_arrival.tween_callback(_arrival_sound.play)
	_arrival.tween_property(_gabe, "position:x", landing, DRIFT_SECONDS) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_arrival.tween_callback(_gabe.menace)
	await _arrival.finished
	_start_dialogue()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and _arrival.is_running():
		# Handled first, so the dialogue that starts now doesn't see the press.
		get_viewport().set_input_as_handled()
		_arrival.custom_step(BLACK_SECONDS + DRIFT_SECONDS)


func _start_dialogue() -> void:
	var dialogue: DialogueBox = DialogueBoxScene.instantiate()
	dialogue.dialogue_path = DIALOGUE
	add_child(dialogue)
	await dialogue.finished

	_music.stop()
	_curtain.play("fade_out")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(FIGHT_SCENE)
