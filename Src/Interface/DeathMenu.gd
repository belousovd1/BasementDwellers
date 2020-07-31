extends Control


onready var quit = $Quit
onready var restart = $Restart



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_Restart_pressed():
	get_tree().change_scene("res://Src/Interface/Main.tscn")
func _on_Quit_pressed():
	get_tree().quit()
