
extends Control
class_name Message, "res://addons/radmatt.DialogueSystem2/icons/Message.svg"

###############################################################################
# Settings:

export (NodePath) var text_path
export (NodePath) var choices_path

export var sound_effect_speed = 0.1 # Sound effect frequency

export var bubble_y_offset = -48 # Bubble only
export var bubble_max_width = 700 # Bubble only

var pause_time = 0.4 # (sec) # when using '|' in text.
var punctuation_marks_pauses = {
	".":0.7,
	"...":0.3,
	",":0.25,
	";":0.4,
	"!":0.7,
	"?":0.7,
}

const NORMAL = 0.03
const FAST = 0.01
const SLOW = 0.2
var text_speed = NORMAL

##############################
# SIGNALS
signal started_new_message
signal finished_message

##############################
# NODES:
onready var sound = $SoundEffect
onready var Continue = $Continue
onready var text_node = get_node(text_path)
onready var Choices = get_node(choices_path)


##############################
# VARIABLES:
var wait_for_choice = false
var is_message_completed = false
var current_character = 0 # Current letter in a text
var characters_left = []

###############################################################################
### FUNCTIONS ###
###############################################################################

func _ready():
	Dialogue.connect("dialogue_ended", self, "_on_dialogue_ended")
	Dialogue.connect("dialogue_started", self, "_on_dialogue_started")
	set_process(false)
	Continue.set_process(false)
	Continue.set_process_input(false)
	$TextBackground.set_process(false)
	hide()


# SET ITS SIZE TO MATCH THE TEXT
func _process(delta):
	Dialogue.Box.get_node("TextBackground").margin_top = 0


func show_new_message(text, wait_for_choice=false): # Message initiation
	Continue.hide()
	text_speed = NORMAL
	if wait_for_choice:
		Dialogue.can_continue = false
	is_message_completed = false
	text_node.clear()
	text_node.text = text
	Dialogue.message_finished = false
	if ! Dialogue.current_choices_array.empty():
		Dialogue.is_waiting_for_decision = true
	else:
		Dialogue.is_waiting_for_decision = false

	emit_signal("started_new_message")
	_start_showing_characters()
	show()


func finish_message(): # If pressed [dialogue_next] button while the text was appearing >>> jump to the end.
	Continue.show()
	is_message_completed = true
	text_node.show_all_characters()
	Dialogue.message_finished = true
	if ! Dialogue.current_choices_array.empty():
		Choices.activate()
	else:
		pass

	emit_signal("finished_message")



func _start_showing_characters():
	var n = 0
	for x in text_node.clean_text.length():
		if ! is_message_completed:
			text_node.visible_characters += 1
			var v = text_node.visible_characters

			var letter = text_node.clean_text[v-1]

			#SOUNDS
			if n % 3  == 0:
				var r = randi() % 9 + 1
				var s = load("res://addons/radmatt.DialogueSystem2/sfx/new/Audio Track-" + str(r) + ".wav")
				$SoundEffect.stream = s
				$SoundEffect.play()
			n+=1

			var _pause_t = text_speed

			# SPEED TAGS (<slow>, <normal>, <fast>)
			if Dialogue.speed_tag_positions.has(v):
				if Dialogue.speed_tag_positions[v] == "slow":
					text_speed = SLOW
				elif Dialogue.speed_tag_positions[v] == "normal":
					text_speed = NORMAL
				elif Dialogue.speed_tag_positions[v] == "fast":
					text_speed = FAST


			# PAUSES FOR '|'
			if Dialogue.pause_positions.has(v):
				_pause_t += pause_time


			# PAUSES FOR PUNCTUATION MARKS (; , . ... ! ?)
			if v == 0:
				if punctuation_marks_pauses.has(text_node.cleaner_text[v]):
					_pause_t += punctuation_marks_pauses[text_node.cleaner_text[v]]
			else:
				if v-1 < text_node.cleaner_text.length():
					if punctuation_marks_pauses.has(text_node.cleaner_text[v-1]):
						if text_node.cleaner_text[v-1] == ".":
							if text_node.cleaner_text[v] == ".":
								_pause_t += punctuation_marks_pauses["..."]
							else:
								_pause_t += punctuation_marks_pauses[text_node.cleaner_text[v-1]]
						else:
							_pause_t += punctuation_marks_pauses[text_node.cleaner_text[v-1]]

			# SKIPPING LAST PAUSE
			if v == text_node.clean_text.length():
				print("LAST LETTER, SKIPPING PAUSE") # usually it's a '.' but there's no need to do a pause after it
			else:
				yield(get_tree().create_timer(_pause_t), "timeout")
		else:
			break
	finish_message()


func _on_dialogue_started():
	set_process(true)
	Continue.set_process(true)
	Continue.set_process_input(true)
	$TextBackground.set_process(true)

func _on_dialogue_ended():
	print("DIALOGUE_ ENDED")
	set_process(false)
	Continue.set_process(false)
	Continue.set_process_input(false)
	$TextBackground.set_process(false)
