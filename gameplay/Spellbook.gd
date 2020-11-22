extends StaticBody2D


export(String, "lumos", "fireball") var spell_name = "lumos"


signal book_picked_up


# if the player is near the spellbook, he will "pick it up"
func _on_Area2D_body_entered(_body : Area2D) -> void:
	emit_signal("book_picked_up")
	call_deferred("queue_free")
	

func _ready() -> void:
	# send the signal the book was picked up
	if connect("book_picked_up", get_parent().get_node("Player"), "_on_pickup_item",  [ spell_name ]):
		print("an error occured")
