extends Node2D

var speed = 200
var dir = Vector2.ZERO
onready var boomerangs = get_children()
var removed_index


func _ready():
	var _err = connect("newrow", $"../", "spawn_boomerang_row" )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position +=  dir.normalized() * speed * delta

func remove_boomerang():
	boomerangs[removed_index].queue_free()





