extends Node


onready var paintbrush_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBullet.tscn")
onready var paintbrush_row_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBulletRow.tscn")
onready var paintbrush_boomerang_attack_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/PaintBrushBoomerangAttack.tscn")

signal done_attacking

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = connect("done_attacking", $"../../", "attack_boss")
	attack1()
	


func spwn_boomerang(pos, dir):
	var paintbrush= paintbrush_sc.instance()
	paintbrush.position = pos
	paintbrush.dir = dir
	add_child(paintbrush)
	return paintbrush 

func spwn_paintbrush_boom_atk(pos):
	var paintbrush_attack = paintbrush_boomerang_attack_sc.instance()
	paintbrush_attack.position.y = pos
	add_child(paintbrush_attack)

func spwn_boomerang_row(index_to_remove):
	var boomerang_row = paintbrush_row_sc.instance()
	boomerang_row.dir = Vector2(0,1)
	boomerang_row.removed_index = index_to_remove
	add_child(boomerang_row)
	boomerang_row.remove_boomerang()

func make_timer(w_time, next_func):
	var timer = Timer.new()
	timer.wait_time = w_time
	timer.one_shot = true	
	add_child(timer)
	timer.start()
	timer.connect("timeout", self, next_func)

func attack1():
	spwn_paintbrush_boom_atk(0)
	make_timer(2, "attack2")

func attack2():
	spwn_boomerang(Vector2(400, 150), Vector2(-1,0))
	spwn_boomerang(Vector2(-400, 350), Vector2(1,0))
	make_timer(3, "attack3")

func attack3():
	spwn_boomerang(Vector2(48, 0), Vector2(0,1))
	spwn_boomerang(Vector2(-48, 0), Vector2(0,1))
	make_timer(2, "attack4")

func attack4():
	spwn_paintbrush_boom_atk(0)
	make_timer(1, "attack5")

func attack5():
	spwn_boomerang(Vector2(400, 150), Vector2(-1,0))
	spwn_boomerang(Vector2(-400, 350), Vector2(1,0))
	make_timer(2, "attack6")

func attack6():
	spwn_boomerang(Vector2(48, 0), Vector2(0,1))
	spwn_boomerang(Vector2(-48, 0), Vector2(0,1))
	make_timer(2, "attack7")

func attack7():
	var count = 0
	while count < 3:
		spwn_boomerang_row(0)
		yield(get_tree().create_timer(1), "timeout")
		spwn_boomerang_row(1)
		yield(get_tree().create_timer(1), "timeout")
		spwn_boomerang_row(2)
		yield(get_tree().create_timer(1), "timeout")
		count += 1
	make_timer(2, "emit_end_atc")

func emit_end_atc():
	emit_signal("done_attacking")
