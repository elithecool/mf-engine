extends KinematicBody2D


const UP = Vector2(0, -1)

var velocity = Vector2()
var move_speed = 5 * 96

func _physics_process(delta):
	
	move_and_slide(velocity, UP)

func _get_input():
	var move_direct = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = move_speed
