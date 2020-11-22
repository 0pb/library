extends Node


onready var explosion = preload("res://gameplay/Explosion.tscn")


var speed : int = 1600
var end_position


func _physics_process(_delta):
#	if self.global_position.distance_to(end_position) < 30:
#		call_end()
	pass

# reparent the trail node, so it doesn't disappear the moment the fireball disappear
# create an explosion instance where the fireball disappeared
func call_end() -> void:
	var trail = get_node("Trail")
	
	call_deferred("remove_child", trail)
	trail.position = self.position
	trail.emitting = false
	get_parent().call_deferred("add_child", trail)
	
	var explosion_instance = explosion.instance()
	explosion_instance.position = self.position
	get_parent().call_deferred("add_child", explosion_instance)
	call_deferred("queue_free")


# ramps up the energy property, so the screen doesn't flash white every time
# the fireball is spawned
func _ready() -> void:
	var tween = get_node("Tween")
	
	tween.interpolate_property($Light2D, "energy",
			0.1, 1.5, 
			2,
			Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()


func _on_Area2D_body_entered(body) -> void:
	if not "Player" in body.name and not "FireBall" in body.name:
		call_end()


func _on_DisappearTimer_timeout() -> void:
	call_end()
	queue_free()
