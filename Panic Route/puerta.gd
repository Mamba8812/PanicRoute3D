extends StaticBody3D

@export var duracion = 1.0
@export var tiempo_espera = 3.0
@export var angulo_apertura = 90.0
@export var abierta_al_inicio = false

var abierta = false
var en_movimiento = false

@onready var rot_inicial_y = rotation.y
@onready var collision_shape = $CollisionShape3D

func _ready():
	if abierta_al_inicio:
		abierta = true
		rotation.y = rot_inicial_y + deg_to_rad(angulo_apertura)
		collision_shape.disabled = true 


func alternar():
	if en_movimiento:
		return
	
	en_movimiento = true
	abierta = not abierta
	
	if abierta:
		collision_shape.disabled = true

	var destino_angulo = rot_inicial_y + deg_to_rad(angulo_apertura) if abierta else rot_inicial_y
	
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", destino_angulo, duracion)
	await tween.finished
	
	if not abierta:
		collision_shape.disabled = false
	
	en_movimiento = false
	
	if abierta:
		await get_tree().create_timer(tiempo_espera).timeout
		
		if abierta and not en_movimiento:
			alternar()
