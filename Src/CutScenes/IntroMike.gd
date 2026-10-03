extends Control
## Mike's entrance before his fight: he floats down from above the screen to
## where he is placed in the scene, introduces himself, then the curtain drops
## and the fight starts. Accept skips the descent.

const DialogueBoxScene := preload("res://Src/Interface/DialogueBox.tscn")
const DIALOGUE := "res://Src/CutScenes/dialogues/Mike/IntroMike.json"
const FIGHT_SCENE := "res://Src/Interface/MikeFight.tscn"
const DESCENT_SECONDS := 6.0
## How far above the screen's top edge he starts.
const START_HEIGHT := -300.0

var _descent: Tween

@onready var _mike: Node2D = $Mike
@onready var _music: AudioStreamPlayer = $Music
@onready var _curtain: AnimationPlayer = $CurtainColorRect/AnimationPlayer


func _ready() -> void:
	_curtain.play("fade_in")
	var landing := _mike.position
	_mike.position.y = START_HEIGHT
	_descent = create_tween()
	_descent.tween_property(_mike, "position", landing, DESCENT_SECONDS) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await _descent.finished
	_start_dialogue()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and _descent.is_running():
		# Handled first, so the dialogue that starts now doesn't see the press.
		get_viewport().set_input_as_handled()
		_descent.custom_step(DESCENT_SECONDS)


func _start_dialogue() -> void:
	var dialogue: DialogueBox = DialogueBoxScene.instantiate()
	dialogue.dialogue_path = DIALOGUE
	add_child(dialogue)
	await dialogue.finished

	_music.stop()
	_curtain.play("fade_out")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(FIGHT_SCENE)
