extends Control


# Declare member variables here. Examples:
# var a = 2
onready var tie = $"Panel/TextInterfaceEngine"


# Called when the node enters the scene tree for the first time.
func _ready():
	window_two()


func window_one():
	tie.reset()
	tie.connect("buff_end", self, "window_two")
	tie.buff_text("Far away,", .1)
	tie.buff_silence(1)
	tie.buff_text(" in the middle of bufu Egypt.\n", .1)
	tie.buff_silence(1)
	tie.buff_text("Deep within a suburban basement,", .05)
	tie.buff_silence(1)
	tie.buff_text(" dwelled a special set of houligans.\n", .05) 
	tie.buff_silence(1)
	tie.buff_text("A gaggle of bozos,", .05)
	tie.buff_silence(1)
	tie.buff_text(" the kind that would clean up a little BBQ sauce on their homies lips\n", .05)
	tie.buff_silence(1)
	tie.buff_text("(If you know what I'm saying)", .01)
	tie.buff_silence(1.5)
	tie.set_state(tie.STATE_OUTPUT)

func window_two():
	tie.reset()
	tie.buff_text("These sexually confident bois had done the unimaginable.\n", .1)
	tie.connect("buff_end", self, "window_three")
	tie.buff_silence(1)
	tie.buff_text("They had succeeded in finding the power of true friendship.\nAnd with it,", .05)
	tie.buff_silence(1)
	tie.buff_text(" each and every one of them became capable of tremendous strength.\n", .05)
	tie.buff_silence(1)
	tie.buff_text("But,", ".1")
	tie.buff_silence(1)
	tie.buff_text(" as Kayne once said", .1)
	tie.buff_silence(1)
	tie.buff_text("'No one man should have all that power'", .1)
	tie.buff_silence(1)
	tie.buff_text("For the time being they haven't done anything with it. They mostly are concerned with themselves, not worrying about	about anything beyond their basement", .05)
	tie.buff_silence(1.5)
	tie.set_state(tie.STATE_OUTPUT)

func window_three():
	pass

