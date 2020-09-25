extends Area2D

onready var animPlayer = $AnimationPlayer

var end = false

func _ready():
	$RichTextLabel.bbcode_text += name.to_upper()

func _on_Checkpoint_body_entered(body):
	if "Player" in body.name && name != Master.checkpoint:
		if name == "Win" && Master.picked_cherries.size() != Master.total_cherries:
			return
		animPlayer.play("display_text")
		Master.checkpoint = name
