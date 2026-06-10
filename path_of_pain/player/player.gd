extends CharacterBody2D


const SPEED = 300.0
const DASH_SPEED = 600.0

const JUMP_VELOCITY = -400.0
const DOUBLE_JUMP_VELOCITY = -400.0
const WALL_JUIMP_VELOCITY = -400.0

const WALL_SLIDE_DRAG = 7

const DASH_DURATION = 0.3
const DASH_COOLDOWN_DURATION = 0.17
const WALL_FIXE_DURATION = 0.5
const WALL_JUMP_DURATION = 0.2

var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var wall_fixe_timer = 0.0
var wall_jump_timer = 0.0

var can_double_jump = true
var can_dash = true

var is_dashing = false
var is_in_dash_cooldown = false
var is_wall_fixed = false
var is_wall_sliding = false
var hase_quitte_wall = true


var last_direction = 1.0

var tp_location = Vector2(0, 0)

signal double_jump_signal

func _physics_process(delta: float) -> void:
	
	gravity(delta)
	
	move()
	
	look_at_wall()
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dashing:
		jump()
		
	elif Input.is_action_just_pressed("jump") and can_double_jump and not is_dashing:
		double_jump()
	
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing and not is_in_dash_cooldown:
		dash()
	
	if is_wall_fixed:
		process_wall_fixe(delta)
		
	if is_dashing:
		process_dash(delta)
		
	elif is_in_dash_cooldown:
		dash_cooldown(delta)
		
	move_and_slide()

func gravity(delta):
	# Add the gravity.
	if is_on_floor():
		can_double_jump = true
		can_dash = true
	elif is_dashing or is_wall_fixed:
		velocity.y = 0
	elif is_wall_sliding:
		velocity.y += 400 * delta
	else:
		velocity += get_gravity() * delta

func move():
	var direction := Input.get_axis("left", "right")
	if not is_dashing:
		if direction:
			last_direction = direction
			velocity.x = SPEED * direction
		else:
			velocity.x = 0

func look_at_wall():
	if is_on_wall() and not is_on_floor():
		can_double_jump = true
		can_dash = true
		if velocity.y >= 0 and not is_wall_fixed and not is_wall_sliding and hase_quitte_wall:
			hase_quitte_wall = false
			is_wall_fixed = true
			wall_fixe_timer = WALL_FIXE_DURATION
		elif velocity.y < 0:
			is_wall_sliding = false
			is_wall_fixed = false
			hase_quitte_wall = true
			
	else:
		is_wall_sliding = false
		is_wall_fixed = false
		hase_quitte_wall = true

func process_wall_fixe(delta):
	wall_fixe_timer -= delta
	
	if wall_fixe_timer <= 0:
		is_wall_fixed = false
		is_wall_sliding = true

func jump():
	velocity.y = JUMP_VELOCITY
	
func double_jump():
	velocity.y = DOUBLE_JUMP_VELOCITY
	can_double_jump = false
	emit_signal("double_jump_signal")

func dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	
	if not is_on_floor() or not is_on_wall():
		can_dash = false

func process_dash(delta):
	dash_timer -= delta
	velocity.x = DASH_SPEED * last_direction
	
	if dash_timer <= 0:
		is_dashing = false
		is_in_dash_cooldown = true
		dash_cooldown_timer = DASH_COOLDOWN_DURATION

func dash_cooldown(delta):
	dash_cooldown_timer -= delta
	
	if dash_cooldown_timer <= 0:
		end_dash()
		
func end_dash():
	is_dashing = false
	is_in_dash_cooldown = false
