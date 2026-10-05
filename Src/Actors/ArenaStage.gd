class_name ArenaStage
extends BossStage
## A stage whose attacks are placed in arena space rather than the boss's own:
## the origin is the middle of the arena, and its inner walls are
## [constant ARENA_HALF_SIZE] away. Attacks are children of [member arena],
## which stays put when the boss moves.

## The middle of the arena on screen, and half its inner size. These match the
## BattleSquare in Main.tscn.
const ARENA_CENTER := Vector2(960, 800)
const ARENA_HALF_SIZE := Vector2(274, 230)

var arena := Node2D.new()


func _ready() -> void:
	arena.top_level = true
	arena.position = ARENA_CENTER
	add_child(arena)
	super()


## Has the boss shout [param line], cutting off whatever it was saying.
func call_out(line: String) -> void:
	(get_parent() as Boss).say(line, true)


## Where the player is, in arena space.
func player_position() -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	return arena.to_local(player.global_position)
