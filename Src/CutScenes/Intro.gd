extends Control
## The opening crawl, typed out page by page with the GodotTIE text engine.
## Accept skips straight to the main menu.

const MAIN_MENU := "res://Src/Interface/Menus/MainMenu.tscn"
## Seconds the last page stays up before the menu.
const END_PAUSE := 5.0

## Each page is typed out in order. An item is either [text, seconds per letter]
## or a pause in seconds.
const PAGES := [
	[
		["Far away,", 0.1],
		1.0,
		[" in the middle of bufu Egypt.\n", 0.1],
		1.0,
		["Deep within a suburban basement,", 0.05],
		1.0,
		[" dwelled a special set of hooligans.\n", 0.05],
		1.0,
		["A gaggle of bozos,", 0.05],
		1.0,
		[" the kind that would clean up a little BBQ sauce on their homies lips\n", 0.05],
		1.0,
		["(If you know what I'm saying)", 0.01],
		1.5,
	],
	[
		["These sexually confident Bois had done the unimaginable.\n", 0.05],
		2.0,
		["They had succeeded in finding the power of true friendship.\n", 0.05],
		1.0,
		["And with it,", 0.05],
		1.0,
		[" each and every one of them became capable of tremendous strength.\n", 0.05],
		1.0,
		["But,", 0.4],
		1.0,
		[" as Kanye once said,", 0.05],
		1.0,
		[" 'No one man should have all that power'.\n", 0.05],
		2.0,
	],
	[
		["At first", 0.05],
		1.0,
		[" nothing changed after achieving this power.\n", 0.05],
		0.5,
		["They were mostly concerned with themselves,", 0.05],
		0.5,
		[" not worrying about anything beyond their basement.", 0.05],
		1.5,
	],
	[
		["However,", 0.01],
		1.0,
		[" news of their accomplishment spread far and wide.\n", 0.05],
		1.0,
		["It did not take long for visitors to come from all corners of the globe.\n", 0.05],
		1.0,
		["Courageous warriors came seeking to test their might against it.\n", 0.05],
		1.0,
		["Learned scholars traveled to record, and study it.\n", 0.05],
		1.0,
		["Cunning thieves navigated to the basement in hopes of stealing it.\n", 0.05],
		2.0,
	],
	[
		["The friends quickly grew frustrated from all the toxicity that followed.\n", 0.05],
		1.0,
		["They then came to an agreement,", 0.05],
		1.0,
		[" holding hands they recited a pledge to one another, \n", 0.05],
		1.0,
		["'we're done playing League of Legends'.\n", 0.01],
		2.0,
		["And while they were at it, they also decided to cut themselves off from the rest of the world.", 0.05],
		2.0,
	],
	[
		["A potential catastrophe looms over all of us in that basement.\n", 0.05],
		2.0,
		["On any given day these giants could wake from their slumber", 0.05],
		1.0,
		[" and decide to flatten this world.", 0.05],
		2.0,
	],
	[
		["You must vanquish these soon to be horsemen of the apocalypse.\n", 0.05],
		2.0,
		["Remove this threat once and for all,", 0.05],
		1.0,
		[" to finally put an end to these so called.....", 0.05],
		2.0,
	],
]

@onready var _tie = $Panel/TextInterfaceEngine  # GodotTIE text_interface_engine.gd
@onready var _music: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	_play_crawl()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file(MAIN_MENU)


func _play_crawl() -> void:
	for page in PAGES:
		_tie.reset()
		for item in page:
			if item is Array:
				_tie.buff_text(item[0], item[1])
			else:
				_tie.buff_silence(item)
		_tie.set_state(_tie.STATE_OUTPUT)
		await _tie.buff_end
	# A connection (unlike an await) is dropped if the player skips meanwhile.
	get_tree().create_timer(END_PAUSE).timeout.connect(_on_crawl_finished)


func _on_crawl_finished() -> void:
	_music.stop()
	get_tree().change_scene_to_file(MAIN_MENU)
