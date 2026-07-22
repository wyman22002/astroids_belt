class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 100
@export var rate_of_fire := 0.25

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionPolygon2D

var lazer_scene = preload("res://scenes/laser.tscn")

var shoot_cd = false
var alive := true

func _process(delta):
	if !alive: return
	
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false
	
	#if Input.action_press("move_forward"):
		#$CPUParticles2D.emitting = true

func _physics_process(delta):
	if !alive: return
	
	var input_vector := Vector2(0, Input.get_axis("move_forward", "move_backwards"))
	
	# Basic movement
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed*delta))
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed*delta))
	
	# This creates drag slowing the ship down
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
	
	move_and_slide()
	
	# This makes the ship loop around screen edges
	#var screen_size = get_viewport_rect().size
	#if global_position.y < 0:
		#global_position.y = screen_size.y
	#elif global_position.y > screen_size.y:
		#global_position.y = 0
		#
	#if global_position.x < 0:
		#global_position.x = screen_size.x
	#elif global_position.x > screen_size.x:
		#global_position.x = 0

func shoot_laser():
	var l = lazer_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("laser_shot", l)

func die():
	if alive == true:
		alive = false
		sprite.visible = false
		cshape.set_deferred("disabled", true)
		emit_signal("died")

func respawn(pos):
	if alive == false:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		sprite.visible = true
		cshape.set_deferred("disabled", false)
