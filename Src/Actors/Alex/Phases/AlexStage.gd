class_name AlexStage
extends ArenaStage
## One of Alex's stages, with helpers that spawn his attacks in arena space.
## His rounds keep time: wait in beats with [method beats].

const MusicNoteScene := preload("res://Src/Actors/Alex/Attacks/MusicNote.tscn")
const StaffScene := preload("res://Src/Actors/Alex/Attacks/Staff.tscn")
const NoteGemScene := preload("res://Src/Actors/Alex/Attacks/NoteGem.tscn")
const EqualizerScene := preload("res://Src/Actors/Alex/Attacks/Equalizer.tscn")
const VinylScene := preload("res://Src/Actors/Alex/Attacks/Vinyl.tscn")
const SpaceBubbleScene := preload("res://Src/Actors/Alex/Attacks/SpaceBubble.tscn")
## The tempo, in beats per minute.
const BPM := 120.0
## The note highway's lanes across the arena.
const LANES := 5
## Where bars of notes start on the staff, right of the arena, and the gap
## between the notes in a bar, in pixels.
const STAFF_START := 400.0
const BAR_SPACING := 110.0
const VINYL_LABELS: Array[Color] = [Color("e8417a"), Color("f7d13c"), Color("5fcde4")]


## Waits [param count] beats.
func beats(count: float) -> void:
	await wait(count * 60.0 / BPM)


## A music note flying from [param at] along [param direction], weaving
## [param wobble] pixels either side of its path.
func spawn_note(at: Vector2, direction: Vector2, speed := 260.0, wobble := 0.0, beamed := false,
		color := Color.WHITE) -> void:
	var note := MusicNoteScene.instantiate()
	note.position = at
	note.direction = direction
	note.speed = speed
	note.wobble = wobble
	note.beamed = beamed
	note.color = color
	arena.add_child(note)


## Sight-reading: the staff appears, and after [param warn_beats] beats a bar
## of [param count] notes slides in from the right along each line in
## [param lines] (indices into the staff's lines, 0 at the top). The spaces
## between the lines are safe.
func play_staff(lines: Array, count := 6, warn_beats := 2.0, speed := 320.0) -> void:
	var staff := StaffScene.instantiate()
	var bar_seconds := (STAFF_START * 2 + count * BAR_SPACING) / speed
	staff.duration = warn_beats * 60.0 / BPM + bar_seconds
	arena.add_child(staff)
	await beats(warn_beats)
	for line in lines:
		for i in count:
			var y: float = staff.LINES[line]
			spawn_note(Vector2(STAFF_START + i * BAR_SPACING, y), Vector2.LEFT, speed, 0.0, i % 2 == 1)


## A gem dropping down lane [param lane] of the note highway (0 on the left).
func spawn_gem(lane: int, warn_time := 0.8, speed := 750.0) -> void:
	var gem := NoteGemScene.instantiate()
	var lane_width := ARENA_HALF_SIZE.x * 2 / LANES
	gem.position = Vector2(-ARENA_HALF_SIZE.x + lane_width * (lane + 0.5), -ARENA_HALF_SIZE.y - 60)
	gem.lane = lane
	gem.lane_width = lane_width - 8
	gem.warn_time = warn_time
	gem.speed = speed
	arena.add_child(gem)


## Gems in several lanes at once.
func spawn_chord(lanes: Array, warn_time := 0.8, speed := 750.0) -> void:
	for lane in lanes:
		spawn_gem(lane, warn_time, speed)


## The equalizer on the arena floor, jumping through [param steps] (one height
## per bar for each step), [param beats_per_step] beats apart.
func spawn_equalizer(steps: Array[PackedFloat32Array], beats_per_step := 2.0) -> void:
	var meter := EqualizerScene.instantiate()
	meter.position = Vector2(0, ARENA_HALF_SIZE.y)
	meter.width = ARENA_HALF_SIZE.x * 2
	meter.max_height = ARENA_HALF_SIZE.y * 2
	meter.steps = steps
	meter.step_time = beats_per_step * 60.0 / BPM
	arena.add_child(meter)


## Random equalizer heights for [param count] steps of [param bars] bars. Every
## step keeps the top of the arena clear, and leaves at least one bar low.
func random_equalizer(rng: RandomNumberGenerator, count: int, bars := 8, highest := 0.75) -> Array[PackedFloat32Array]:
	var steps: Array[PackedFloat32Array] = []
	for _step in count:
		var heights := PackedFloat32Array()
		for _bar in bars:
			heights.append(rng.randf_range(0.1, highest))
		heights[rng.randi_range(0, bars - 1)] = 0.08
		steps.append(heights)
	return steps


## A record that appears at [param at] and starts bouncing along [param direction].
func spawn_vinyl(at: Vector2, direction: Vector2, speed := 230.0) -> Bouncer:
	var record: Bouncer = VinylScene.instantiate()
	record.position = at
	record.direction = direction
	record.speed = speed
	record.label_color = VINYL_LABELS.pick_random()
	record.bounds = Rect2(-ARENA_HALF_SIZE, ARENA_HALF_SIZE * 2)
	arena.add_child(record)
	return record


## The giant bubble, rolling across the arena at height [param y] from the left
## or from the right.
func spawn_bubble(y: float, from_left: bool, speed := 140.0) -> void:
	var bubble := SpaceBubbleScene.instantiate()
	var side := -1 if from_left else 1
	bubble.position = Vector2(side * (ARENA_HALF_SIZE.x + 140), y)
	bubble.direction = Vector2(-side, 0)
	bubble.speed = speed
	arena.add_child(bubble)
