extends Control


"""
main menu node, with 2 buttons for play/quit with signal
"""


export(String, FILE) var path_to_levels_scene = "res://level/levels/level1.tscn"
export(NodePath) var menu_path = ""


onready var menu_ressource : Node = get_node(menu_path)
onready var first_start : bool = true


# load the first level
func start_game() -> void:
	var first_scene = load(path_to_levels_scene)
	var main_scene = first_scene.instance()
	get_parent().get_parent().get_parent().add_child(main_scene)
	get_parent().get_parent().get_parent().get_node("TimeInGame").start()


func _on_Quit_pressed() -> void:
	get_tree().quit()


func _on_Play_pressed() -> void:
	menu_ressource.visible = !menu_ressource.visible

	# unpause the game
	if get_tree().paused:
		get_tree().paused = false

	# load the game the first time the play button is pressed
	if first_start:
		start_game()
		first_start = false


func _ready() -> void:
	# pause_mode on process so it doesn't freeze the menu when the game is paused
	pause_mode = Node.PAUSE_MODE_PROCESS


# pressing escape show the menu and pause the game
func _unhandled_input(_event : InputEvent) -> void:
	if Input.get_action_strength("ui_menu"):
		# unpause/pause the game
		get_tree().paused = !get_tree().paused
		
		# hide or show the menu
		menu_ressource.visible = !menu_ressource.visible


