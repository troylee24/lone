extends Node2D

onready var animPlayer = $AnimationPlayer
onready var area2D = $Area2D

var id

func _ready():
	animPlayer.play("idle")

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		animPlayer.play("burst")

func add_cherry():
	Master.add_cherry(id)
