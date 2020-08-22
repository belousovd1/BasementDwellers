extends Node2D


export(Texture) var portait  
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$PortraitSprite.texture = portait


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
