extends Node2D


onready var stage1_sc = preload("res://Src/Actors/Mitch/Phases/Stage1.tscn")
onready var stage2_sc = preload("res://Src/Actors/Mitch/Phases/Stage2.tscn")
onready var stage3_sc = preload("res://Src/Actors/Mitch/Phases/Stage3.tscn")
var health = 100
onready var current_stage = null


func _ready():
	$AnimationPlayer.play("idle")

func _process(_delta):
	pass

func intiate_stage1():
	var stage1 = stage1_sc.instance()
	add_child(stage1)

func intiate_stage2():
	var stage2 = stage2_sc.instance()
	add_child(stage2)

func intiate_stage3():
	var stage3 = stage3_sc.instance()
	add_child(stage3)
	$AnimationPlayer.play("stage3_idle")




func take_damage(damage, stage):
	health -= damage
	if health < 0 :
		change_stage(stage)

func change_stage(stage):
	if stage == 0:
		intiate_stage2()
		return 1
	if stage == 1:
		intiate_stage3()
		return 2
	if stage == 2:
		return 3

		
