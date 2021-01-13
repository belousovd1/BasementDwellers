extends Control


onready var dialogue_sc = preload("res://Src/Interface/DialogueBox.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Start")


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		skip_intro()

func start_Dialogue():
	$EnterPath/PathFollow2D/Mitch.set_scale(Vector2(3,3))
	$DialogueST.play()
	var dialogue  = dialogue_sc.instance()
	dialogue.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/IntroMitch.json"
	add_child(dialogue)
	dialogue.get_node("DialogueBox").connect("finish", self, "end_dialogue_ST")

func end_dialogue_ST():
	$DialogueST.stop()
	yield(get_tree().create_timer(1), "timeout")
	var _err = get_tree().change_scene("res://Src/Interface/Main.tscn")

func skip_intro():
	$AnimationPlayer.advance(8.0)
