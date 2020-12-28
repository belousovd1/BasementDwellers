extends Control


# Declare member variables here. Examples:
# var a = 2
onready var tie = $"Panel/TextInterfaceEngine"


# Called when the node enters the scene tree for the first time.
func _ready():
	window_one()


func window_one():
	tie.reset()
	tie.connect("buff_end", self, "window_two")
	tie.buff_text("Far away,", .1)
	tie.buff_silence(1)
	tie.buff_text(" in the middle of bufu Egypt.\n", .1)
	tie.buff_silence(1)
	tie.buff_text("Deep within a suburban basement,", .05)
	tie.buff_silence(1)
	tie.buff_text(" dwelled a special set of hooligans.\n", .05) 
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
	tie.disconnect("buff_end", self, "window_two")
	tie.connect("buff_end", self, "window_three")
	tie.buff_text("These sexually confident Bois had done the unimaginable.\n", .05)
	tie.buff_silence(2)
	tie.buff_text("They had succeeded in finding the power of true friendship.\n", .05)
	tie.buff_silence(1)
	tie.buff_text("And with it,", .05)
	tie.buff_silence(1)
	tie.buff_text(" each and every one of them became capable of tremendous strength.\n", .05)
	tie.buff_silence(1)
	tie.buff_text("But,", .4)
	tie.buff_silence(1)
	tie.buff_text(" as Kanye once said,", .05)
	tie.buff_silence(1)
	tie.buff_text(" 'No one man should have all that power'.\n", .05)
	tie.buff_silence(2)
	tie.set_state(tie.STATE_OUTPUT)

func window_three():
	tie.reset()
	tie.disconnect("buff_end", self, "window_three")
	tie.connect("buff_end", self, "window_four")
	tie.buff_text("At first", .05)
	tie.buff_silence(1)
	tie.buff_text(" nothing changed after achieving this power.\n", .05)
	tie.buff_silence(.5)
	tie.buff_text("They were mostly concerned with themselves,", .05)
	tie.buff_silence(.5)
	tie.buff_text(" not worrying about anything beyond their basement.", .05)
	tie.buff_silence(1.5)
	tie.set_state(tie.STATE_OUTPUT)

func window_four():
	tie.reset()
	tie.disconnect("buff_end", self, "window_four")
	tie.connect("buff_end", self, "window_five")
	tie.buff_text("However,", .01)
	tie.buff_silence(1)
	tie.buff_text(" news of their accomplishment spread far and wide.\n", .05)
	tie.buff_silence(1)
	tie.buff_text("It did not take long for visitors to come from all corners of the globe.\n", .05)
	tie.buff_silence(1)
	tie.buff_text("Courageous warriors came seeking to test their might against it.\n", .05)
	tie.buff_silence(1)
	tie.buff_text("Learned scholars traveled to record, and study it.\n", .05)
	tie.buff_silence(1)
	tie.buff_text("Cunning thieves navigated to the basement in hopes of stealing it.\n", .05)
	tie.buff_silence(2)
	tie.set_state(tie.STATE_OUTPUT)

func window_five():
	tie.reset()
	tie.disconnect("buff_end", self, "window_five")
	tie.connect("buff_end", self, "window_six")
	tie.buff_text("The friends quickly grew frustrated from all the toxicity that followed.\n", .05)
	tie.buff_silence(1)
	tie.buff_text("They then came to an agreement,", .05)
	tie.buff_silence(1)
	tie.buff_text(" holding hands they recited a pledge to one another, \n", .05)
	tie.buff_silence(1)
	tie.buff_text("'we're done playing League of Legends'.\n", .01)
	tie.buff_silence(2)
	tie.buff_text("And while they were at it, they also decided to cut themselves off from the rest of the world.", .05)
	tie.buff_silence(2)
	tie.set_state(tie.STATE_OUTPUT)

func window_six():
	tie.reset()
	tie.disconnect("buff_end", self, "window_six")
	tie.connect("buff_end", self, "window_seven")
	tie.buff_text("A potential catastrophe looms over all of us in that basement.\n", .05)
	tie.buff_silence(2)
	tie.buff_text("On any given day these giants could wake from their slumber", .05)
	tie.buff_silence(1)
	tie.buff_text(" and decide to flatten this world.", .05)
	tie.buff_silence(2)
	tie.set_state(tie.STATE_OUTPUT)

func window_seven():
	tie.reset()
	tie.disconnect("buff_end", self, "window_seven")
	tie.connect("buff_end", self, "next_fnc")
	tie.buff_text("You must vanquish these soon to be horsemen of the apocalypse.\n", .05)
	tie.buff_silence(2)
	tie.buff_text("Remove this threat once and for all,", .05)
	tie.buff_silence(1)
	tie.buff_text(" to finally put an end to these so called.....", .05)
	tie.buff_silence(2)
	tie.set_state(tie.STATE_OUTPUT)

func next_fnc():
	$AudioStreamPlayer.stop()
	print("done")
			
		


