extends Node2D


onready var stage1_sc = preload("res://Src/Actors/Mitch/Phases/Stage1.tscn")

func _ready():
	$AnimationPlayer.play("idle")
	#intiate_stage1()
	

func _process(delta):
	pass


func intiate_stage1():
	var stage1 = stage1_sc.instance()
	add_child(stage1)








