extends Node

onready var attack_bar_sc = preload("res://Src/Interface/AttackBar.tscn")

signal player_health_change(player_health)
signal attack_finished


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("attack_finished", $Mitch/Stage1, "attack4")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_player_hit(hp):
	$OnHitCamera.make_current()
	$HitTimer.start()
	emit_signal("player_health_change", hp)

func _on_HitTimer_timeout():
	$OnHitCamera.offset.x = 0
	$OnHitCamera.offset.y = 0
	$OnHitCamera.clear_current()

func _on_Player_dead():
	get_tree().change_scene("res://Src/Interface/DeathMenu.tscn")


func attack_boss():
	get_tree().call_group("defense", "invisible")
	var attack_bar = attack_bar_sc.instance()
	add_child(attack_bar)
	attack_bar.position = Vector2(534, 510)

func attack_finished(anm_name):
	if anm_name == "hit":
		$AttackBar.queue_free()
		get_tree().call_group("defense", "visible")
		emit_signal("attack_finished")
		$Mitch/AnimationPlayer.play("idle")




