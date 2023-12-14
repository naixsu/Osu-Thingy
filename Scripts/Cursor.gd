extends Node2D

class_name Cursor

@onready var audio = $AudioStreamPlayer2D
@onready var hitTimer = $HitTimer
@onready var healthLabel = $HealthLabel


var health : int = 100

func _process(_delta):
	healthLabel.text = str(health)

func handle_hit(dmg: int) -> void:
	health -= dmg

func restore_health(hp: int) -> void:
	health += hp
