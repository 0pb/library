extends Control


onready var boss_node = get_parent().get_parent().get_node("Boss")
onready var health_bar = get_node("Container/CenterContainer/VBoxContainer/Health")
onready var shield_bar = get_node("Container/CenterContainer/VBoxContainer/Shield")


var current_shield_health
var current_health


func _ready():

#	current_shield_health = boss_node.current_shield_health
#	current_health  = boss_node.current_health

	health_bar.min_value = 0.0
	health_bar.max_value = boss_node.max_health
	shield_bar.min_value = 0.0
	shield_bar.max_value = boss_node.shield_max_health


func _physics_process(_delta):
	health_bar.value = boss_node.current_health
	if boss_node.current_shield_health:
		shield_bar.show()
		shield_bar.value = boss_node.current_shield_health
	else:
		shield_bar.hide()


func _on_Boss_boss_died():
	queue_free()
