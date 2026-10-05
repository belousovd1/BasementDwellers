extends Projectile
## Gerald: Gabe's first car, an old Subaru Forester, summoned for his final
## stage, and out to get the player.
##
## He has two views: side on while he drives, wheels spinning, and head on,
## facing out of the screen. He rises out of a summoning circle head on with
## his headlights off, then they blaze on. He swings round to face the player
## whenever he turns, and before every charge he faces them, flashing his high
## beams, shaking and steaming. He charges twice in a row, re-aiming in
## between, then cruises off before hunting again. Every other time, instead of
## charging, he does a burnout, his wheels spinning in a cloud of smoke while a
## line of tyre tracks shows his path, then drifts in a sweeping arc through
## the middle of the arena, leaving skid marks behind. He roams the whole
## screen, not just the arena. Lives in arena space, whose origin is the middle
## of the arena.

enum State { SUMMON, CHASE, REV, CHARGE, CRUISE, LEAVE, BURNOUT, DRIFT }

## Side on, facing right. The wheels are drawn over the arches in code.
const SIDE: Array[String] = [
	"         ########                 ",
	"        #lllLllll#                ",
	"       ##lllLllll#########        ",
	"      #RRRRRRRRRRRRRRRRRRR#       ",
	"      #ggggggggggggggggggg#       ",
	"      #wwwwwgwwwwwwgwxwwww#       ",
	"      #wwwwwgwwwwwwgwwxxwww#####  ",
	"   ####wwwwwgwwwwwwgwwwwxwwgEEEE# ",
	"  #tgggggrggdppppppdggggggggEEEE# ",
	"  #tggrgggggdppppppdgggggrggEEEE# ",
	"  #ggrggggggdppppppdgggggggggGGG# ",
	"  #ggg......ggggggg......gcccccc# ",
	"  #ccc......ccccccc......ccccccc# ",
	"   #############################  ",
	"                                  ",
	"                                  ",
]
## Staring out of the screen.
const FRONT: Array[String] = [
	"        #llllllllll#        ",
	"      ###llllllllll###      ",
	"     #RRRRRRRRRRRRRRRR#     ",
	"     #gggggggggggggggg#     ",
	"     #wwwwwwwwwxwwwwww#     ",
	" ## #wwwwwwwwwwwxwwwwww# ## ",
	"#gg##wwwwwwwwwwxwxwwwww##gg#",
	"#gg#wwwwwwwwwwwwwwxwwwww#gg#",
	" #gggggggggggggggggggggggg# ",
	" #ggEEEEEEgggbbgggEEEEEEgg# ",
	" #ggEEEEEEggggggggEEEEEEgg# ",
	" #ggEEEEEEGGGGGGGGEEEEEEgg# ",
	" #ggggggggRRRRRRRRggggggrg# ",
	" #grggggggGGGGGGGGggggrggg# ",
	" #cccccccccccccccccccccccc# ",
	"  #kkkk##############kkkk#  ",
	"  #kkkk#            #kkkk#  ",
	"  #kkkk#            #kkkk#  ",
	"   ####              ####   ",
]
## Where his wheels and headlights are, in art pixels from the top-left corner
## of their picture.
const SIDE_WHEELS: Array[Vector2] = [Vector2(9, 13), Vector2(22, 13)]
const FRONT_HEADLIGHTS: Array[Rect2i] = [Rect2i(4, 9, 6, 3), Rect2i(18, 9, 6, 3)]
const WHEEL_RADIUS := 2.6

