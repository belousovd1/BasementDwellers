extends Node


onready var paintbrush_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBullet.tscn")
onready var paintbrush_row_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBulletRow.tscn")
onready var paintbrush_boomerang_attack_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/PaintBrushBoomerangAttack.tscn")
onready var legattack_sc = preload("res://Src/Actors/Mitch/Mitch_LegAttacks.tscn")

signal done_attacking

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = connect("done_attacking", $"../../", "attack_boss")
	attack1()
	


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
	spwn_legattack()
	make_timer(5, "attack2")

func attack2():
	$Mitch_LegAttacks.queue_free()
	spwn_boomerang(Vector2(0, 600), Vector2(0, -1))
	make_timer(2, "attack3")

func attack3():
	var count = 0
	while count < 3:
		spwn_boomerang_row(0, Vector2(400, 264), Vector2(-1,0), 90)
		yield(get_tree().create_timer(.60), "timeout")
		spwn_boomerang_row(1, Vector2(400, 264), Vector2(-1,0), 90)
		yield(get_tree().create_timer(.60), "timeout")
		spwn_boomerang_row(2, Vector2(400, 264), Vector2(-1,0), 90)
		yield(get_tree().create_timer(.60), "timeout")
		count += 1
		
	make_timer(3, "attack4")
 

func attack4():
	spwn_boomerang(Vector2(0, 600), Vector2(0, -1))
	spwn_boomerang_row(1, self.position, Vector2(0, 1))   
	make_timer(2, "attack5")
	
func attack5():
	spwn_boomerang(Vector2(0,0), Vector2(0, 1))
	spwn_boomerang_row(1, Vector2(0, 600), Vector2(0, -1))   
	make_timer(2, "attack6")

func attack6():
	spwn_boomerang(Vector2(600, 264), Vector2(-1, 0))
	spwn_boomerang_row(1, Vector2(-600,264), Vector2(1, 0), 90)   
	make_timer(1.5, "attack7")

func attack7():
	spwn_boomerang(Vector2(600, 264), Vector2(-1, 0))
	spwn_boomerang_row(1, Vector2(-600,264), Vector2(1, 0), 90)   
	make_timer(2, "attack8")

func attack8():
	spwn_boomerang(Vector2(-600, 264), Vector2(1, 0))
	spwn_boomerang_row(1, Vector2(600, 264), Vector2(-1, 0), 90)
	make_timer(2, "attack9")

func attack9():
	spwn_legattack(true)
	make_timer(7, "attack10")

func attack10():
	$Mitch_LegAttacks.queue_free()
	make_timer(1, "emit_end_atc")


func emit_end_atc():
	emit_signal("done_attacking")

