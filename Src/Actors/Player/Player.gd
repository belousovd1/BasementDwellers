extends KinematicBody2D


var speed = 300
var max_health = 100
var health = max_health
var inv = false
var alive = true
signal player_hit(health)
signal dead

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(_delta):
	if alive:
		player_movement()
	else:
		pass


func _on_ProjectileDetector_area_entered(area2D):
	if not(inv):
		var hp = take_damage(area2D.damage)
		inv = true
		$InvTimer.start()
		emit_signal("player_hit", hp)
	else:
		pass	


func take_damage(dmg):
	health -= dmg
	if health <= 0:
		end_game()
		return 0
	else:
		$AnimationPlayer.play("Hit")
		return health



func _on_InvTimer_timeout():
	inv = false

func end_game():
	alive = false
	$"../AudioStreamPlayer".stop()
	get_tree().call_group("environment", "queue_free")
	$AnimationPlayer.play("death")


func death_menu_signal():
	emit_signal("dead")


func player_movement():
	var velocity = Vector2.ZERO

	if Input.is_action_pressed("left"):
		velocity.x += -1 
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("up"):
		velocity.y += -1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide(velocity)

func invisible():
	visible = false

func visible():
	visible = true