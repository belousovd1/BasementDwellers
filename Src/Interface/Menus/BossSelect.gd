extends Control
## The Load screen: pick which boss to fight instead of starting from the first
## one. Each boss starts with its entrance, and once it is beaten the story
## carries on to the next boss as usual. Hovering a boss shows its picture.

const MAIN_MENU := "res://Src/Interface/Menus/MainMenu.tscn"
const MenuButtonScene := preload("res://Src/Interface/Menus/MenuButton.tscn")

## The bosses in story order: the name on the button, the scene the fight
## starts from, the picture and the part of it to show, and a line about them.
const BOSSES: Array[Dictionary] = [
	{
		"name": "Mitch",
		"scene": "res://Src/CutScenes/IntroMitch.tscn",
		"picture": preload("res://Assets/Sprites/Mitch/mitch-sprite.png"),
		"region": Rect2(14, 6, 94, 166),
		"blurb": "Sauce master of the basement.",
	},
	{
		"name": "Mike",
		"scene": "res://Src/CutScenes/IntroMike.tscn",
		"picture": preload("res://Assets/Sprites/Mike/mike.png"),
		"region": Rect2(18, 9, 56, 103),
		"blurb": "Blender guru. Meditates. Extrudes.",
	},
	{
		"name": "Gabe",
		"scene": "res://Src/CutScenes/IntroGabe.tscn",
		"picture": preload("res://Assets/Sprites/Gabe/gabe.png"),
		"region": Rect2(20, 2, 65, 120),
		"blurb": "Apple Genius, car guy, Dunkey fan.",
	},
	{
		"name": "Rafi",
		"scene": "res://Src/CutScenes/IntroRafi.tscn",
		"picture": preload("res://Assets/Sprites/Rafi/rafi.png"),
		"region": Rect2(26, 0, 47, 122),
		"blurb": "Arms crossed. Seen it all.",
	},
	{
		"name": "Alex",
		"scene": "res://Src/CutScenes/IntroAlex.tscn",
		"picture": preload("res://Assets/Sprites/Alex/alex.png"),
		"region": Rect2(26, 0, 59, 121),
		"blurb": "The headliner. Keeps the beat.",
	},
]

@onready var _buttons: VBoxContainer = %Bosses
@onready var _picture: TextureRect = %Picture
@onready var _blurb: Label = %Blurb


func _ready() -> void:
	for boss in BOSSES:
		var button := MenuButtonScene.instantiate()
		button.label = boss.name
		button.pressed.connect(_on_boss_pressed.bind(boss.scene))
		button.mouse_entered.connect(_show.bind(boss))
		_buttons.add_child(button)
	_show(BOSSES[0])


## Shows [param boss]'s picture and line.
func _show(boss: Dictionary) -> void:
	var picture := AtlasTexture.new()
	picture.atlas = boss.picture
	picture.region = boss.region
	_picture.texture = picture
	_blurb.text = boss.blurb


func _on_boss_pressed(scene: String) -> void:
	get_tree().change_scene_to_file(scene)


func _on_Back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
