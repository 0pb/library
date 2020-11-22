extends Node


onready var fireball = preload("res://ennemie/Fireball.tscn")
onready var boss_node : Node = get_parent().get_parent()
onready var cooldown_fireball = $Cooldown


export(float) var cooldown = 3 # second


var speed_of_fireball : int = 800


signal end_of_cooldown 


func _on_Boss_on_fireball() -> void:
	# create a fireball instance and place it on the player location
	var fireball_instance = fireball.instance()
	var glob_mouse = boss_node.get_parent().get_node("Player").global_position
	var glob_start = boss_node.global_position
	fireball_instance.global_position = glob_start
	fireball_instance.end_position = glob_mouse
	
	# rotate the hitbox on the fireball, resulting in better collision against the wall
	fireball_instance.rotation = boss_node.rotation

	# speed ramps up, giving the fireball a "powerful" feeling
	# the fireball go toward where the player aim
#	var tween = get_node("Tween")
#	tween.interpolate_property(fireball_instance, "position",
#			glob_start, glob_mouse, 1,
#			Tween.TRANS_EXPO, Tween.EASE_IN)
#	tween.start()

	cooldown_fireball.start(cooldown)
	# in case we want to use physics to move the fireball
	fireball_instance.apply_impulse(Vector2(), Vector2(speed_of_fireball, 0).rotated(boss_node.rotation))
	
	# add the fireball to the level, so the fireball is independant of player movement
	boss_node.get_parent().call_deferred("add_child", fireball_instance)


func _on_Cooldown_timeout() -> void:
	emit_signal("end_of_cooldown")
