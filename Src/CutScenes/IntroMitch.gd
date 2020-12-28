extends Control


onready var dialogue_sc = preload("res://Src/Interface/DialogueBox.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Start")
	#start_Dialogue()

func start_Dialogue():
	$DialogueST.play()
	var dialogue  = dialogue_sc.instance()
	dialogue.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/IntroMitch.json"
	add_child(dialogue)
	dialogue.get_node("DialogueBox").connect("finish", self, "end_dialogue_ST")

func end_dialogue_ST():
	$DialogueST.stop()
