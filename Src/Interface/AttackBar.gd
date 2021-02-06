extends Node2D

onready var main = $"../"
onready var mitch_anim_node = $"../Mitch/AnimationPlayer"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Run")
	mitch_anim_node.connect("animation_finished", $"../", "attack_finished")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("ui_accept"):
		$AnimationPlayer.stop()
		mitch_anim_node.play("hit")


func get_damage():
	var max_damage = 100
	var indcator_pos = $Indicator.get_position().x
	indcator_pos = turn_pos(indcator_pos)
	var damage = (1 - (indcator_pos / 1030)) * max_damage
	return round(damage)


func turn_pos(num):
	if num < 0:
		num *= -1
	return num