## The colours of the pictures: # outline, g paint, p the grey primer door,
## w windows, x the cracks in them, E headlights, G grille, t tail light,
## r rust, c cladding, . wheel arches, k tyres, l the luggage box on the roof
## and L its strap, R the roof rack, d door seams and b the badge.
const PALETTE := {
	"#": Color.WHITE, "g": Color("3f7a62"), "p": Color("8f97a6"), "w": Color("6e788c"),
	"x": Color("e6ebf5"), "E": Color("fff096"), "G": Color("2a2a32"), "t": Color("ff3c3c"),
	"r": Color("965028"), "c": Color("6e6e78"), ".": Color.BLACK, "k": Color("141418"),
	"l": Color("8c5a32"), "L": Color("3c2819"), "R": Color("aaaab4"), "d": Color("1e3c2d"),
	"b": Color("bec8d7"),
}
const TYRE := Color("141418")
const HUBCAP := Color("aaaab4")
const HUB_SHADOW := Color("6e6e78")
const HEADLIGHTS_OFF := Color("3a3a2a")
const HIGH_BEAM := Color(1.0, 0.97, 0.75, 0.3)
const SUMMON_GLOW := Color("7dff9a")
const STEAM := Color(0.85, 0.88, 0.92)
const EXHAUST := Color(0.6, 0.6, 0.66)
const BACKFIRE := Color("ff9a2a")

## How far inside [member bounds] he keeps his middle: about half his size.
const MARGIN := Vector2(140, 70)
## The summoning: the circle opening, him rising out of it, then revving.
const OPEN_TIME := 0.5
const RISE_TIME := 0.8
const GLARE_TIME := 0.6
## Seconds he revs before a charge, how fast he charges, and how many more
## charges follow each one before he cruises off.
const REV_TIME := 0.6
const CHARGE_SPEED := 1100.0
const FOLLOW_UP_CHARGES := 1
## How much faster than his chase he cruises, how far away a cruise takes him
## at least, and how close to its end counts as there.
const CRUISE_BOOST := 1.6
const CRUISE_REACH := 380.0
const CRUISE_ARRIVED := 90.0
## The longest a cruise lasts, in seconds.
const CRUISE_TIME := 1.6
## Seconds he spends head on when he swings round.
const TURN_TIME := 0.2
const PUFF_LIFE := 0.5
## The drift: how long the burnout warns for, how fast he slides, how far from
## the middle of the arena he has to be to drift through it, and how much the
## arc bends.
const BURNOUT_TIME := 0.75
const DRIFT_SPEED := 950.0
const DRIFT_MIN_DISTANCE := 380.0
const DRIFT_BEND := 0.55
const SMOKE := Color(0.75, 0.75, 0.8)
const SKID := Color(0.25, 0.25, 0.3)
const TRACK := Color("ff9a2a")
const SKID_LIFE := 2.0

## How fast he drives while chasing, and how quickly he can change direction.
@export var speed := 380.0
@export var grip := 560.0
## Seconds of chasing between charges.
@export var charge_every := 2.2
## Where he can drive, in his parent's coordinates: the whole screen.
@export var bounds := Rect2(-960, -800, 1920, 1080)
## How many screen pixels each of his art pixels covers, as a multiple of
## [constant PixelArt.SIZE].
@export var art_scale := 2.0

var _state := State.SUMMON
var _velocity := Vector2.ZERO
var _facing := 1
var _clock := 0.0
var _time := 0.0
var _turning := 0.0
var _wheel_turn := 0.0
var _charge_direction := Vector2.ZERO
var _cruise_to := Vector2.ZERO
var _puffs: Array[Dictionary] = []
var _roared := false
var _drift_next := false
var _follow_ups := 0
var _drift_pending := false
var _drift_center := Vector2.ZERO
var _drift_radius := 0.0
var _drift_from := 0.0
var _drift_sweep := 0.0
var _drift_time := 0.0
var _skids: Array[Dictionary] = []

@onready var _hitbox: CollisionShape2D = $CollisionShape2D
@onready var _honk: AudioStreamPlayer = $Honk
@onready var _summon_sound: AudioStreamPlayer = $SummonSound
@onready var _roar: AudioStreamPlayer = $Roar
@onready var _screech: AudioStreamPlayer = $Screech


func _ready() -> void:
	scale = Vector2.ONE * art_scale
	_hitbox.disabled = true
	_summon_sound.play()


## Drives off the nearest side of the screen and frees himself, for when the
## player takes their turn.
func leave() -> void:
	_hitbox.disabled = true
	_switch(State.LEAVE)


