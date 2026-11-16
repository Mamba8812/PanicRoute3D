extends StaticBody3D

@export var duracion = 0.35
@export var abierta_al_inicio = false
var abierta = false
var en_movimiento = false

@onready var pos_inicial_y = position.y


func _ready():
	if abierta_al_inicio:
		abierta = true
		position.y = pos_inicial_y - 3.0


func alternar():
	if en_movimiento:
		return

	en_movimiento = true
	abierta = not abierta

	var destino_y = pos_inicial_y - 3.0 if abierta else pos_inicial_y

	var tween = create_tween()
	tween.tween_property(self, "position:y", destino_y, duracion)
	await tween.finished

	en_movimiento = false
