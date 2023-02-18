extends KinematicBody2D

signal grounded_updated(is_grounded)


const UP = Vector2(0, -1)
const SLOPE_STOP_THRESHOLD = 64.0
const DROP_THRU_BIT = 1

var velocity = Vector2()
var move_speed = 5 * Globals.UNIT_SIZE
var gravity
var move_direct 
var max_jump_velocity 
var min_jump_velocity 
var is_grounded
var is_jumping = false

var max_jump_height = 2.25 * Globals.UNIT_SIZE
var min_jump_height = 0.8 * Globals.UNIT_SIZE
var jump_duration = 0.5

onready var raycasts = $Raycasts
onready var anim_player = $Body/AnimationPlayer


func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)


	
func _apply_gravity(delta):
	velocity.y += gravity * delta

func _apply_movement():
	if is_jumping && velocity.y >= 0:
		is_jumping = false
	
	var snap = Vector2.DOWN * 32 if !is_jumping else Vector2.ZERO
	
	if move_direct == 0 && abs(velocity.x) < SLOPE_STOP_THRESHOLD:
		velocity.x = 0
	
	var stop_on_slope = true if get_floor_velocity().x == 0 else false
	
	velocity = move_and_slide_with_snap(velocity, snap, UP, stop_on_slope)
	is_grounded = !is_jumping && get_collision_mask_bit(DROP_THRU_BIT) && _check_is_grounded()
	var was_grounded = is_grounded
	
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)
	

func _update_move_direct():
	move_direct = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))

func _handle_move_input():
	velocity.x = lerp(velocity.x, move_speed * move_direct, _get_h_weight())
	if move_direct != 0:
		$Body.scale.x = move_direct
		
# 0.05 is too low
func _get_h_weight():
	return 0.2 if is_grounded else 0.1

func _check_is_grounded(raycasts = self.raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	# If the loop completes, then the raycast was not dectected
	return false
	


func _on_Area2D_body_exited(body):
	set_collision_mask_bit(DROP_THRU_BIT, true)

