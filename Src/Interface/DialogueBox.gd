extends Control

class_name DialogueBox

export var dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/TestDialogue.json" 
var index = 0
onready var dialogue = load_dialogue(dialogue_file_path).result
onready var  skip
onready var finished = false
signal finish


func _ready():
	write_dialogue_by_text()


func _process(_delta):
	$NextIndicator.visible = finished
	if finished:
		if Input.is_action_just_pressed("ui_accept"):
			write_dialogue_by_text()
	else:
		if Input.is_action_just_pressed("ui_accept"):
			skip = true


		



func write_dialogue_by_text():
	if index < dialogue.size():
		$Name.clear()
		$Name.add_text(dialogue[index]["name"])
		finished = false

		$DialogueText.clear()
		$DialogueText.set_use_bbcode(true)
		$DialogueText.set_bbcode(dialogue[index]["text"])
		$DialogueText.visible_characters = 0
		var t = Timer.new()
		t.set_wait_time(float(dialogue[index]["time"]))
		t.set_one_shot(true)
		self.add_child(t)
		var in_bb_tage = false


		for letter in $DialogueText.bbcode_text:
			if skip:
				show_all_dialogue()
				skip = false
				break
			var should_bleep
			t.start()
			if letter == "[":
				 in_bb_tage = true 
			if not in_bb_tage: $DialogueText.visible_characters += 1
			should_bleep = determine_if_bleep(letter, in_bb_tage)
			if should_bleep: $Bleep.play()
			if not in_bb_tage: 
				yield(t, "timeout")			
			if letter == "]" :
				in_bb_tage = false 

		finished = true
	else:
		emit_signal("finish")
		queue_free()
	index += 1


func determine_if_bleep(letter, in_bb_tage):
	if in_bb_tage:
		return false
	elif letter == " ":
		return false
	else:
		return true

func show_all_dialogue():
	$DialogueText.visible_characters = -1

func load_dialogue(file_path):
	var file = File.new()
	file.open(file_path, file.READ)
	var jason_dialogue = JSON.parse(file.get_as_text())
	file.close()
	return jason_dialogue

func calc_draw_time(char_time):
	var duration = $DialogueText.bbcode_text.length() * char_time
	return duration
