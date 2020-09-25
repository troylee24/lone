extends KinematicBody2D

#load
onready var arrow = load("res://Player/Scenes/Arrow.tscn")

#initialization
onready var sprite = $Sprite
onready var arrowPosition = $ArrowPosition
onready var hurtBoxMove = $HurtBoxMove
onready var hurtBoxSlide = $HurtBoxSlide
onready var hitBoxSword = $HitBoxSword/CollisionShape2D
onready var animPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animTree = $AnimationTree.get("parameters/playback")

onready var sword_position = hitBoxSword.position.x

#raycasts
onready var rayCasts = $RayCasts
onready var rayCastDown = $RayCasts/RayCastDown

#timers
onready var attackTimer = $Timers/AttackTimer
onready var attackAirTimer = $Timers/AirAttackTimer
onready var bowDelayTimer = $Timers/BowDelayTimer
onready var bowDelay2Timer = $Timers/BowDelay2Timer
onready var bowMaxTimer = $Timers/BowMaxTimer
onready var invincibilityTimer = $Timers/InvincibilityTimer

#player size (in pixels)
const size_x = 50
const size_y = 37

#parameters
var min_jump_height = 0.5 * size_y
var max_jump_height = 2.4 * size_y
var gravity = 1500

#movement speeds
var move_speed = 5.5 * size_x
var wall_climb_speed = 2.0 * size_y
var slide_speed = 4.25 * size_x
var crouch_speed = 1.5 * size_x
var arrow_speed = 8 * size_x
var knockback_speed = 6 * size_x

#jump velocities
var min_jump_velocity = -sqrt(1.5 * gravity * min_jump_height)
var max_jump_velocity = -sqrt(1.5 * gravity * max_jump_height)

#variables
var move_dir = Vector2.ZERO #based on player inputs, use sprite.scale.x when no inputs
var velocity = Vector2.ZERO

#stats
var health = 100
var jumps_left = 2
var dashes_left = 2
var attack_num = 1
var arrow_speed_factor

#booleans
var is_in_air = false

enum {
	SPAWN,
	MOVE,
	WALL_CLIMB,
	SLIDE,
	CROUCH
	ATTACK_GROUND,
	ATTACK_AIR,
	BOW,
	TAKE_DAMAGE
}
var state = SPAWN

func set_collision(new_collision):
	for collision in get_children():
		if "Collision" in collision.name:
			if new_collision in collision.name:
				collision.disabled = false
			else:
				collision.disabled = true
		if "Hurtbox" in collision.name:
			var coll = collision.get_node("CollisionShape2D")
			if new_collision in collision.name:
				coll.disabled = false
			else:
				coll.disabled = true
				
func rayCast_colliding(type):
	var dir
	if sprite.scale.x == 1:
		dir = "Right"
	elif sprite.scale.x == -1:
		dir = "Left" 
	var ray_name = "RayCast" + type + dir
	var rayCast = rayCasts.get_node(ray_name)
	return rayCast.is_colliding()

func _ready():
	Master.connect("slime_squash",self,"jump")
	animationTree.active = true
	set_collision("Move")

func _physics_process(delta):
	velocity.y += gravity * delta
	move_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	match state:
		SPAWN:
			spawn()
		MOVE:
			move(delta)
			check_enemy(hurtBoxMove)
		WALL_CLIMB:
			wall_climb()
		SLIDE:
			slide()
			check_enemy(hurtBoxSlide)
		CROUCH:
			crouch()
			check_enemy(hurtBoxSlide)
		ATTACK_GROUND:
			attack_ground()
			check_enemy(hurtBoxMove)
		ATTACK_AIR:
			attack_air()
		BOW:
			bow()
			check_enemy(hurtBoxMove)
		TAKE_DAMAGE:
			take_damage()
	
	velocity = move_and_slide(velocity,Vector2.UP)

func input():
	if Input.is_action_just_pressed("Jump"):
		jump()
	if Input.is_action_just_released("Jump"):
		if velocity.y < min_jump_velocity:
			velocity.y = min_jump_velocity
	if Input.is_action_just_pressed("Slide"):
		if is_on_floor() && velocity.x != 0:
			state = SLIDE
	if Input.is_action_pressed("Crouch"):
		if is_on_floor():
			state = CROUCH
	if Input.is_action_just_pressed("Attack"):
		if is_on_floor():
			state = ATTACK_GROUND
		else:
			attackAirTimer.start(0.8)
			is_in_air = true
			state = ATTACK_AIR
	if Input.is_action_just_pressed("Bow"):
		bowDelayTimer.start(0.25)
		bowMaxTimer.start(2)
		state = BOW

func spawn():
	animTree.travel("spawn")

func spawn_finished():
	state = MOVE

func move(delta):
	velocity.x = lerp(velocity.x,move_speed * move_dir.x,0.35)
		
	var anim = "idle"
	if move_dir.x != 0:
		sprite.scale.x = move_dir.x
		anim = "run"
	else:
		velocity.x = 0
	
	if is_on_floor():
		jumps_left = 2
		if rayCast_colliding("Head") && !rayCast_colliding("Feet"):
			state = CROUCH
		else:
			set_collision("Move")
			animTree.travel(anim)
	else:
		if rayCast_colliding("Ledge") && rayCast_colliding("Feet") && rayCast_colliding("Body"):
			state = WALL_CLIMB
		else:
			if velocity.y > (gravity * delta):
				if jumps_left == 2:
					jumps_left = 1
				animTree.travel("fall")
	
	input()

