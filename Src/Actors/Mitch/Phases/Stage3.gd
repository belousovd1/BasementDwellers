extends BossStage
## Stage 3: Malocchio circles the arena firing its laser while paintbrushes
## close in from the sides or from the corners.

const MalocchioScene := preload("res://Src/Actors/Mitch/Malocchio.tscn")
const MalocchioPathScene := preload("res://Src/Actors/Mitch/MalocchioPath.tscn")
const SPEED := 400.0
const SIZE := Vector2(0.8, 0.8)
## At or below this health, Malocchio fires faster.
const ENRAGE_HEALTH := 50

var rng := RandomNumberGenerator.new()
var _malocchio_path: Node2D


func start() -> void:
	rng.randomize()
	var summoned := MalocchioScene.instantiate()
	add_child(summoned)
	# The summon animation frees this Malocchio when it ends.
	summoned.tree_exiting.connect(_on_summon_finished, CONNECT_DEFERRED)
	summoned.summon()


func resume() -> void:
	for _volley in 9:
		if rng.randf_range(-1.0, 1.0) > 0:
			_square_volley()
		else:
			_diagonal_volley()
		await wait(2)
	attacks_finished.emit()


func on_player_turn_started() -> void:
	_malocchio_path.stop_firing()


func on_player_turn_ended(boss_health: int) -> void:
	# The laser only restarts once Mitch is badly hurt; above that it stays
	# stopped for the rest of the stage, as in the original game.
	if boss_health <= ENRAGE_HEALTH:
		_malocchio_path.rapid_fire()
		_malocchio_path.start_firing()


func _on_summon_finished() -> void:
	_malocchio_path = MalocchioPathScene.instantiate()
	add_child(_malocchio_path)
	await wait(2)
	resume()


## Four paintbrushes closing in from above, below, left and right.
func _square_volley() -> void:
	spawn_boomerang(Vector2(0, -216), Vector2.DOWN, SPEED, SIZE)
	spawn_boomerang(Vector2(0, 584), Vector2.UP, SPEED, SIZE)
	spawn_boomerang(Vector2(400, 264), Vector2.LEFT, SPEED, SIZE)
	spawn_boomerang(Vector2(-400, 264), Vector2.RIGHT, SPEED, SIZE)


## Four paintbrushes closing in from the corners.
func _diagonal_volley() -> void:
	spawn_boomerang(Vector2(298, 14), Vector2(-1.2, 1), SPEED, SIZE)
	spawn_boomerang(Vector2(-282, 14), Vector2(1.2, 1), SPEED, SIZE)
	spawn_boomerang(Vector2(-282, 514), Vector2(1.2, -1), SPEED, SIZE)
	spawn_boomerang(Vector2(298, 514), Vector2(-1.2, -1), SPEED, SIZE)
