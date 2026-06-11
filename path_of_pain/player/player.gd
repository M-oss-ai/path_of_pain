extends CharacterBody2D

# ================== CONSTANTE ==================

# ========= SPEED X =========
const SPEED = 300.0
const DASH_SPEED = 600.0
const CRISTAL_DASH_SPEED = 900

# ========= VELOCITY Y =========
const JUMP_VELOCITY = -500.0
const DOUBLE_JUMP_VELOCITY = -500.0
const WALL_JUMP_VELOCITY = -500.0
const WALL_SLIDE_VELOCITY = 350

# ========= DURATION =========
const DURATION = {
	"dash" : 0.3, 
	"dash_cooldown" : 0.17, 
	"wall_fixe" : 0.1, 
	"wall_jump" : 0.13, 
	"charge_crystal_dash" : 1.5, 
	"crystal_dash_cooldown" : 0.5
}


# ================== variables ==================

# ========= timer =========
var timer = {
	"dash" : 0.0, 
	"dash_cooldown" : 0.0, 
	"wall_fixe" : 0.0, 
	"wall_jump" : 0.0, 
	"charge_crystal_dash" : 0.0, 
	"crystal_dash_cooldown" : 0.0
}

# ========= player_status =========
var player_status = {
	"is_dashing" : false, 
	"is_in_dash_cooldown" : false, 
	"is_wall_fixed" : false, 
	"is_wall_sliding" : false, 
	"hase_quitte_wall" : true, 
	"is_wall_jumping" : false, 
	"is_charging_crystal_dash" : false, 
	"is_cristal_dashing" : false, 
	"is_crystal_dash_ready" : false, 
	"is_in_crystal_dash_cooldown" : false, 
	"can_double_jump" : true, 
	"can_dash" : true
}

# ========= direction =========
var wall_direction = 0.0
var last_direction = 1.0

# ========= location =========
var tp_location = Vector2(0, 0)

# ================== signal ==================
signal double_jump_signal

# =========================== function ===========================
func _physics_process(delta: float) -> void:
	# ================== physique ==================
	gravity(delta)
	move(delta)
	look_at_wall()
	
	# ================== actions ==================
	if Input.is_action_just_pressed("jump") and not player_status["is_charging_crystal_dash"] and not player_status["is_crystal_dash_ready"] and not player_status["is_cristal_dashing"] and not player_status["is_in_crystal_dash_cooldown"]:
		if is_on_floor() and not player_status["is_dashing"]:
			jump()
			
		elif is_on_wall():
			wall_jump()
			
		elif player_status["can_double_jump"] and not player_status["is_dashing"]:
			double_jump()
	
	if Input.is_action_just_pressed("dash") and player_status["can_dash"] and not player_status["is_dashing"] and not player_status["is_in_dash_cooldown"] and not player_status["is_charging_crystal_dash"] and not player_status["is_crystal_dash_ready"] and not player_status["is_cristal_dashing"] and not player_status["is_in_crystal_dash_cooldown"]:
		dash()
	
	if Input.is_action_just_pressed("cristal dash") and (is_on_wall() or is_on_floor()) and not player_status["is_dashing"]:
		charge_crystal_dash()
		
	if Input.is_action_just_released("cristal dash"):
		if player_status["is_charging_crystal_dash"]:
			end_charge_crystal_dash()
		elif player_status["is_crystal_dash_ready"]:
			crystal_dash()
	
	if (Input.is_action_just_pressed("cristal dash") or Input.is_action_just_pressed("jump")) and player_status["is_cristal_dashing"]:
		end_cristal_dash()
	
	
	# ================== process ==================
	if player_status["is_wall_fixed"]:
		process_wall_fixe(delta)
		
	if player_status["is_dashing"]:
		process_dash(delta)
		
	elif player_status["is_in_dash_cooldown"]:
		dash_cooldown(delta)
	
	if player_status["is_wall_jumping"]:
		process_wall_jump(delta)
	
	if player_status["is_charging_crystal_dash"]:
		process_charge_crystal_dash(delta)
		
	if player_status["is_in_crystal_dash_cooldown"]:
		cristal_dash_cooldown(delta)
		
	move_and_slide()


# ================== gravity ==================
func gravity(delta):
	# Add the gravity.
	if is_on_floor():
		player_status["can_double_jump"] = true
		player_status["can_dash"] = true
	elif player_status["is_dashing"] or player_status["is_wall_fixed"] or player_status["is_charging_crystal_dash"] or player_status["is_crystal_dash_ready"] or player_status["is_cristal_dashing"] or player_status["is_in_crystal_dash_cooldown"]:
		velocity.y = 0
	elif player_status["is_wall_sliding"]:
		velocity.y += WALL_SLIDE_VELOCITY * delta
	else:
		velocity += get_gravity() * delta

