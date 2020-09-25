extends KinematicBody2D

onready var sprite = $Sprite
onready var hurtBox = $HurtBox
onready var animationTree = $AnimationTree
onready var animTree = $AnimationTree.get("parameters/playback")
onready var rayCasts = $RayCasts

var health = 3

var move_speed = 30
var knockback_speed = 100

var velocity = Vector2.ZERO
var dir = "Right"

enum {
	MOVE,
	ATTACK,
	SQUASH,
	TAKE_DAMAGE
}
var state = MOVE

#return whether single raycast (in current direction) is colliding
func rayCast_colliding(type):
	var ray_name = "RayCast" + dir + type
	var rayCast = rayCasts.get_node(ray_name)
	return rayCast.is_colliding()

func _ready():
	if randi()%2 == 0:
		sprite.scale.x = -1
	animationTree.active = true

func _process(_delta):
	if sprite.scale.x == 1:
		dir = "Right"
	elif sprite.scale.x == -1:
		dir = "Left"
	
func _physics_process(_delta):
	velocity.y = 100
	
	match state:
		MOVE:
			move()
		ATTACK:
			attack()
		SQUASH:
			squash()
		TAKE_DAMAGE:
			take_damage()
	
	velocity = move_and_slide(velocity)

func move():
	if rayCast_colliding("Side") || !rayCast_colliding("Down"):
		check_player()
	
	velocity.x = move_speed * sprite.scale.x
	animTree.travel("move")

func check_player():
	var ray_name = "RayCast" + dir + "Side"
	var rayCast = rayCasts.get_node(ray_name)
	if rayCast.is_colliding():
		if "Player" in rayCast.get_collider().name:
			state = ATTACK
		else:
			sprite.scale.x *= -1
	else:
		sprite.scale.x *= -1

func attack():
	animTree.travel("attack")

func attack_finished():
	state = MOVE

func squash():
	animTree.travel("squash")

#called at start of "squash" animation
func squash_jump():
	Master.emit_signal("slime_squash")

func squash_finished():
	state = MOVE
	
func take_damage():
	animTree.travel("take_damage")
	velocity.x = lerp(velocity.x,0,0.2)
	if health <= 0:
		animTree.travel("die")
	elif int(velocity.x) == 0:
		state = MOVE

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		state = SQUASH

func _on_HurtBox_area_entered(area):
	if "Sword" in area.name || "Arrow" in area.name:
		var knockback_dir
		if area.global_position > hurtBox.global_position:
			knockback_dir = -1
		else:
			knockback_dir = 1
		health -= 1
		velocity.x = knockback_speed * knockback_dir
		state = TAKE_DAMAGE