func _process(delta: float) -> void:
	_time += delta
	_clock += delta
	_turning = maxf(_turning - delta, 0.0)
	match _state:
		State.SUMMON:
			if _clock >= OPEN_TIME + RISE_TIME and not _roared:
				_roared = true
				_roar.play()
			if _clock >= OPEN_TIME + RISE_TIME + GLARE_TIME:
				_hitbox.disabled = false
				_switch(State.CHASE)
		State.CHASE:
			_steer_to(_player_position(), speed, delta)
			if _clock >= charge_every:
				# He takes turns: a charge, then a drift, for which he first
				# drives out to somewhere well away from the arena.
				_drift_next = not _drift_next
				if _drift_next:
					_drift_pending = true
					_cruise_to = _drift_start()
					_switch(State.CRUISE)
				else:
					_follow_ups = FOLLOW_UP_CHARGES
					_switch(State.REV)
		State.BURNOUT:
			# Handbrake on: he stays where his drift starts, wheels spinning.
			_velocity = Vector2.ZERO
			_wheel_turn += 30.0 * _facing * delta
			if fmod(_clock, 0.06) < delta:
				_puff(_rear_wheel(), SMOKE, Vector2(-_facing * randf_range(40, 120), randf_range(-60, -20)), 3)
			if _clock >= BURNOUT_TIME:
				_screech.play()
				_switch(State.DRIFT)
		State.DRIFT:
			var angle := _drift_from + _drift_sweep * minf(_clock / _drift_time, 1.0)
			var was := position
			position = _drift_center + Vector2.from_angle(angle) * _drift_radius
			_velocity = (position - was) / delta
			_leave_skids()
			if fmod(_clock, 0.05) < delta:
				_puff(_rear_wheel(), SMOKE, Vector2(randf_range(-40, 40), randf_range(-60, -20)), 3)
			if _clock >= _drift_time:
				_cruise_to = _far_point()
				_switch(State.CRUISE)
		State.REV:
			_velocity = _velocity.move_toward(Vector2.ZERO, grip * 3 * delta)
			_drive(delta)
			_charge_direction = (_player_position() - position).normalized()
			if fmod(_clock, 0.12) < delta:
				_puff(_hood(), STEAM, Vector2(randf_range(-40, 40), -90))
			if _clock >= REV_TIME:
				_honk.play()
				if absf(_charge_direction.x) > 0.1:
					_facing = 1 if _charge_direction.x > 0 else -1
				_velocity = _charge_direction * CHARGE_SPEED
				_switch(State.CHARGE)
		State.CHARGE:
			if fmod(_clock, 0.1) < delta:
				_puff(_tailpipe(), BACKFIRE, Vector2(-_facing * 60, -20))
			if _drive(delta) or _clock > 3.0:
				# Reached the edge: bounce off a little, then charge again or
				# cruise off somewhere.
				_velocity *= -0.25
				if _follow_ups > 0:
					_follow_ups -= 1
					_switch(State.REV)
				else:
					_cruise_to = _far_point()
					_switch(State.CRUISE)
		State.CRUISE:
			_steer_to(_cruise_to, speed * CRUISE_BOOST, delta)
			if position.distance_to(_cruise_to) < CRUISE_ARRIVED or _clock > CRUISE_TIME:
				if _drift_pending and _plan_drift():
					_screech.play()
					_switch(State.BURNOUT)
				else:
					_switch(State.CHASE)
				_drift_pending = false
		State.LEAVE:
			var exit_x := bounds.position.x - 400 if position.x < bounds.get_center().x else bounds.end.x + 400
			_velocity = _velocity.move_toward(Vector2(signf(exit_x - position.x) * speed * 2, 0), grip * 2 * delta)
			position += _velocity * delta
			if absf(position.x - exit_x) < 100:
				queue_free()
				return
	# Swing round to face the player whenever he changes direction.
	# Not while drifting, though: he slides sideways, still facing the same way.
	var steady := _state in [State.REV, State.SUMMON, State.BURNOUT, State.DRIFT]
	if not steady and absf(_velocity.x) > 40:
		var heading := 1 if _velocity.x > 0 else -1
		if heading != _facing:
			_facing = heading
			_turning = TURN_TIME
	_wheel_turn += _velocity.x / (WHEEL_RADIUS * PixelArt.SIZE * scale.x) * delta
	var moving := _state == State.CHASE or _state == State.CRUISE or _state == State.LEAVE
	if moving and _velocity.length() > 60 and fmod(_time, 0.25) < delta:
		_puff(_tailpipe(), EXHAUST, Vector2(-_facing * 30, -30))
	for puff in _puffs:
		puff.age += delta
		puff.at += puff.drift * delta
	_puffs = _puffs.filter(func(p: Dictionary) -> bool: return p.age < PUFF_LIFE)
	for skid in _skids:
		skid.age += delta
	_skids = _skids.filter(func(k: Dictionary) -> bool: return k.age < SKID_LIFE)
	var head_on := _head_on()
	(_hitbox.shape as RectangleShape2D).size = PixelArt.bitmap_size(FRONT if head_on else SIDE) \
			- Vector2(24, 28 if head_on else 40)
	queue_redraw()


