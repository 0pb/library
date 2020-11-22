extends Node2D


onready var current_camera = get_parent().get_node("CameraPlayer")
onready var explosion = get_node("ExplosionRadius")
onready var particle = get_node("Particles2D")
onready var light = get_node("Light2D")


var remember_active : bool


func _ready() -> void:
	# add shake to the camera inverse proportional to the distance (fartest = lesser shake)
	
	remember_active = PlayerStats.true_if_lumos_active
	PlayerStats.true_if_lumos_active = true

	var distance = current_camera.global_position.distance_to(global_position)
	current_camera.trauma += clamp(1 - (distance / 1280.0) + 0.1, 0.0, 1.0)
	
	particle.emitting = true
	
	# ramp down the light
	var tween = get_node("Tween")
	tween.interpolate_property(light, "texture_scale",
			3.0, 0, 
			4,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	

func _on_Timer_timeout() -> void:
	PlayerStats.true_if_lumos_active = remember_active
	queue_free()


func _on_Timer2_timeout() -> void:
	explosion.monitorable = false
	explosion.monitoring = false
