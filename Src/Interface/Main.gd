extends Node

signal player_health_change(player_health)
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


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
