extends KinematicBody2D

onready var sprite = $Sprite
onready var animPlayer = $AnimationPlayer
onready var timer = $Timer

var move_speed = 50
var velocity = Vector2.ZERO

func _ready():
	timer.start()

func _physics_process(_delta):
	animPlayer.play("move")
	velocity = Vector2(move_speed * sprite.scale.x,0)
	velocity = move_and_slide(velocity)
	
	if global_position.x <= 0 || get_slide_count() != 0:
		sprite.scale.x *= -1
		timer.start()

func _on_Timer_timeout():
	sprite.scale.x *= -1

func _on_Area2D_body_entered(body):
	if "Arrow" in body.name:
		sprite.scale.x *= -1
