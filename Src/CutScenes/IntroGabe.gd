extends Control
## Gabe's entrance before his fight: after a moment of black he drifts in from
## the right like he's parking, he introduces himself and begs Dunkey for
## power, Dunkey blesses him, then the curtain drops and the fight starts.
## Accept skips the drift.

const DialogueBoxScene := preload("res://Src/Interface/DialogueBox.tscn")
const BlessingScene := preload("res://Src/Actors/Gabe/Blessing.tscn")
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
	# The swish is imported looping, for Mitch's boomerangs, so stop it once
	# he's parked.
	_arrival.tween_callback(_arrival_sound.stop)
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
	dialogue.line_event.connect(_on_line_event)
	add_child(dialogue)
	await dialogue.finished

	var blessing := BlessingScene.instantiate()
	blessing.target = _gabe
	add_child(blessing)
	await blessing.finished

	_curtain.play("fade_out")
	await get_tree().create_timer(1).timeout
	# The fight carries on with the same track from where it has got to.
	Main.carry_music(_music.stream, _music.get_playback_position())
	get_tree().change_scene_to_file(FIGHT_SCENE)


func _on_line_event(event: String) -> void:
	if event == "music":
		_music.play()
