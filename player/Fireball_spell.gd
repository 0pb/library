extends Node


onready var fireball = preload("res://player/Fireball.tscn")
onready var player_node : Node = get_parent().get_parent()
onready var cooldown_fireball = $Cooldown


export(float) var cooldown = 1.0 # second


signal end_of_cooldown 


# if the player pressed the fireball activation button
func _on_Player_fireball() -> void:
	
	# create a fireball instance and place it on the player location
	var fireball_instance = fireball.instance()
	var glob_mouse = player_node.get_global_mouse_position()
	var glob_start = player_node.global_position
	fireball_instance.end_position = glob_mouse
	fireball_instance.global_position = glob_start
	
	# rotate the hitbox on the fireball, resulting in better collision against the wall
	fireball_instance.rotation = player_node.rotation

	# speed ramps up, giving the fireball a "powerful" feeling
	# the fireball go toward where the player aim
#	var tween = get_node("Tween")
#	tween.interpolate_property(fireball_instance, "position",
#			glob_start, glob_mouse, 1,
#			Tween.TRANS_EXPO, Tween.EASE_IN)
#	tween.start()

	# in case we want to use physics to move the fireball
	fireball_instance.apply_impulse(Vector2(), Vector2(fireball_instance.speed, 0).rotated(player_node.rotation))
	
	cooldown_fireball.start(cooldown)
	
	# add the fireball to the level, so the fireball is independant of player movement
	player_node.get_parent().call_deferred("add_child", fireball_instance)


func _on_Cooldown_timeout() -> void:
	emit_signal("end_of_cooldown")
