extends Node

@onready var attack_bar_sc = preload("res://Src/Interface/AttackBar.tscn")
@onready var mitch = $Mitch
@onready var attack_bar = attack_bar_sc.instantiate()
enum stages {stage1, stage2, stage3, defeated}   
@onready var current_stage = stages.stage1
@onready var dialog_sc = preload("res://Src/Interface/DialogueBox.tscn")
@onready var death_aniamtoin_sc = preload("res://Assets/Shaders/BodySprites.tscn")

signal player_health_change(player_health)
signal boss_turn_resumed


func _ready():
	$CurtainColorRect/AnimationPlayer.play("fade_in")
	mitch.intiate_stage1()
	stage_connect(current_stage)

func _on_player_hit(hp):
	$OnHitCamera.enabled = true
	$OnHitCamera.make_current()
	$HitTimer.start()
	emit_signal("player_health_change", hp)

func _on_HitTimer_timeout():
	$OnHitCamera.offset.x = 0
	$OnHitCamera.offset.y = 0
	$OnHitCamera.enabled = false

func _on_Player_dead():
	var _err = get_tree().change_scene_to_file("res://Src/Interface/Menus/DeathMenu.tscn")


func attack_boss():
	get_tree().call_group("defense", "invisible")
	attack_bar = attack_bar_sc.instantiate()
	add_child(attack_bar)
	attack_bar.position = Vector2(960, 800)
	if current_stage == stages.stage3:
		$AttackBar/AnimationPlayer.play("stage3run")
	if current_stage == stages.stage3: $Mitch/Stage3/MalocchioPath/Timer.stop()

func attack_finished(_anm_name):
	
	var damage = attack_bar.get_damage()
	mitch.health = mitch.health - damage

	if mitch.health <= 0 and not(current_stage == stages.defeated):
		get_tree().call_group("defense", "invisible")
		$Mitch/AnimationPlayer.play("idle")
		$AttackBar.queue_free()
		$Mitch/AnimationPlayer.disconnect("animation_finished", Callable(self, "attack_finished"))
		start_dialog(current_stage)

	elif (stages.stage3 == current_stage) and (mitch.health > 0 and mitch.health <= 50):
		mitch.set_better_malocchio()
		$AttackBar.queue_free()
		$Mitch/AnimationPlayer.disconnect("animation_finished", Callable(self, "attack_finished"))
		get_tree().call_group("defense", "make_visible")
		emit_signal("boss_turn_resumed")
		$Mitch/AnimationPlayer.play("idle")
		$Mitch/Stage3/MalocchioPath/Timer.start()

	else:
		$AttackBar.queue_free()
		$Mitch/AnimationPlayer.disconnect("animation_finished", Callable(self, "attack_finished"))
		get_tree().call_group("defense", "make_visible")
		emit_signal("boss_turn_resumed")
		$Mitch/AnimationPlayer.play("idle")


func stage_connect(stage):
	if stage == 0:
		var _err = connect("boss_turn_resumed", Callable($Mitch/Stage1, "attack4"))
	if stage == 1:
		disconnect("boss_turn_resumed", Callable($Mitch/Stage1, "attack4"))
		#$Mitch/Stage1.queue_free()
		var _err1 = connect("boss_turn_resumed", Callable($Mitch/Stage2, "attack1"))
	if stage == 2:
		disconnect("boss_turn_resumed", Callable($Mitch/Stage2, "attack1"))
		#$Mitch/Stage2.queue_free()
		var _err = connect("boss_turn_resumed", Callable($Mitch/Stage3, "attack2"))
	if stage == 3:
		disconnect("boss_turn_resumed", Callable($Mitch/Stage3, "attack2"))




func start_dialog(stage):
	var dialog = dialog_sc.instantiate()
	if stage == 0:
		mitch.set_scale(Vector2(3,3))
		mitch.set_global_position(Vector2(950, 535))
		dialog.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/IntoStage2Convo.json"

	if stage == 1:
		mitch.set_scale(Vector2(3,3))
		mitch.set_global_position(Vector2(950, 535))
		$AudioStreamPlayer.stop()
		dialog.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/IntoStage3Convo.json"
		$Mitch/AnimationPlayer.play("stage3_idle")

	if stage == 2:
		mitch.set_scale(Vector2(3,3))
		mitch.set_global_position(Vector2(950, 535))
		get_tree().call_group("defense", "invisible")
		$Mitch/Stage3.queue_free()
		$AudioStreamPlayer.stop()
		dialog.get_node("DialogueBox").dialogue_file_path = "res://Src/CutScenes/dialogues/Mitch/MitchDeathConvo.json"

	add_child(dialog)
	dialog.get_node("DialogueBox").connect("finish", Callable(self, "manage_new_stage"))

func manage_new_stage():
	if current_stage == stages.stage3:
		current_stage = mitch.change_stage(current_stage)
		$Mitch/AnimationPlayer.play("hit")
		await $Mitch/AnimationPlayer.animation_finished
		var death_animation = death_aniamtoin_sc.instantiate()
		death_animation.set_scale(Vector2(3.5,3.3))
		death_animation.set_global_position(Vector2(984, 440))
		$Mitch.set_visible(false)
		add_child(death_animation)
		death_animation.emitting = true
		$AudioStreamPlayer.set_stream(load("res://Assets/Sound/SFX/426318__mtjohnson__rocks-falling.wav"))
		$AudioStreamPlayer.play()
		await get_tree().create_timer(4).timeout
		get_tree().change_scene_to_file("res://Src/Interface/Menus/ToBeContinued.tscn")



	else:
		stage_transition()
		await $CurtainColorRect/AnimationPlayer.animation_finished
		mitch.set_scale(Vector2(1.8,1.8))
		mitch.set_global_position(Vector2(960, 336))
		get_tree().call_group("defense", "make_visible")
		await get_tree().create_timer(2).timeout
		current_stage = mitch.change_stage(current_stage)
		stage_connect(current_stage)
		mitch.health = 100
		if current_stage == stages.stage3:
			change_current_track("res://Assets/Sound/OST/Stage3Mitch.ogg")





func stage_transition():
	var player = $CurtainColorRect/AnimationPlayer
	player.connect("animation_finished", Callable(self, "fade_in"))
	player.play("fade_out")

func change_current_track(file_path):
	var player = $AudioStreamPlayer
	player.stop()
	var new_track = load(file_path)
	player.set_stream(new_track)
	player.play()

func fade_in(_anim_name):
	$CurtainColorRect/AnimationPlayer.play("fade_in")
	$CurtainColorRect/AnimationPlayer.disconnect("animation_finished", Callable(self, "fade_in"))

