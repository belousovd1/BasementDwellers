extends Node2D

onready var paintbrush_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBullet.tscn")
onready var paintbrush_row_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBulletRow.tscn")
onready var paintbrush_boomerang_attack_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/PaintBrushBoomerangAttack.tscn")
onready var legattack_sc = preload("res://Src/Actors/Mitch/Mitch_LegAttacks.tscn")
onready var mallochio_path_sc = preload("res://Src/Actors/Mitch/MalocchioPath.tscn")
onready var mallochio_sc = preload("res://Src/Actors/Mitch/Malocchio.tscn")

signal done_attacking

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = connect("done_attacking", $"../../", "attack_boss")
	mallochio_summon()
	

func mallochio_summon():
	var mallochio = mallochio_sc.instance()
	add_child(mallochio)
	mallochio.connect("tree_exiting", self, "attack1")
	mallochio.summon()

func spwn_mallochio():
	var mallochio_attack = mallochio_path_sc.instance()
	add_child(mallochio_attack)

func spwn_boomerang(pos, dir):
	var paintbrush = paintbrush_sc.instance()
	paintbrush.position = pos
	paintbrush.dir = dir
	add_child(paintbrush)
	paintbrush.speed = 400
	return paintbrush 

func spwn_paintbrush_boom_atk(pos):
	var paintbrush_attack = paintbrush_boomerang_attack_sc.instance()
	paintbrush_attack.position.y = pos
	add_child(paintbrush_attack)

func spwn_boomerang_row(index_to_remove, pos, dir, rot = 0):
	var boomerang_row = paintbrush_row_sc.instance()
	boomerang_row.dir = dir
	boomerang_row.removed_index = index_to_remove
	boomerang_row.position = pos
	boomerang_row.rotation_degrees = rot
	add_child(boomerang_row)
	boomerang_row.speed = 400 
	boomerang_row.remove_boomerang()

func spwn_legattack(adv = false):
	var legattack = legattack_sc.instance()
	legattack.position.y = 264
	add_child(legattack)
	if adv:
		legattack.adv_alternating_kicks()

func make_timer(w_time, next_func):
	var timer = Timer.new()
	timer.wait_time = w_time
	timer.one_shot = true	
	add_child(timer)
	timer.start()
	timer.connect("timeout", self, next_func)

func attack1():
	spwn_mallochio()

func attack2():
	pass

func emit_end_atc():
	emit_signal("done_attacking")


