extends TextureRect

onready var animPlayer = $AnimationPlayer
onready var textureProgress = $TextureProgress
onready var heart = $Heart/Label
onready var cherry = $Cherry/Label

const LOW_HEALTH_TRIGGER = 25

var is_health_low = false

func _ready():
	heart.bbcode_text = "x " + str(Master.lives)
	cherry.bbcode_text = "x " + str(Master.picked_cherries.size())

func add_cherry(cherries):
	cherry.bbcode_text = "x " + str(cherries)
	if cherries%5 == 0:
		Master.lives += 1
		heart.bbcode_text = "x " + str(Master.lives)

func update_health(new_health):
	textureProgress.update_value(new_health)
	is_health_low = new_health <= LOW_HEALTH_TRIGGER
	animPlayer.play('Shake')
	
	if new_health <= 0:
		Master.lose_heart()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Shake":
			if is_health_low:
				animPlayer.play("Flash")
		"Flash":
			if not is_health_low:
				animPlayer.stop("Flash")
