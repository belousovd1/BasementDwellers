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
	var _err = get_tree().change_scene("res://Src/Interface/DeathMenu.tscn")


func attack_boss():
	get_tree().call_group("defense", "invisible")
	attack_bar = attack_bar_sc.instance()
	add_child(attack_bar)
	attack_bar.position = Vector2(534, 510)


func attack_finished(_anm_name):
	var damage = attack_bar.get_damage()
	print("damage: ", damage)
	mitch.health = mitch.health - damage
	print("Mitch's Health: ", mitch.health)

	if mitch.health <= 0:
		print('he should be dead')
		get_tree().call_group("defense", "invisible")
		$Mitch/AnimationPlayer.play("idle")
		$AttackBar.queue_free()
		start_dialog(current_stage)

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
		var _err = connect("attack_finished", $Mitch/Stage3, "attack1")

func start_dialog(stage):
	var dialog = dialog_sc.instance()
	if stage == 0:
		dialog.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/IntoStage2Convo.json"
	if stage == 1:
		dialog.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/IntoStage3Convo.json"
	if stage == 2:
		dialog.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/IntroMitch.json"
	add_child(dialog)
	dialog.get_node("DialogueBox").connect("finish", self, "manage_new_stage")

func manage_new_stage():
	current_stage = mitch.change_stage(current_stage)
	stage_connect(current_stage)
	get_tree().call_group("defense", "visible")
	mitch.health = 100
	if current_stage == stages.stage3:
		change_current_track("res://Assets/Sound/OST/Stage3Mitch.ogg")

func change_current_track(file_path):
	var player = $AudioStreamPlayer
	player.stop()
	var new_track = load(file_path)
	player.set_stream(new_track)
	player.play()
