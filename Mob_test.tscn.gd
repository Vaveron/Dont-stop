extends CharacterBody2D

var Go = false
var speed = 300.0
var random_direction = 0
var random_direction_time = 0
var past_position_x = 0
# Called when the node enters the scene tree for the first time.
@onready var anim = get_node('AnimatedSprite2D')
@onready var RayCast = get_node('RayCast2D')
@onready var LeftRayCast = $Left/RayCast2D
@onready var RightRayCast = $Right/RayCast2D
func _physics_process(delta: float) -> void:
	#Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Работа с направлением на игрока
	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()
	RayCast.target_position = direction * 5000.0
	
	if abs(direction.x) < 0.2:
		var change_position = past_position_x - self.position.x
		past_position_x = self.position.x
		Go = false
		if random_direction_time == 0:
			random_direction = randi_range(0, 1) * 2 - 1
			print("Направление движения моба:", random_direction )
			random_direction_time += 1
		if change_position == 0:
			if random_direction == 1:
				random_direction == -1
			else: 
				random_direction == 1
		velocity.x == speed * random_direction * 10
	elif RayCast.is_colliding():
		var object = RayCast.get_collider()
		if object.name == 'Player':
			Go = true
			random_direction_time = 0
	
	#Это условия прыжка
	if (LeftRayCast.is_colliding() or RightRayCast.is_colliding()) and is_on_floor():
		velocity.y = -400.0
	
	#Это движение
	if velocity.x == 0 and velocity.y == 0:
		anim.play('idle')
	if Go:
		velocity.x = direction.x * speed
		anim.play('Run')	
		if direction.x < 0:
			anim.flip_h = true
		elif direction.x > 0:
			anim.flip_h = false
	else: 
		velocity.x == 0
	move_and_slide()
