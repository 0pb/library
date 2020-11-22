extends KinematicBody2D


export(float) var ACCELERATION = 400.0 * 5
export(float) var MAX_SPEED = 200.0
export(float) var detection_zone_radius = 350.0
export(int) var max_health = 1


onready var detection : Node = get_node("DetectionZone/DetectionZone")
onready var timer_end_chase : Node = get_node("End_of_chase")
onready var footstep : Node = get_node("AudioStreamPlayer2D")
onready var squeak : Node = get_node("AudioStreamPlayer2D2")
onready var sprite : Node = get_node("AnimatedSprite")
onready var light : Node = get_node("Light2D")
onready var shield : Node = get_node("Shield")
onready var spawn_location : Vector2 = global_position
onready var velocity := Vector2.ZERO
onready var player_body : PhysicsBody2D


var path := PoolVector2Array() setget set_path
var true_if_returning = false
var true_if_chasing = false
var current_health : int
var current_alpha : float
var true_if_shield : bool


func set_path(value : PoolVector2Array) -> void:
	path = value
	if value.size() == 0:
		return
	set_process(true)


# taken from https://gist.github.com/saward/2e14ec0f4744834e366d436f7c3a8420
# modified for move_and_slide movement instead of linear interpolation
# Use recursion to move along path.  We move along path, and if there's any
# distance remaining, we call this function again and move further along until
# we reach our destination or there's no distance left to travel
func move_along_path(distance : float, delta : float) -> void:
	if footstep.is_playing():
		pass
	else:
		footstep.playing = true
	# Ensure we have an actual path, otherwise we are done and can stop
	# processing
	if path.size() == 0:
		set_process(false)
		return
	
	# If there's no distance available to travel, then nothing to do for this
	# tick
	if distance <= 0.0:
		return
	
	# Check how far until the next point
	var distance_to_next_point : = position.distance_to(path[0])
	
	# Assuming there's some distance left to go, let's move it
	if distance_to_next_point > 0.0:
		# Use the min of distance and distance_to_next_point so that we don't
		# overshoot our destination when distance > distance_to_next_point
#		position = position.linear_interpolate(path[0], min(distance, distance_to_next_point) / distance_to_next_point)
#		position = position.linear_interpolate(path[0], min(distance, distance_to_next_point) / distance_to_next_point)
		look_at(path[0])
		velocity = velocity.move_toward((path[0] - global_position).normalized() * MAX_SPEED, ACCELERATION * delta)
		velocity = move_and_slide(velocity)


	# If this condition is met, we must have reached destination, so remove point
	if distance >= distance_to_next_point:
		path.remove(0)
	
	# Subtract the amount we used up before moving further along the path.  If
	# there is no distance left, the next call will check this at the start
	# and return
	move_along_path(distance - distance_to_next_point, delta)


func _ready() -> void:
	sprite.playing = false
	current_health = max_health
	detection.shape.radius = detection_zone_radius
	
	if has_node("Shield"):
		current_alpha = shield.modulate.a - 1.0/max_health
		true_if_shield = true


func _physics_process(delta : float) -> void:
	
	if PlayerStats.true_if_lumos_active:
		detection.shape.radius = detection_zone_radius
	else:
		detection.shape.radius = detection_zone_radius / 2.5

	if player_body:
		if squeak.is_playing():
			pass
		else:
			squeak.playing = true
		sprite.playing = true
		var move_distance = MAX_SPEED * delta
		move_along_path(move_distance, delta)
	elif true_if_returning:
		sprite.playing = true
		var move_distance = MAX_SPEED * delta
		move_along_path(move_distance, delta)
		if global_position.distance_to(spawn_location) < 10:
			sprite.playing = false
			true_if_returning = false
	else:
		squeak.playing = false
		footstep.playing = false


# check if the player entered the detection zone, use collision mask to look for the player only
func _on_DetectionZone_body_entered(body : PhysicsBody2D) -> void:
	if player_body:
		return

	true_if_returning = false
	sprite.playing = true
	true_if_chasing = true
	light.enabled = true

	player_body = body
	timer_end_chase.stop()


# check if the player exited the detection zone, use collision mask to look for the player only
func _on_DetectionZone_body_exited(body : PhysicsBody2D) -> void:
	sprite.playing = false
	true_if_chasing = false
	light.enabled = false

	if player_body == body:
		player_body = null
		timer_end_chase.start()


# if the the monster is hit by a spell
func _on_Hurtbox_area_entered(_area : Area2D) -> void:
	current_health = current_health - 1
	if true_if_shield:
		current_alpha = current_alpha - 1.0/max_health
		shield.modulate = Color(1, current_alpha, current_alpha, current_alpha)
	if current_health:
		pass
	else:
		queue_free()


func _on_End_of_chase_timeout() -> void:
	true_if_chasing = true
	true_if_returning = true