func check_enemy(hurtbox):
	for body in hurtbox.get_overlapping_bodies():
		if "Slime" in body.name:
			var slime_dir = body.sprite.scale.x
			var x = global_position.x - body.global_position.x
			if x > 0 && slime_dir > 0 || x < 0 && slime_dir < 0 && invincibilityTimer.time_left == 0:
				invincibilityTimer.start()
				velocity.x = knockback_speed * slime_dir
				state = TAKE_DAMAGE

func jump():
	if is_on_floor() || (!is_on_floor() && jumps_left == 1):
		velocity.y = max_jump_velocity
		jumps_left -= 1
		animTree.travel("jump")
	else:
		jumps_left = 0

func wall_climb():
	var colliding = false
	colliding = rayCast_colliding("Ledge")
	
	#no input opposite of facing direction
	if move_dir.x != sprite.scale.x && move_dir.x != 0 || !rayCast_colliding("Feet"):
		state = MOVE
	else:
		if colliding:
			animTree.travel("wall_climb")
			#offset to ensure player not on floor while wall climbing
			if is_on_floor():
				velocity.y += 1
			#pause animation when not moving
			if move_dir.y == 0:
				sprite.frame = 138
				animationTree["parameters/wall_climb/TimeScale/scale"] = 0
			else:
				animationTree["parameters/wall_climb/TimeScale/scale"] = 0.75
			velocity.y = wall_climb_speed * move_dir.y
			jumps_left = 1
		else:
			if move_dir.y > 0:
				colliding = true
			else:
				velocity.y = 0
				animTree.travel("ledge_grab")
				if Input.is_action_just_pressed("Jump"):
					set_collision("Move")
					jump()
					state = MOVE

func slide():
	set_collision("Slide")
	animTree.travel("slide")
	var slide_dir = sprite.scale.x
	velocity.x = lerp(velocity.x,slide_speed * slide_dir,0.5)

func slide_finished():
	animTree.travel("crouch")
	state = MOVE

func crouch():
	if Input.is_action_pressed("Crouch") || rayCast_colliding("Head") && !rayCast_colliding("Feet"):
		set_collision("Slide")
		animTree.travel("crouch")
		if move_dir.x != 0:
			sprite.scale.x = move_dir.x
			animationTree["parameters/crouch/TimeScale/scale"] = 0.5
		else:
			sprite.frame = 80
			animationTree["parameters/crouch/TimeScale/scale"] = 0
		velocity.x = crouch_speed * move_dir.x
	else:
		state = MOVE

func attack_ground():
	hitBoxSword.position.x = sword_position * sprite.scale.x
	if move_dir.x != 0:
		velocity.x = lerp(velocity.x,0,0.15)
	else:
		velocity.x = 0
	
	if Input.is_action_just_pressed("Attack") && attack_num <= 3 || attack_num == 1:
		velocity.x = 200 * sprite.scale.x
		attackTimer.start(0.4)
		animTree.travel("attack" + str(attack_num))
		attack_num += 1

func attack_finished():
	hitBoxSword.disabled = true
	attack_num = 1
	state = MOVE

func attack_air():
	hitBoxSword.position.x = sword_position * sprite.scale.x
	if is_in_air:
		animTree.travel("attack_air")
		velocity.y = 0
		velocity.x = lerp(velocity.x,0,0.10)
	else:
		if rayCastDown.is_colliding() || is_on_floor():
			animTree.travel("attack_air_land")
			state = MOVE
		velocity.y = 1000

func attack_air_finished():
	is_in_air = false
	
func bow():
	velocity.x = 0
	if Input.is_action_pressed("Bow"):
		if is_on_floor():
			animTree.travel("bow_ground")
		else:
			velocity.y = 10
			animTree.travel("bow_air")
	if Input.is_action_just_released("Bow"):
		if bowDelayTimer.time_left == 0:
			arrow_speed_factor = bowMaxTimer.wait_time - bowMaxTimer.time_left
			bow_finished()
		else:
			bowDelay2Timer.start(bowDelayTimer.time_left)
	
	if bowMaxTimer.time_left == 0:
		arrow_speed_factor = bowMaxTimer.wait_time
		bow_finished()

func bow_finished():
	var arrow_instance = arrow.instance()
	arrow_instance.position = global_position
	arrow_instance.position.x += arrowPosition.position.x * sprite.scale.x
	arrow_instance.scale.x *= sprite.scale.x
	arrow_instance.apply_impulse(Vector2.ZERO,Vector2(arrow_speed * (0.75 + arrow_speed_factor) * sprite.scale.x,10))
	get_parent().add_child(arrow_instance)
	state = MOVE

func _on_BowDelay2Timer_timeout():
	arrow_speed_factor = bowDelayTimer.wait_time
	bow_finished()	

func take_damage():
	hitBoxSword.disabled = true
	animTree.travel("take_damage")
	velocity.x = lerp(velocity.x,0,0.2)
	if int(velocity.x) == 0:
		if $CollisionMove.disabled == false:
			state = MOVE
		else:
			state = CROUCH

#called at start of "take_damage" animation
func update_health():
	health -= 20
	Master.emit_signal("update_health",health)
