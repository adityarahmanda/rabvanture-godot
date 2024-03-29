class_name PlayerEntity
extends Entity

@export var min_jump_velocity := 150.0
@export var max_jump_velocity := 300.0
@export var charge_jump_time := 1.0
@export var jump_forgiveness := 0.2

var direction := 0.0
var is_jumping := false
var is_charge_jumping := false
var elapsed_charge_jump_time := 0.0
var elapsed_jump_time := jump_forgiveness
var jump_velocity := 0.0
var ungrounded_time := 0.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal on_dead

func _physics_process(delta) -> void:
	handle_movement(delta)
	handle_facing()

func handle_movement(delta) -> void:
	# Handle Jump
	if Input.is_action_just_pressed("ui_accept"):
		elapsed_charge_jump_time = 0
		jump_velocity = min_jump_velocity
		is_charge_jumping = true
	if Input.is_action_just_released("ui_accept"):
		is_charge_jumping = false
	
	if is_charge_jumping:
		jump_velocity = lerp(jump_velocity, max_jump_velocity, elapsed_charge_jump_time / charge_jump_time)
		jump_velocity = clamp(jump_velocity, min_jump_velocity, max_jump_velocity)
		elapsed_charge_jump_time += delta
		elapsed_jump_time = 0
	else:
		elapsed_jump_time += delta
	
	if is_on_floor():
		ungrounded_time = 0
		is_jumping = false
	else:
		ungrounded_time += delta
		velocity.y += gravity * delta
		
	if ungrounded_time > jump_forgiveness:
		jump_velocity = min_jump_velocity
	
	if ungrounded_time <= jump_forgiveness and elapsed_jump_time <= jump_forgiveness and !is_jumping and !is_charge_jumping:
		velocity.y = -jump_velocity
		is_jumping = true
		
	# Handle Movement
	direction = clamp(Input.get_axis("ui_left", "ui_right"), -1, 1)
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func handle_facing() -> void:
	if direction > 0:
		$Sprite2D.scale.x = 1
	elif direction < 0:
		$Sprite2D.scale.x = -1
		
func die() -> void:
	emit_signal("on_dead")
