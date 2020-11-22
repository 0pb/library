extends KinematicBody2D


signal death_player
signal lumos
signal fireball


export(NodePath) var remote_transform = ""
export(NodePath) var current_camera_path = "../CameraPlayer"
# movement var
export(int) var ACCELERATION = 400 * 5
export(int) var MAX_SPEED = 300


onready var lumos_spell : Node = get_node("Spells/Lumos_spell/Flashlight")
onready var velocity := Vector2.ZERO


# if the cooldown is off for the fireball
var true_if_fireball_cooldown_off : bool = true
var fireball = PlayerStats.fireball
var lumos =  PlayerStats.lumos
var remember_state : int

# state
enum {MOVE,	SPELL, IDLE}
var state = IDLE

# spell used
enum {LUMOS, FIREBALL}
var current_spell = LUMOS

# put the camera of the level on the player
# the camera is separated to allow easy camera shake for example
func set_camera_for_level() -> void:
	
	var camera_node_path = get_node(current_camera_path).get_path()
	get_node(remote_transform).set_remote_node(camera_node_path)


# if the player is touched, he is teleported back to the spawn of the current level
func die() -> void:
	emit_signal("death_player")


func spell_state(spell_used : int, remembered_state : int) -> void:
	match spell_used:
		LUMOS:
			# if the spellbook was collected or the level allow it
			if lumos:
				lumos_spell.play()
				emit_signal("lumos")
		FIREBALL:
			if fireball and true_if_fireball_cooldown_off:
				emit_signal("fireball")
				true_if_fireball_cooldown_off = false
	state = remembered_state


func move_state(delta : float) -> int:
	$AnimatedSprite.play()
	if $AudioStreamPlayer.is_playing():
		pass
	else:
		$AudioStreamPlayer.playing = true
	look_at(get_global_mouse_position())
	
	# move toward the cursor position on click
	velocity = velocity.move_toward((get_global_mouse_position() - global_position).normalized() 
		* MAX_SPEED, ACCELERATION * delta)
	
	velocity = move_and_slide(velocity)
	
	return MOVE


func idle_state(delta : float) -> int:
	$AudioStreamPlayer.playing = false
	$AnimatedSprite.stop()
	look_at(get_global_mouse_position())
	velocity = Vector2.ZERO
#	velocity = move_and_slide(velocity)
	return IDLE


func _on_Fireball_spell_end_of_cooldown() -> void:
	true_if_fireball_cooldown_off = true


func _input(event : InputEvent) -> void:
	if event.is_action_pressed("spell_1"):
		state = SPELL
		current_spell = LUMOS
	# fire fireball if possible
	elif event.is_action_pressed("spell_2"):
		state = SPELL
		current_spell = FIREBALL
	elif event.is_action_pressed("left_click"):
		state = MOVE
	elif event.is_action_released("left_click"):
		state = IDLE


# allow the use of the spell with the variable given by the spellbook
func _on_pickup_item(spell_name : String) -> void:
	match spell_name:
		"lumos": 
			lumos = true
			PlayerStats.lumos = true
		"fireball":
			fireball = true
			PlayerStats.fireball = true


# placeholder
func _on_Lumos_end_of_cooldown() -> void:
	pass


# if the player get hit by an ennemy or projectile
func _on_Hurtbox_area_entered(_area : Area2D) -> void:
	die()


func _ready() -> void:
	get_node("AudioStreamPlayer").playing = true
	remember_state = IDLE
	set_camera_for_level()
	set_process_input(true) # in case for linux
	if PlayerStats.true_if_lumos_active:
		state = SPELL
		current_spell = LUMOS
	
	if connect("death_player", get_parent(), "_on_Player_death_player"):
		print("an error occured")


func _physics_process(delta : float) -> void:
	match state:
		MOVE:
			remember_state = move_state(delta)
		SPELL:
			spell_state(current_spell, remember_state)
		IDLE:
			remember_state = idle_state(delta)
	



