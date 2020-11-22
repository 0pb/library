extends Control


func _on_Boss_boss_died():
	visible = true

	var tween = get_node("Tween")
	tween.interpolate_property($ColorRect, "color",
			Color(0, 0, 0, 0), Color(0, 0, 0, 1), 
			4,
			Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.start()
	$Timer.start(8)
	
	$AudioStreamPlayer2D.play()
	

	var time_left = get_tree().get_root().get_node("MainNode").get_node("TimeInGame").time_left
	$Container/CenterContainer2/VBoxContainer/Label2.text = "You beat the game in : " + str(3600 - time_left) + " seconds"
	print(3600 - time_left, "second")


func _on_Timer_timeout():
	get_tree().quit()
