extends CharacterBody2D

var SPEED = 50
var JUMP_VELOCITY = -100

var lastdirection = "right"

var doublejumping = false
var groundpounding = false

const RUN_SPEED = 35
const RUN_JUMP = -20
const GP_VELOCITY = 650

var JUMPS = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var ground_particle = $GroundParticles
@onready var anim = $Sprite

func _ready():
	anim.play("idle_right")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if groundpounding == true:
			ground_particle.emitting = true
		doublejumping = false
		groundpounding = false
		JUMPS = 0
	
	
	#MOVEMENT STUFF
	if Input.is_action_just_pressed("run"): # CHECK IF STARTED RUNNING
		print("player started running")
		SPEED = SPEED + RUN_SPEED
		JUMP_VELOCITY = JUMP_VELOCITY + RUN_JUMP
		
	if Input.is_action_just_released("run"): ## CHECK IF STOPPED RUNNING
		print("player stopped running")
		SPEED = SPEED - RUN_SPEED
		JUMP_VELOCITY = JUMP_VELOCITY - RUN_JUMP
	
	if Input.is_action_just_released("groundpound") and not is_on_floor() and groundpounding == false: # GROUNDPOUND
		ground_particle.emitting = false
		print("player is groundpounding")
		groundpounding = true;
		velocity.y = -100
		await get_tree().create_timer(1).timeout
		velocity.y = GP_VELOCITY
	
	if Input.is_action_just_pressed("jump") and is_on_floor(): # JUMPING
		print("player jumped")
		JUMPS = JUMPS + 1
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and JUMPS <= 1: # DOUBLE JUMPING
		print("player double jumped")
		doublejumping = true
		JUMPS = JUMPS + 2
		velocity.y = JUMP_VELOCITY
		await get_tree().create_timer(0.25).timeout
		doublejumping = false

	var direction = Input.get_axis("left", "right") # MOVEMENT
	if groundpounding == false: # CHECK IF NOT GROUNDPOUNDING
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	#ANIMATION STUFF
	if not is_on_floor() and lastdirection == "left" and doublejumping == false: # FALLING LEFT ANIMATION
		anim.play("left_fall")
	elif not is_on_floor() and lastdirection == "right" and doublejumping == false: # FALLING RIGHT ANIMATION
		anim.play("right_fall")
	elif Input.is_action_pressed("left") and Input.is_action_pressed("run"): #LEFT RUNNING ANIMATION
		lastdirection = "left"
		anim.play("left_run")
	elif Input.is_action_pressed("left"): # LEFT ANIMATION
		lastdirection = "left"
		anim.play("left_walk")
	elif Input.is_action_pressed("right") and Input.is_action_pressed("run"): #RIGHT RUNNING ANIMATION
		lastdirection = "right"
		anim.play("right_run")
	elif Input.is_action_pressed("right"): # RIGHT ANIMATION
		lastdirection = "right"
		anim.play("right_walk")
	else:
		if lastdirection == "left": # IDLE LEFT ANIMATION
			anim.play("idle_left")
		elif lastdirection == "right": # IDLE RIGHT ANIMATION
			anim.play("idle_right")
