class_name GabeStage
extends ArenaStage
## One of Gabe's stages, with helpers that spawn his attacks in arena space.

const AppleLogoScene := preload("res://Src/Actors/Gabe/Attacks/AppleLogo.tscn")
const BeachBallScene := preload("res://Src/Actors/Gabe/Attacks/BeachBall.tscn")
const CarScene := preload("res://Src/Actors/Gabe/Attacks/Car.tscn")
const TireScene := preload("res://Src/Actors/Gabe/Attacks/Tire.tscn")
const RoadRollerScene := preload("res://Src/Actors/Gabe/Attacks/RoadRoller.tscn")
const FireLineScript := preload("res://Src/Actors/Gabe/Attacks/FireLine.gd")
const WrenchScene := preload("res://Src/Actors/Gabe/Attacks/Wrench.tscn")
const IceCreamCakeScene := preload("res://Src/Actors/Gabe/Attacks/IceCreamCake.tscn")
const GeraldScene := preload("res://Src/Actors/Gabe/Attacks/Gerald.tscn")
## Heights of the traffic lanes across the arena. There's room to stand between
## any two of them.
const LANES: Array[float] = [-170, -85, 0, 85, 170]
const CAR_PAINTS: Array[Color] = [
	Color("e83030"), Color("f7d13c"), Color("2f9bf0"), Color("5ac739"), Color("f5872b"), Color.WHITE,
]
## How far outside the arena walls cars start.
const CAR_START := 480.0


## An Apple logo flying from [param at] along [param direction].
func spawn_apple(at: Vector2, direction: Vector2, speed := 260.0, rainbow := false) -> void:
	var apple := AppleLogoScene.instantiate()
	apple.position = at
	apple.direction = direction
	apple.speed = speed
	apple.rainbow = rainbow
	arena.add_child(apple)


## An apple shot: a line of fire marks its path from [param at] along
## [param direction] for [param warn_time] seconds, then a fast apple rips down
## it. It doesn't wait for the warning, so shots can be fired in quick
## succession with their lines overlapping.
func spawn_apple_shot(at: Vector2, direction: Vector2, warn_time := 0.6, speed := 800.0) -> void:
	var line := FireLineScript.new()
	line.position = at
	line.direction = direction
	line.warn_time = warn_time
	arena.add_child(line)
	await wait(warn_time)
	spawn_apple(at, direction, speed)


## The spinning beach ball, turning around [param at].
func spawn_beach_ball(at := Vector2.ZERO, arms := 1, turn_speed := 1.2, spin_time := 6.0) -> void:
	var ball := BeachBallScene.instantiate()
	ball.position = at
	ball.arms = arms
	ball.turn_speed = turn_speed
	ball.spin_time = spin_time
	arena.add_child(ball)


## A car speeding along lane [param lane] (an index into [constant LANES]),
## from the left or from the right, painted [param paint] or, if that is left
## clear, a random colour.
func spawn_car(lane: int, from_left: bool, warn_time := 0.9, speed := 900.0,
		paint := Color.TRANSPARENT) -> void:
	var car := CarScene.instantiate()
	var side := -1 if from_left else 1
	car.position = Vector2(CAR_START * side, LANES[lane])
	car.heading = -side
	car.warn_time = warn_time
	car.speed = speed
	car.paint = paint if paint.a > 0 else CAR_PAINTS.pick_random()
	arena.add_child(car)


## A tyre that appears at [param at] and starts bouncing along [param direction].
func spawn_tire(at: Vector2, direction: Vector2, speed := 220.0) -> Tire:
	var tire: Tire = TireScene.instantiate()
	tire.position = at
	tire.direction = direction
	tire.speed = speed
	tire.bounds = Rect2(-ARENA_HALF_SIZE, ARENA_HALF_SIZE * 2)
	arena.add_child(tire)
	return tire


## A road roller dropping onto [param at], kept inside the arena.
func spawn_road_roller(at: Vector2, warn_time := 1.0) -> void:
	var roller := RoadRollerScene.instantiate()
	var room := ARENA_HALF_SIZE - Vector2(70, 40)
	roller.position = at.clamp(-room, room)
	roller.warn_time = warn_time
	arena.add_child(roller)


## A wrench thrown end over end from [param at] along [param direction].
func spawn_wrench(at: Vector2, direction: Vector2, speed := 420.0) -> void:
	var wrench := WrenchScene.instantiate()
	wrench.position = at
	wrench.direction = direction
	wrench.speed = speed
	arena.add_child(wrench)


## An ice cream cake against the [param wall] side of the arena (such as
## [constant Vector2.UP]), [param along] pixels from the middle of that wall,
## shooting slices of itself into the arena.
func spawn_ice_cream_cake(wall: Vector2, along := 0.0, spray_time := 3.0) -> void:
	var cake := IceCreamCakeScene.instantiate()
	var across := Vector2(wall.y, wall.x).abs()
	cake.position = wall * ARENA_HALF_SIZE + across * along
	cake.direction = -wall
	cake.spray_time = spray_time
	arena.add_child(cake)


## Gerald, Gabe's first car, rising out of a summoning circle at [param at] to
## hunt the player all over the screen. [param speed] and [param charge_every]
## set how fast he chases and how many seconds pass between his charges.
func spawn_gerald(at: Vector2, speed := 380.0, charge_every := 2.2) -> Node2D:
	var gerald: Node2D = GeraldScene.instantiate()
	gerald.position = at
	gerald.speed = speed
	gerald.charge_every = charge_every
	# The whole screen, in arena space.
	gerald.bounds = Rect2(-ARENA_CENTER, get_viewport_rect().size)
	arena.add_child(gerald)
	return gerald
