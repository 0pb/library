extends KinematicBody2D


signal broken_shield
signal on_fireball
signal boss_died


export(int) var ACCELERATION = 10
export(int) var MAX_SPEED = 10
export(int) var max_health = 6
export(int) var shield_max_health = 3


onready var celebration := preload("res://ennemie/Celebration.tscn")
onready var player_node : Node = get_parent().get_node("Player")
onready var shield : Node = get_node("Shield")
onready var light : Node = get_node("Light2D")
onready var base_shield = shield.modulate
onready var current_alpha = base_shield.a
onready var velocity := Vector2.ZERO
onready var fireball_spell = get_node("Spells/Fireball_spell")


var true_if_fireball_cooldown_off : bool = true
var current_shield_health : int
var current_health : float
var _true_if_invicible : bool = false
var speed_of_fireball : int = 800


func _ready() -> void:
	current_health = max_health
	current_shield_health = shield_max_health
	if connect("broken_shield", self, "_on_broken_shield"):
		print("couldn't connect broken shield")


func _physics_process(delta : float) -> void:
	look_at(player_node.global_position)

	# lock on the player and follow it if in detectionzone
	velocity = velocity.move_toward((player_node.global_position - global_position).normalized() 
		* MAX_SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity)

	shield.modulate = Color(1, current_alpha, current_alpha, 1)
	$Sprite.modulate = Color(1, current_health/max_health, current_health/max_health, 1)

	if true_if_fireball_cooldown_off:
		emit_signal("on_fireball")
		true_if_fireball_cooldown_off = false


func _on_broken_shield() -> void:
	$Shield_broke.emitting = true
	$AudioStreamPlayer.play()
	light.modulate = Color(1, current_alpha, current_alpha, 1)
	MAX_SPEED *= 3
	fireball_spell.cooldown = 2
	fireball_spell.speed_of_fireball = speed_of_fireball * 1.2
	

# if hit by a fireball
func _on_Hurtbox_area_entered(_area : Area2D) -> void:
	if _true_if_invicible:
		return
	else:
		if current_shield_health:
			fireball_spell.cooldown = 3
			fireball_spell.speed_of_fireball = speed_of_fireball
			shield.visible = true
			current_shield_health = current_shield_health - 1
			current_alpha = current_alpha - 1.0/shield_max_health
			if !current_shield_health:
				shield.visible = false
				emit_signal("broken_shield")
		else:
			$Boss_page.emitting = true
			current_health = current_health - 1
		
#		emit_signal("on_fireball")
		
		_true_if_invicible = true
		$Invicibility.start(1.0)

	if current_health == 0:
		emit_signal("boss_died")
		
		var confetti_instance = celebration.instance()
		confetti_instance.emitting = true
		confetti_instance.global_position = global_position
		get_parent().call_deferred("add_child", confetti_instance)
		call_deferred("queue_free")


func _on_Invicibility_timeout() -> void:
	_true_if_invicible = false


func _on_Fireball_end_of_cooldown():
	true_if_fireball_cooldown_off = true


func _on_Player_death_player():
	shield.visible = true
	fireball_spell.cooldown = 3
	fireball_spell.speed_of_fireball = speed_of_fireball
	current_shield_health = clamp(current_shield_health + 2, 0, shield_max_health)
	current_alpha = clamp(current_alpha + 2.0/shield_max_health, 0.0, 1.0)


func _on_EasierMode_timeout():
	# if 60s pass, the boss become easier with slower fireball
	speed_of_fireball = 600