func _steer_to(target: Vector2, top_speed: float, delta: float) -> void:
	var desired := (target - position).normalized() * top_speed
	_velocity = _velocity.move_toward(desired, grip * delta)
	_drive(delta)


## Moves him along, kept inside [member bounds]. Returns whether he hit an
## edge.
func _drive(delta: float) -> bool:
	position += _velocity * delta
	var inner := _inner_bounds()
	var kept := position.clamp(inner.position, inner.end)
	var hit := not kept.is_equal_approx(position)
	if kept.x != position.x:
		_velocity.x = 0
	if kept.y != position.y:
		_velocity.y = 0
	position = kept
	return hit


## Plans a drift from where he is, in an arc through the middle of the arena
## and out the other side, staying on the screen. Returns false if he's too
## close to the middle to drift through it.
func _plan_drift() -> bool:
	var from := position
	var distance := from.length()
	if distance < DRIFT_MIN_DISTANCE:
		return false
	# The arc's centre is off to one side of the line from him to the middle.
	var side := 1.0 if randf() < 0.5 else -1.0
	_drift_center = from / 2 + (-from).orthogonal().normalized() * distance * DRIFT_BEND * side
	_drift_radius = from.distance_to(_drift_center)
	_drift_from = (from - _drift_center).angle()
	var through := wrapf((-_drift_center).angle() - _drift_from, -PI, PI)
	# Through the middle and as far again, or less if that would leave the screen.
	_drift_sweep = through * 2
	var inner := _inner_bounds()
	while absf(_drift_sweep) > absf(through) * 1.2 \
			and not inner.has_point(_drift_center + Vector2.from_angle(_drift_from + _drift_sweep) * _drift_radius):
		_drift_sweep *= 0.92
	_drift_time = absf(_drift_sweep) * _drift_radius / DRIFT_SPEED
	var heading := Vector2.from_angle(_drift_from + PI / 2 * signf(_drift_sweep))
	if absf(heading.x) > 0.1:
		_facing = 1 if heading.x > 0 else -1
	return true


## Somewhere on the screen far enough from the middle of the arena to drift
## through it from.
func _drift_start() -> Vector2:
	var inner := _inner_bounds()
	for _try in 16:
		var point := Vector2.from_angle(randf() * TAU) * (DRIFT_MIN_DISTANCE + 160)
		if inner.has_point(point):
			return point
	return _far_point()


## Marks the ground under his wheels as he slides.
func _leave_skids() -> void:
	var size := PixelArt.bitmap_size(SIDE)
	for along in [-0.3, 0.3]:
		_skids.append({"at": position + Vector2(size.x * along, size.y * 0.3) * scale, "age": 0.0})


func _rear_wheel() -> Vector2:
	var size := PixelArt.bitmap_size(SIDE)
	return position + Vector2(-_facing * size.x * 0.3, size.y * 0.35) * scale


func _switch(state: State) -> void:
	_state = state
	_clock = 0.0


## Whether he's drawn head on, staring out of the screen.
func _head_on() -> bool:
	return _state == State.SUMMON or _state == State.REV or _turning > 0.0


