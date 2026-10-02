extends Control
## Mitch's entrance before the fight: he rolls in along a path, introduces
## himself, then the curtain drops and the fight starts. Each press of accept
## jumps the entrance forward.

const DialogueBoxScene := preload("res://Src/Interface/DialogueBox.tscn")
const DIALOGUE := "res://Src/CutScenes/dialogues/Mitch/IntroMitch.json"
const SKIP_SECONDS := 8.0

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _mitch: Node2D = $EnterPath/PathFollow2D/Mitch
@onready var _dialogue_music: AudioStreamPlayer = $DialogueST
@onready var _curtain: AnimationPlayer = $CurtainColorRect/CurtainAnimationPlayer


func _ready() -> void:
	_animation_player.play("Start")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_animation_player.advance(SKIP_SECONDS)


# Called from the end of the "MitchEnter" animation.
func _start_dialogue() -> void:
	_mitch.scale = Vector2(3, 3)
	_dialogue_music.play()
	var dialogue: DialogueBox = DialogueBoxScene.instantiate()
	dialogue.dialogue_path = DIALOGUE
	add_child(dialogue)
	await dialogue.finished

	_dialogue_music.stop()
	_curtain.play("fade_out")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Src/Interface/Main.tscn")
