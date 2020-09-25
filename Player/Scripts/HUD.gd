extends TextureRect

onready var animPlayer = $AnimationPlayer
onready var textureProgress = $TextureProgress
onready var heart = $Heart/Label
onready var cherry = $Cherry/Label

const LOW_HEALTH_TRIGGER = 25

var is_health_low = false

func _ready():
	Master.connect("update_health",self,"update_health")
	Master.connect("add_cherry",self,"add_cherry")
	update_text(heart)
	update_text(cherry)

func update_text(label):
	var text = "x "
	match label:
		heart:
			text += str(Master.lives)
		cherry:
			text += str(Master.picked_cherries.size())
	label.bbcode_text = text

func add_cherry():
	var cherries = Master.picked_cherries.size()
	update_text(cherry)
	if cherries%5 == 0:
		Master.lives += 1
		update_text(heart)

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
