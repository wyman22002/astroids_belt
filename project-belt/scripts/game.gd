extends Node2D

@export var asteroid_scenes: Array[PackedScene] = []

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea
@onready var asteroid_spawn_timer = $AsteroidSpawnTimer

var asteroid_scene = preload("res://scenes/asteroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives: int:
	set(value):
		lives = value
		hud.init_lives(lives)

func _ready():
	randomize()
	game_over_screen.visible = false
	score = 0
	lives = 3
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)


func _on_player_laser_shot(laser):
	$Sounds/LaserSound.play()
	lasers.add_child(laser)


func _on_asteroid_exploded(pos, size, points):
	$Sounds/AseroidHitSound.play()
	score += points
	for i in range(2):
			match size:
				Asteroid.AsteroidSize.LARGE:
					spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
				Asteroid.AsteroidSize.MEDIUM:
					spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
				Asteroid.AsteroidSize.SMALL:
					pass
					#spawn_asteroid(pos, Asteroid.AsteroidSize.TINY)
				#Asteroid.AsteroidSize.TINY:
					#pass

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)

func _on_player_died():
	$Sounds/PlayerDieSound.play()
	lives -= 1
	player.global_position = player_spawn_pos.global_position
	if lives <= 0:
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1.5).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_pos.global_position)


func _on_asteroid_spawn_timer_timeout():
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$Player/AsteroidSpawnZone/PathFollow2D.progress = rng.randi_range(0, 4800)
	
	var a = asteroid_scene.instantiate()
	
	a.size = Asteroid.AsteroidSize.LARGE
	a.connect("exploded", _on_asteroid_exploded)
	
	a.global_position = $Player/AsteroidSpawnZone/PathFollow2D/Marker2D.global_position
	asteroids.call_deferred("add_child", a)
	 