## A point somewhere on the screen, well away from where he is now.
func _far_point() -> Vector2:
	var inner := _inner_bounds()
	var point := position
	for _try in 12:
		point = inner.position + Vector2(randf(), randf()) * inner.size
		if point.distance_to(position) >= CRUISE_REACH:
			break
	return point


func _inner_bounds() -> Rect2:
	return bounds.grow_individual(-MARGIN.x, -MARGIN.y, -MARGIN.x, -MARGIN.y)


func _player_position() -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	return get_parent().to_local(player.global_position) if player else position


## Where his exhaust pipe and his hood are, in his parent's coordinates.
func _tailpipe() -> Vector2:
	var size := PixelArt.bitmap_size(SIDE)
	return position + Vector2(-_facing * size.x * 0.45, size.y * 0.25) * scale


func _hood() -> Vector2:
	return position + Vector2(randf_range(-60, 60), -10) * scale


## A puff of [param color] at [param at] drifting along [param drift], starting
## [param size] art pixels across and growing as it fades.
func _puff(at: Vector2, color: Color, drift: Vector2, size := 1) -> void:
	_puffs.append({"at": at, "age": 0.0, "color": color, "drift": drift, "size": size})


func _draw() -> void:
	for skid in _skids:
		var fade: float = 1.0 - skid.age / SKID_LIFE
		PixelArt.dot(self, (skid.at - position) / scale, Color(SKID, fade), 2)
	if _state == State.BURNOUT and fmod(_clock, 0.2) < 0.13:
		_draw_drift_path()
	for puff in _puffs:
		var fade: float = 1.0 - puff.age / PUFF_LIFE
		var grow: int = puff.size + int(puff.age / PUFF_LIFE * 2)
		PixelArt.dot(self, (puff.at - position) / scale, Color(puff.color, fade), grow)
	if _state == State.CHARGE:
		_draw_speed_lines()
	if _head_on():
		_draw_front()
	else:
		_draw_side()


func _draw_side() -> void:
	var size := PixelArt.bitmap_size(SIDE)
	var corner := -size / 2
	var flip := _facing < 0
	var wheels_at := corner
	# His body bobs on his wheels as he drives; the wheels stay on the road.
	if _velocity.length() > 60 and fmod(_time, 0.2) < 0.1:
		corner.y -= PixelArt.SIZE
	_bitmap(SIDE, corner, flip)
	for wheel in SIDE_WHEELS:
		_draw_wheel(wheels_at + _flip_point(wheel, SIDE, flip) * PixelArt.SIZE)


func _draw_front() -> void:
	var size := PixelArt.bitmap_size(FRONT)
	var corner := -size / 2
	var clip := INF
	if _state == State.SUMMON:
		_draw_summon_circle(size)
		# Rising out of the circle: only what's above the ground shows.
		var rise := clampf((_clock - OPEN_TIME) / RISE_TIME, 0.0, 1.0)
		corner.y += (1.0 - ease(rise, 0.5)) * size.y
		clip = size.y / 2
	var raging := _state == State.REV or (_state == State.SUMMON and _roared)
	if raging:
		corner += Vector2(randi_range(-1, 1), randi_range(-1, 0)) * PixelArt.SIZE
	_bitmap(FRONT, corner, false, clip)
	# His headlights: off until he's risen, then flashing his high beams while
	# he revs.
	var lights_on := _roared or _state != State.SUMMON
	var high_beams := raging and fmod(_time, 0.16) < 0.08
	for light in FRONT_HEADLIGHTS:
		if not lights_on:
			_fill_cells(light, HEADLIGHTS_OFF, corner, FRONT, false, clip)
		elif high_beams:
			var glow := Rect2(corner + Vector2(light.position - Vector2i.ONE) * PixelArt.SIZE,
					Vector2(light.size + Vector2i(2, 2)) * PixelArt.SIZE)
			draw_rect(glow, HIGH_BEAM)
			_fill_cells(light, PixelArt.WHITE, corner, FRONT, false, clip)


