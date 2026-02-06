extends CharacterBody2D


const SPEED = 75.0
const SPRINT_SPEED = 300.0
const JUMP_VELOCITY = -400.0
var was_on_floor = true
var past_speed = 0.0
var time_ctrl = 0
var health = 100
var has_hit_player = false
var is_attacking = false
@onready var anim = get_node("AnimatedSprite2D")
@onready var Collision = get_node("CollisionShape2D")
@onready var AttackRayCast = $Attack_sword/RayCast2D

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var offset = mouse_pos.x - position.x
	var direct_for_attack = (mouse_pos - position).normalized()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		anim.play("fall")
	# Handle jump.
	if !is_attacking:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			anim.play("jump")
			velocity.y = JUMP_VELOCITY
		var direction := Input.get_axis("move_left", "move_right")
		var current_speed = SPRINT_SPEED if Input.is_action_pressed("Shift") else SPEED
		if direction:
			if Input.is_action_pressed("CTRL"):
				if is_on_floor():
					time_ctrl += 1
					anim.play("ctrl")
					Collision.scale.x = 1.9
					Collision.scale.y = 0.4
					Collision.position.y = 72.0
					if direction == 1:
						velocity.x = move_toward(velocity.x, 0, past_speed * delta)
					elif direction == -1:
						velocity.x = move_toward(velocity.x, 0, -past_speed * delta)
				else:
					velocity.y = -JUMP_VELOCITY * 2
			elif current_speed > 200:
				if is_on_floor() and velocity.y == 0:
					anim.play("run")
				velocity.x = direction * current_speed
				time_ctrl = 0
			else:
				if velocity.y == 0:
					anim.play("walk")
				velocity.x = direction * current_speed
				time_ctrl = 0
			past_speed = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed * 3)
			Collision.scale.x = 1.055
			Collision.scale.y = 1.055
			Collision.position.y = 0
		if velocity.x == 0 and velocity.y == 0 and is_on_floor():
			anim.play("idle")
			
		if velocity.x != 0 or velocity.y != 0:
			if direction == -1:
				anim.flip_h = true
			elif direction == 1:
				anim.flip_h = false
		else:
			if offset > 0:
				anim.flip_h = false
			elif offset < 0:
				anim.flip_h = true
	was_on_floor = is_on_floor()
	move_and_slide()
	if Input.is_action_just_pressed("Attack"):
		Attack(direct_for_attack)


func take_damage(amount):
	health -= amount
	print("Атака по игроку: ", amount)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "jump":
		anim.play('fall')
		print('fall')
		
		
func Attack(direct: Vector2):
	if is_attacking:
		return  # Выходим если уже атакуем
		
	is_attacking = true
	has_hit_player = false
	var attack_range = 100.0
	anim.play("Attack")
	velocity.x = 250 * direct.x
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
				if object.get_parent().name == 'Mobs':
					object.take_damage(10)
					has_hit_player = true,
		0.0, 1.0, 0.5
	).finished.connect(func(): is_attacking = false)  # Сбрасываем флаг
