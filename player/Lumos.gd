extends Node


export(bool) var is_on = false


onready var light_2D_res = preload("Spell_light.tscn")
onready var light_spell = light_2D_res.instance()


signal end_of_cooldown 


# if the player pressed the lumos activation button
func _on_Player_lumos() -> void:
	is_on = !is_on
	if is_on:
		PlayerStats.true_if_lumos_active = true
		light_spell = light_2D_res.instance()
		get_parent().get_parent().add_child(light_spell)
		light_spell.global_position = get_parent().get_parent().global_position
	else:
		PlayerStats.true_if_lumos_active = false
		light_spell.queue_free()
		light_spell = light_2D_res.instance()
	emit_signal("end_of_cooldown")
