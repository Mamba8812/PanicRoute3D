extends Area3D


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D):
	if body.is_in_group("civiles") and body.has_method("evacuar"):
		if body.evacuar():
			var gm = get_tree().get_first_node_in_group("game_manager")
			if gm != null:
				gm.registrar_rescate()