# ================== move ==================
func move(delta):
	var direction := Input.get_axis("left", "right")
	if player_status["is_wall_jumping"]:
		direction = last_direction
		
	if player_status["is_cristal_dashing"]:
		velocity.x = CRISTAL_DASH_SPEED * last_direction
		
	elif player_status["is_in_crystal_dash_cooldown"]:
		velocity.x = move_toward(velocity.x, 0.0, (CRISTAL_DASH_SPEED / DURATION["crystal_dash_cooldown"]) * delta)
	elif player_status["is_charging_crystal_dash"] or player_status["is_crystal_dash_ready"]:
		velocity.x = 0
			
	elif not player_status["is_dashing"]:
		if direction:
			last_direction = direction
			velocity.x = SPEED * direction
		else:
			velocity.x = 0

# ================== look_at_wall ==================
func look_at_wall():
	if is_on_wall():
		if player_status["is_dashing"] and wall_direction != last_direction:
			end_dash()
			player_status["is_in_dash_cooldown"] = true
			timer["dash_cooldown"] = DURATION["dash_cooldown"]
		
		if player_status["is_cristal_dashing"] and wall_direction != last_direction:
			end_cristal_dash()
				
		if not is_on_floor():
			wall_direction = sign(get_wall_normal().x)
				
			last_direction = wall_direction
			player_status["can_double_jump"] = true
			player_status["can_dash"] = true
				
			if velocity.y >= 0 and not player_status["is_wall_fixed"] and not player_status["is_wall_sliding"] and player_status["hase_quitte_wall"]:
				player_status["hase_quitte_wall"] = false
				player_status["is_wall_fixed"] = true
				timer["wall_fixe"] = DURATION["wall_fixe"]
				
			elif velocity.y < 0:
				player_status["is_wall_sliding"] = false
				player_status["is_wall_fixed"] = false
				player_status["hase_quitte_wall"] = true
	else:
		wall_direction = 0.0
		player_status["is_wall_sliding"] = false
		player_status["is_wall_fixed"] = false
		player_status["hase_quitte_wall"] = true

func process_wall_fixe(delta):
	timer["wall_fixe"] -= delta
	
	if timer["wall_fixe"] <= 0:
		player_status["is_wall_fixed"] = false
		player_status["is_wall_sliding"] = true


# ================== jump ==================
func jump():
	velocity.y = JUMP_VELOCITY
	

# ================== double_jump ==================
func double_jump():
	velocity.y = DOUBLE_JUMP_VELOCITY
	player_status["can_double_jump"] = false
	emit_signal("double_jump_signal")
	
	
# ================== wall_jump ==================
func wall_jump():
	velocity.y = WALL_JUMP_VELOCITY
	player_status["is_wall_sliding"] = false
	player_status["is_wall_fixed"] = false
	player_status["hase_quitte_wall"] = true
	player_status["is_wall_jumping"] = true
	timer["wall_jump"] = DURATION["wall_jump"]

func process_wall_jump(delta):
	timer["wall_jump"] -= delta
	
	if timer["wall_jump"] <= 0:
		last_direction = -last_direction
		player_status["is_wall_jumping"] = false


# ================== dash ==================
func dash():
	player_status["is_dashing"] = true
	timer["dash"] = DURATION["dash"]
	
	if not is_on_floor() and not is_on_wall():
		player_status["can_dash"] = false

func process_dash(delta):
	timer["dash"] -= delta
	velocity.x = DASH_SPEED * last_direction
	
	if timer["dash"] <= 0:
		end_dash()
		player_status["is_in_dash_cooldown"] = true
		timer["dash_cooldown"] = DURATION["dash_cooldown"]

func dash_cooldown(delta):
	timer["dash_cooldown"] -= delta
	
	if timer["dash_cooldown"] <= 0:
		end_dash_couldown()
		
func end_dash():
	player_status["is_dashing"] = false

func end_dash_couldown():
	player_status["is_in_dash_cooldown"] = false
	

# ================== crystal_dash ==================
func crystal_dash():
	player_status["is_crystal_dash_ready"] = false
	player_status["is_cristal_dashing"] = true
	
func charge_crystal_dash():
	player_status["is_charging_crystal_dash"] = true
	timer["charge_crystal_dash"] = DURATION["charge_crystal_dash"]

func process_charge_crystal_dash(delta):
	timer["charge_crystal_dash"] -= delta
	
	if timer["charge_crystal_dash"] <= 0:
		end_charge_crystal_dash()
		player_status["is_crystal_dash_ready"] = true

func end_charge_crystal_dash():
	player_status["is_charging_crystal_dash"] = false

func end_cristal_dash():
	player_status["is_cristal_dashing"] = false
	player_status["is_in_crystal_dash_cooldown"] = true
	timer["crystal_dash_cooldown"] = DURATION["crystal_dash_cooldown"]

func cristal_dash_cooldown(delta):
	timer["crystal_dash_cooldown"] -= delta
	
	if timer["crystal_dash_cooldown"] <= 0:
		player_status["is_in_crystal_dash_cooldown"] = false
