extends Node

enum Estado { LISTA, ACTIVA, RECARGA }

@export var tecla = "puerta"
@export var duracion = 1.5
@export var recarga = 1.0

@onready var pj = get_parent() # El padre es la Puerta (StaticBody3D)
var estado = Estado.LISTA
var tiempo = 0.0

func _physics_process(delta):
	tiempo -= delta
	match estado:
		Estado.LISTA:
			# Preguntamos por la tecla Y si cumple la regla de proximidad y movimiento
			if Input.is_action_just_pressed(tecla) and puede():
				empezar()
		Estado.ACTIVA:
			if tiempo <= 0.001:
				terminar()
		Estado.RECARGA:
			if tiempo <= 0.001:
				estado = Estado.LISTA

func puede():
	# 1. Buscamos al personaje en la escena principal
	var personaje = get_tree().current_scene.get_node_or_null("Personaje")
	if not personaje:
		return false
		
	# 2. Calculamos la distancia entre ESTA puerta y el personaje
	var distancia = pj.global_position.distance_to(personaje.global_position)
	
	# 3. La regla: Solo puede abrirse si está a menos de 2.5 metros Y la puerta no se está moviendo
	var esta_cerca = distancia < 2.5
	var puerta_quieta = not pj.get("en_movimiento") if pj.has_method("get") else true
	
	return esta_cerca and puerta_quieta

func empezar():
	estado = Estado.ACTIVA
	tiempo = duracion
	print("empieza: ", tecla)

func terminar():
	estado = Estado.RECARGA
	tiempo = recarga
	
	# Llamamos a la función de la puerta para que gire con bisagras
	if pj.has_method("alternar"):
		pj.alternar()
		
	# Imprimimos el estado para la tarea
	if pj.get("abierta"):
		print("abierta")
	else:
		print("cerrada")
		
	print("termina: ", tecla)
