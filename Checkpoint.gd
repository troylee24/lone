extends Area2D

onready var animPlayer = $AnimationPlayer

func _on_Checkpoint_body_entered(body):
	if "Player" in body.name && name != Master.checkpoint:
		animPlayer.play("display_text")
		Master.checkpoint = name
