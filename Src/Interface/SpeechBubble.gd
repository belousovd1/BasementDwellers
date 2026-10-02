class_name SpeechBubble
extends Node2D
## A comic-style speech bubble that types out a line with a bleep per letter,
## holds it for a moment, then disappears.
##
## The node's origin is the tip of the tail; [method say] keeps that tip on
## [member speaker_point] (in global coordinates) every frame, so the bubble
## follows whoever is talking. It is drawn top-level so it isn't scaled with
## the speaker, which keeps the pixel font crisp.

signal finished

## Seconds per letter while typing.
@export var letter_time := 0.04
## Seconds the full line stays up after it has been typed.
@export var hold_time := 1.8
## Lines wider than this (in pixels) wrap onto more lines.
@export var max_width := 420.0

## Node the tail points at, and the offset from it in that node's own space.
var speaker: Node2D
var speaker_offset := Vector2.ZERO

@onready var _box: PanelContainer = $Box
@onready var _label: Label = $Box/Text
@onready var _bleep: AudioStreamPlayer = $Bleep
@onready var _letter_timer: Timer = $LetterTimer


func _ready() -> void:
	top_level = true


func _process(_delta: float) -> void:
	if is_instance_valid(speaker):
		# Whole pixels only, so the bubble stays crisp as it follows the speaker.
		global_position = speaker.to_global(speaker_offset).round()


## Types [param line] into the bubble, holds it, then frees the bubble.
func say(line: String) -> void:
	var text := _wrap(line)
	_label.text = text
	_label.visible_characters = 0
	# Size the bubble for the whole line up front (the text reveals letters
	# without re-laying out), hanging below and to the right of the tail.
	_box.reset_size()
	_box.position = Vector2(12, 26)
	_process(0.0)

	_letter_timer.wait_time = letter_time
	for letter in text:
		_label.visible_characters += 1
		if letter == "\n":
			continue
		if letter != " ":
			_bleep.play()
		_letter_timer.start()
		await _letter_timer.timeout
	_label.visible_characters = -1

	_letter_timer.start(hold_time)
	await _letter_timer.timeout
	finished.emit()
	queue_free()


## Breaks [param line] into lines no wider than [member max_width]. Done by hand
## because an auto-wrapping Label only knows its height after it has been drawn.
func _wrap(line: String) -> String:
	var font := _label.get_theme_font("font")
	var font_size := _label.get_theme_font_size("font_size")
	var lines: PackedStringArray = []
	var current := ""
	for word in line.split(" "):
		var candidate := word if current.is_empty() else current + " " + word
		if not current.is_empty() and font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > max_width:
			lines.append(current)
			current = word
		else:
			current = candidate
	lines.append(current)
	return "\n".join(lines)
