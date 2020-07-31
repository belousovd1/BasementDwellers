extends Node


var paintbrush_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBullet.tscn")
var paintbrush_row_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/BoomerangBulletRow.tscn")
var paintbrush_boomerang_attack_sc = preload("res://Src/Actors/Mitch/PaintBrushBullets/PaintBrushBoomerangAttack.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_paintbrush_boomerang()
	print("it worked")


func spawn_boomerang(pos, dir):
	var paintbrush= paintbrush_sc.instance()
	paintbrush.position = pos
	paintbrush.dir = dir
	add_child(paintbrush)
	return paintbrush 

func spawn_paintbrush_boomerang(pos):
	var paintbrush_attack = paintbrush_boomerang_attack_sc.instance()
	paintbrush_attack.position.y = pos
	add_child(paintbrush_attack)
	print("worked again")

func make_timer(w_time, next_func):
	var timer = Timer.new()
	timer.wait_time = w_time
	add_child(timer)
	timer.start()
	timer.connect("timeout", self, next_func)

func spawn_boomerang_row(index_to_remove, new_count_direction_up):
	var boomerang_row = boomerang_bullet_row_scene.instance()
	boomerang_row.dir = Vector2(0,1)
	boomerang_row.removed_index = index_to_remove
	boomerang_row.count_direction_up = new_count_direction_up
	add_child(boomerang_row)
	boomerang_row.remove_boomerang()

func attack1():
	spawn_paintbrush_boomerang(0)
	make_timer(2,"attack2")

func attak2():
	spawn_boomerang(Vector2(400, 150), Vector2(-1,0))
	spawn_boomerang(Vector2(-400, 150), Vector2(1,0))
	make_timer(2, "attack3")

func attack3():
	pass






