class_name Asteroid extends Area2D

signal exploded(pos, size, points)

var movement_vector := Vector2(0, -1)

enum AsteroidSize{LARGE, MEDIUM, SMALL, TINY}
var rng = RandomNumberGenerator.new()

@export var size := AsteroidSize.LARGE
var speed := 50

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

var points: int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 10
			AsteroidSize.MEDIUM:
				return 15
			AsteroidSize.SMALL:
				return 20
			_:
				return 0

func _ready() -> void:
	rotation = randf_range(0, 2*PI)
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(90, 140)
			sprite.texture = preload("res://assets/images/Meteors/meteorGrey_big1.png")
			cshape.set_deferred("shape", preload("res://resources/astroid_cshape_large.tres"))
		AsteroidSize.MEDIUM:
			speed = randf_range(130, 190)	
			sprite.texture = preload("res://assets/images/Meteors/meteorGrey_med1.png")
			cshape.set_deferred("shape", preload("res://resources/astroid_cshape_med.tres"))
		AsteroidSize.SMALL:
			speed = randf_range(180, 230)
			sprite.texture = preload("res://assets/images/Meteors/meteorGrey_small1.png")
			cshape.set_deferred("shape", preload("res://resources/astroid_cshape_small.tres"))
		AsteroidSize.TINY:
			speed = randf_range(150, 200)
			sprite.texture = preload("res://assets/images/Meteors/meteorGrey_tiny1.png")
			cshape.set_deferred("shape", preload("res://resources/astroid_cshape_tiny.tres"))


func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	# This is the part that makes them loop around the screen
	#var radius = cshape.shape.radius
	#var screen_size = get_viewport_rect().size
	#if (global_position.y + radius) < 0:
		#global_position.y = (screen_size.y + radius)
	#elif (global_position.y - radius) > screen_size.y:
		#global_position.y = -radius
		#
	#if (global_position.x + radius) < 0:
		#global_position.x = (screen_size.x + radius)
	#elif (global_position.x - radius) > screen_size.x:
		#global_position.x = -radius
	
	# I want the tiny asteroids to fade after 3 sec

func explode():
	emit_signal("exploded", global_position, size, points)
	queue_free()


func _on_body_entered(body):
	if body is Player:
		var player = body
		player.die()
