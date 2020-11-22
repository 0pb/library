extends Particles2D


	


func _on_Timer_timeout() -> void:
	queue_free()


func _on_Startspawn_timeout():
	self.emitting = true
