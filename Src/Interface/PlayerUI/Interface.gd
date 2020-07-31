extends Control

onready var health_count = $HealthBar/Counter/Count
onready var health_bar = $HealthBar/TextureProgress
onready var tween = $Tween

var animated_health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_max_health = $"../Player/".max_health
	health_bar.max_value = player_max_health
	update_health(player_max_health)



func _process(delta):
	var round_value = round(animated_health)
	health_count.text = str(round_value)
	health_bar.value = animated_health

func _on_player_health_changed(player_health):
	update_health(player_health)

func update_health(new_value):
	tween.interpolate_property(self, "animated_health", animated_health, new_value, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if not tween.is_active():
		tween.start()
