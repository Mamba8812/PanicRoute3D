extends StaticBody3D

@export var duracion = 1.5
var abierta = false
var en_movimiento = false

func alternar():
	if en_movimiento:
		return
	
	en_movimiento = true
	abierta = not abierta
	
	# Rota 90 grados en el eje Y (de forma lateral como una bisagra)
	var destino_angulo = deg_to_rad(90.0) if abierta else 0.0
	
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", destino_angulo, duracion)
	await tween.finished
	
	en_movimiento = false
