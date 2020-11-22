extends Area2D


export(String, FILE) var path_next_level = ""


func _load_next_scene(scene_name : String = "") -> Node:
	var next_scene := load(scene_name)
	return next_scene.instance()


func _on_Portal_body_entered(_body : PhysicsBody2D) -> void:
	var next_level = _load_next_scene(path_next_level)
	
	# MainNode/level_1/Portal, add new level to MainNode and remove level_1 node
	get_tree().get_root().get_node("MainNode").call_deferred("add_child", next_level)
	
	# free the memory of the current level
	get_parent().get_parent().queue_free()
