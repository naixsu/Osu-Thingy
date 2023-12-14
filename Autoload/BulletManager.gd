extends Node2D

@export var Bullet : PackedScene

## Spawns bullets
func spawn_bullets(notePos : Vector2) -> void:
	var root = get_tree().get_root()
	var bulletGroup = root.get_node("Main/BulletGroup")
	
	# Classic pattern: 8 bullets
	var numBullets = 8  # Number of bullets (360 degrees / 45 degrees)
	var angleInterval = 45  # Degrees between each bullet
	
	for i in range(numBullets):
		var bullet = Bullet.instantiate()
		var angleDeg = i * angleInterval
		
		bullet.global_position = notePos
		bullet.rotation_degrees = angleDeg
		
		bulletGroup.add_child(bullet)
