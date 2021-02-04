extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass

func _on_Start_pressed():
	print("start button pressed")
	var _err = get_tree().change_scene("res://Src/CutScenes/IntroMitch.tscn")

func _on_Load_pressed():
	pass

func _on_Options_pressed():
	var _err = get_tree().change_scene("res://Src/Interface/Menus/OptionMenu.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func hide_everything_but_fire():
	get_tree().call_group("everything_but_fire", "invisible") 