## A tyre with a hubcap and spokes turning as he rolls.
func _draw_wheel(centre: Vector2) -> void:
	var radius := ceili(WHEEL_RADIUS)
	for y in range(-radius, radius):
		for x in range(-radius, radius):
			var cell := Vector2(x, y) + Vector2(0.5, 0.5)
			var distance := cell.length()
			if distance > WHEEL_RADIUS:
				continue
			var color := TYRE
			if distance > WHEEL_RADIUS - 0.7:
				color = PixelArt.WHITE
			elif distance < 1.4:
				var spoke := fposmod((cell.angle() - _wheel_turn) / TAU * 3, 1.0) < 0.5
				color = HUBCAP if spoke or distance < 0.6 else HUB_SHADOW
			PixelArt.dot(self, centre + cell * PixelArt.SIZE, color)


## The glowing circle he rises out of, with runes running round it.
func _draw_summon_circle(size: Vector2) -> void:
	var open := clampf(_clock / OPEN_TIME, 0.0, 1.0)
	var fade := 1.0 - clampf((_clock - OPEN_TIME - RISE_TIME) / GLARE_TIME, 0.0, 1.0)
	var radius := Vector2(size.x * 0.6, size.y * 0.16) * ease(open, 0.4)
	if radius.x < 1:
		return
	var ground := Vector2(0, size.y / 2)
	var glow := PackedVector2Array()
	for i in 24:
		var angle := TAU * i / 24
		glow.append(ground + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(glow, Color(SUMMON_GLOW, 0.2 * fade))
	for i in 40:
		var angle := TAU * i / 40 + _time
		var rune := i % 5 == 0
		PixelArt.dot(self, ground + Vector2(cos(angle), sin(angle)) * radius,
				Color(PixelArt.WHITE if rune else SUMMON_GLOW, fade), 2 if rune else 1)


## The tyre tracks he's about to lay down: his drift's arc, dashed.
func _draw_drift_path() -> void:
	var steps := 48
	for i in steps:
		if i % 3 == 2:
			continue
		var angle := _drift_from + _drift_sweep * i / steps
		var at := _drift_center + Vector2.from_angle(angle) * _drift_radius
		PixelArt.dot(self, (at - position) / scale, TRACK, 2)


## Lines streaming off behind him while he charges.
func _draw_speed_lines() -> void:
	var size := PixelArt.bitmap_size(SIDE)
	for i in 5:
		var y := (i - 2) * size.y * 0.18
		var length := size.x * (0.4 + 0.3 * fposmod(_time * 7 + i * 0.37, 1.0))
		var from := Vector2(-_facing * size.x * 0.55, y)
		PixelArt.line(self, from, from - Vector2(_facing * length, 0), Color(PixelArt.WHITE, 0.6))


## Draws [param shape] with [param corner] at its top-left, mirrored with
## [param flip], leaving out any rows that start at or below [param clip].
func _bitmap(shape: Array[String], corner: Vector2, flip: bool, clip := INF) -> void:
	var width := shape[0].length()
	for y in shape.size():
		if corner.y + y * PixelArt.SIZE >= clip:
			return
		var row := shape[y]
		for x in row.length():
			if PALETTE.has(row[x]):
				var column := width - 1 - x if flip else x
				draw_rect(Rect2(corner + Vector2(column, y) * PixelArt.SIZE, Vector2.ONE * PixelArt.SIZE),
						PALETTE[row[x]])


## Fills [param cells] of [param shape] with [param color], following its flip
## and clip.
func _fill_cells(cells: Rect2i, color: Color, corner: Vector2, shape: Array[String], flip: bool,
		clip := INF) -> void:
	var width := shape[0].length()
	for y in range(cells.position.y, cells.end.y):
		if corner.y + y * PixelArt.SIZE >= clip:
			return
		for x in range(cells.position.x, cells.end.x):
			var column := width - 1 - x if flip else x
			draw_rect(Rect2(corner + Vector2(column, y) * PixelArt.SIZE, Vector2.ONE * PixelArt.SIZE), color)


## [param point] in [param shape]'s art pixels, mirrored with [param flip].
func _flip_point(point: Vector2, shape: Array[String], flip: bool) -> Vector2:
	return Vector2(shape[0].length() - point.x, point.y) if flip else point
