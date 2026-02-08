extends CharacterBody2D

var Go = false
var speed = 300.0
var random_direction = 0
var random_direction_time = 0
var past_position_x = 0
var past_position_x_for_direct = 0
var is_attacking = false
var has_hit_player = false
var health = 50
# Called when the node enters the scene tree for the first time.
@onready var anim = get_node('AnimatedSprite2D')
@onready var RayCast = get_node('RayCast2D')
@onready var LeftRayCast = $Left/RayCast2D
@onready var RightRayCast = $Right/RayCast2D
@onready var AttackRayCast = $Attack/RayCast2D
func _physics_process(delta: float) -> void:
	var distance_for_player = update_distance()
	var change_position_in_move = past_position_x_for_direct - self.position.x
	if change_position_in_move == 0:
		logic_move_without_player()
	past_position_x_for_direct = self.position.x
	#Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta
	if health <= 0:
		anim.play("Death")
		await anim.animation_finished  
		queue_free()
	#Работа с направлением на игрока
	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()
	RayCast.target_position = direction * 5000.0
	
	
	#В случае если игрок снизу или сверху
	if abs(direction.x) < 0.2:
		logic_move_without_player()
	elif RayCast.is_colliding():
		var object = RayCast.get_collider()
		if object.name == 'Player':
			Go = true
			random_direction_time = 0
	
	#Это условия прыжка
	if is_on_floor():
		if LeftRayCast.is_colliding():
			var object = LeftRayCast.get_collider()
			if object.name != "Player":
				velocity.y = -400.0
		if RightRayCast.is_colliding():
			var object = RightRayCast.get_collider()
			if object.name != "Player":
				velocity.y = -400.0
	#Это движение
	if distance_for_player != null:
		if Go and distance_for_player > 30.0:
			velocity.x = direction.x * speed
			anim.play('Run')	
			if direction.x < 0:
				anim.flip_h = true
			elif direction.x > 0:
				anim.flip_h = false
		elif distance_for_player < 30.0:
			Go = false
			Attack(direction)
		else: 
			anim.play('idle')
			velocity.x == 0
	move_and_slide()

func logic_move_without_player():
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
func update_distance():
	RayCast.force_raycast_update()
	if RayCast.is_colliding():
		var collision_point = RayCast.get_collision_point()
		var distance = global_position.distance_to(collision_point)
		print("Расстояние до игрока: ", distance)  # Выводит расстояние до объекта
		return distance
	return null  # Нет столкновения
	
	
func take_damage(amount):
	health -= amount

func Attack(direct: Vector2):
	if is_attacking:
		return  # Выходим если уже атакуем
		
	is_attacking = true
	has_hit_player = false
	var attack_range = 100.0
	anim.play("Attack")
	create_tween().tween_method(
		func(t: float):
			var angle = lerp(0.0, PI, t)
			var current_range = sin(angle) * attack_range
			
			# Поворачиваем RayCast в направлении атаки
			AttackRayCast.global_rotation = direct.angle()
			
			# Устанавливаем target_position относительно поворота
			AttackRayCast.target_position = Vector2(current_range, 0)
			
			if AttackRayCast.is_colliding() and not has_hit_player:
				var object = AttackRayCast.get_collider()
				if object.name == 'Player':
					Go = true
					object.take_damage(10)
					has_hit_player = true,
		0.0, 1.0, 1.0
	).finished.connect(func(): is_attacking = false)  # Сбрасываем флаг
