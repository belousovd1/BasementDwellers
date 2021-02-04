extends Node

onready var attack_bar_sc = preload("res://Src/Interface/AttackBar.tscn")
onready var mitch = $Mitch
onready var attack_bar = attack_bar_sc.instance()
enum stages {stage1, stage2, stage3, defeated}   
onready var current_stage = stages.stage1
onready var dialog_sc = preload("res://Src/Interface/DialogueBox.tscn")

signal player_health_change(player_health)
signal attack_finished


func _ready():
	$CurtainColorRect/AnimationPlayer.play("fade_in")
	mitch.intiate_stage1()
	stage_connect(current_stage)

func _on_player_hit(hp):
	$OnHitCamera.make_current()
	$HitTimer.start()
	emit_signal("player_health_change", hp)

func _on_HitTimer_timeout():
	$OnHitCamera.offset.x = 0
	$OnHitCamera.offset.y = 0
	$OnHitCamera.clear_current()

func _on_Player_dead():
	var _err = get_tree().change_scene("res://Src/Interface/Menus/DeathMenu.tscn")


func attack_boss():
	get_tree().call_group("defense", "invisible")
	attack_bar = attack_bar_sc.instance()
	add_child(attack_bar)
	attack_bar.position = Vector2(960, 800)
	if current_stage == stages.stage3: $Mitch/Stage3/MalocchioPath/Timer.stop()

func attack_finished(_anm_name):
	var damage = attack_bar.get_damage()
	print("damage: ", damage)
	mitch.health = mitch.health - damage

	if mitch.health <= 0:
		get_tree().call_group("defense", "invisible")
		$Mitch/AnimationPlayer.play("idle")
		$AttackBar.queue_free()
		start_dialog(current_stage)

	if (stages.stage3 == current_stage) and mitch.health <= 50:
		mitch.set_better_malocchio()
		$AttackBar.queue_free()
		get_tree().call_group("defense", "visible")
		emit_signal("attack_finished")
		$Mitch/AnimationPlayer.play("idle")
		$Mitch/Stage3/MalocchioPath/Timer.stop()

	else:
		$AttackBar.queue_free()
		get_tree().call_group("defense", "visible")
		emit_signal("attack_finished")
		$Mitch/AnimationPlayer.play("idle")


func stage_connect(stage):
	if stage == 0:
		var _err = connect("attack_finished", $Mitch/Stage1, "attack4")
	if stage == 1:
		disconnect("attack_finished", $Mitch/Stage1, "attack4")
		var _err1 = connect("attack_finished", $Mitch/Stage2, "attack1")
	if stage == 2:
		disconnect("attack_finished", $Mitch/Stage2, "attack1")
		var _err = connect("attack_finished", $Mitch/Stage3, "attack2")
	if stage == 3:
		disconnect("attack_finished", $Mitch/Stage3, "attack2")

func start_dialog(stage):
	print(stage)
	var dialog = dialog_sc.instance()
	if stage == 0:
		mitch.set_scale(Vector2(3,3))
		mitch.set_global_position(Vector2(950, 535))
		dialog.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/IntoStage2Convo.json"

	if stage == 1:
		mitch.set_scale(Vector2(3,3))
		mitch.set_global_position(Vector2(950, 535))
		$AudioStreamPlayer.stop()
		dialog.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/IntoStage3Convo.json"

	if stage == 2:
		mitch.set_scale(Vector2(3,3))
		mitch.set_global_position(Vector2(950, 535))
		dialog.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/MitchDeathConvo.json"

	add_child(dialog)
	dialog.get_node("DialogueBox").connect("finish", self, "manage_new_stage")

func manage_new_stage():
	stage_transition()
	yield($CurtainColorRect/AnimationPlayer, "animation_finished") 
	mitch.set_scale(Vector2(1.8,1.8))
	mitch.set_global_position(Vector2(960, 336))
	get_tree().call_group("defense", "visible")
	yield(get_tree().create_timer(2), "timeout")
	current_stage = mitch.change_stage(current_stage)
	stage_connect(current_stage)
	mitch.health = 100
	if current_stage == stages.stage3:
		change_current_track("res://Assets/Sound/OST/Stage3Mitch.ogg")

func stage_transition():
	var player = $CurtainColorRect/AnimationPlayer
	player.connect("animation_finished", self, "fade_in")
	player.play("fade_out")

func change_current_track(file_path):
	var player = $AudioStreamPlayer
	player.stop()
	var new_track = load(file_path)
	player.set_stream(new_track)
	player.play()

func fade_in(_anim_name):
	$CurtainColorRect/AnimationPlayer.play("fade_in")
	$CurtainColorRect/AnimationPlayer.disconnect("animation_finished", self, "fade_in")

