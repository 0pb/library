extends Node2D


"""
set the player on the spawn position
if there are ennemies, create a navigation path between them and the player
"""
onready var spawn_ressource := $Spawn
onready var spawn_position : Vector2 = spawn_ressource.global_position

onready var nav_2d : Navigation2D = get_node("Navigation2D")
onready var line_2d : Line2D = get_node("DebugNavigation") #used for debugging navigation
onready var ennemies_group = get_node("EnnemiesGroup")
onready	var player_instance = get_node("Player")


# loop over the ennemies group, and create a navigation path for each of them
func _physics_process(_delta : float) -> void:
	if ennemies_group.get_child_count() == 0:
		# if no ennemies
		return
	else:
		var new_path
		for ennemy in ennemies_group.get_children():
			if ennemy.true_if_chasing:
				if ennemy.true_if_returning:
					new_path = nav_2d.get_simple_path(ennemy.global_position, ennemy.spawn_location)
				else:
					new_path = nav_2d.get_simple_path(ennemy.global_position, player_instance.global_position)
				ennemy.path = new_path

				# used for debug of navigation
				line_2d.points = new_path


# spawn the player on the spawn location
func _ready() -> void:
	player_instance.global_position = spawn_position


# spawn the player on the spawn location
func _on_Player_death_player() -> void:
	player_instance.global_position = spawn_position
	
