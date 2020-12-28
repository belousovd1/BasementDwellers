extends Node2D


onready var stage1_sc = preload("res://Src/Actors/Mitch/Phases/Stage1.tscn")
onready var stage2_sc = preload("res://Src/Actors/Mitch/Phases/Stage2.tscn")
onready var stage3_sc = preload("res://Src/Actors/Mitch/Phases/Stage3.tscn")
var health = 100
onready var current_stage = null


func _ready():
	$AnimationPlayer.play("idle")
	#change_stage(current_stage)
	intiate_stage1()
	

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




func take_damage(damage, stage):
	health -= damage
	if health < 0 :
		change_stage(stage)

func change_stage(stage):
	if stage == null:
		intiate_stage1()
	if stage == "stage1":
		intiate_stage2()
	if stage == "stage2":
		intiate_stage3()
	if stage == "stage3":
		pass

		
