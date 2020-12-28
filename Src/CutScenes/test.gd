extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Mitch/Dialogue.start_dialogue("res://Src/CutScenes/dialogues/IntroMitchDialogue.json", get_parent())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
