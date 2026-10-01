class_name DialogueBox
extends Control
## A conversation shown one line at a time, typed out letter by letter with a
## bleep per letter. Accept finishes the current line at once, or moves on to
## the next one. Emits [signal finished] and frees itself after the last line.
##
## [member dialogue_path] points to a JSON array of lines such as
## [code]{"name": "Mitch", "text": "Hi [color=red]kid[/color].", "time": ".05"}[/code],
## where "text" may use BBCode and "time" is the delay per letter in seconds.

signal finished

@export_file("*.json") var dialogue_path := ""

var _lines: Array = []
var _line_index := -1
var _typing := false
var _skip_requested := false

@onready var _speaker: RichTextLabel = $Panel/Name
@onready var _text: RichTextLabel = $Panel/DialogueText
@onready var _next_indicator: CanvasItem = $Panel/NextIndicator
@onready var _bleep: AudioStreamPlayer = $Panel/Bleep
@onready var _letter_timer: Timer = $LetterTimer


func _ready() -> void:
	_lines = JSON.parse_string(FileAccess.get_file_as_string(dialogue_path))
	_show_next_line()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return
	if _typing:
		_skip_requested = true
	else:
		_show_next_line()


func _show_next_line() -> void:
	_line_index += 1
	if _line_index >= _lines.size():
		finished.emit()
		queue_free()
		return

	var line: Dictionary = _lines[_line_index]
	_speaker.text = line["name"]
	_text.text = line["text"]
	_text.visible_characters = 0
	_letter_timer.wait_time = float(line["time"])
	_typing = true
	# A press that landed during the previous line's last letter shouldn't
	# skip this one.
	_skip_requested = false
	_next_indicator.visible = false

	for letter in _text.get_parsed_text():
		if _skip_requested:
			_skip_requested = false
			_text.visible_characters = -1
			break
		_text.visible_characters += 1
		if letter != " ":
			_bleep.play()
		_letter_timer.start()
		await _letter_timer.timeout

	_typing = false
	_next_indicator.visible = true
