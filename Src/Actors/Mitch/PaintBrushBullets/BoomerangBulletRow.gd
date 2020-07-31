extends Node2D

var speed = 200
var dir = Vector2.ZERO
var signal_sent = false
onready var boomerangs = get_children()
var removed_index
var count_direction_up

signal newrow(new_removed_index, new_count_direction_up)

func _ready():
	connect("newrow", $"../", "spawn_boomerang_row" )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position +=  dir.normalized() * speed * delta
	if not signal_sent:
		check_send_signal()


			

func check_for_newline():
	return self.position.y > 200

func check_send_signal():
	if check_for_newline():
		emit_signal("newrow", calc_new_index(removed_index), count_direction_up)
		signal_sent = true

func remove_boomerang():
	boomerangs[removed_index].queue_free()

func calc_new_index(removed_index):
	if removed_index == 0:
		count_direction_up = true
	elif removed_index == 2:
		count_direction_up = false
	if count_direction_up == true:
		return removed_index + 1
	else:
		return removed_index - 1




