extends Node

@export_group("Balanceo del Fuego")
## Segundos antes de que aparezca el primer foco en la cocina.
@export var retraso_inicial = 3.0
## Segundos entre cada avance del fuego (subir = más fácil, bajar = más difícil).
@export var intervalo_propagacion = 7.0
## Probabilidad (0.0 a 1.0) de que en un turno el fuego se expanda por 2 rutas a la vez.
@export_range(0.0, 1.0, 0.05) var probabilidad_doble_ruta = 0.45
## Cuántos turnos resiste una puerta cerrada antes de que el fuego la abra y cruce.
@export var resistencia_puerta_cerrada = 1
## Segundos durante los cuales el fuego prioriza quemar oficinas antes de cerrar el Corredor Sur.
@export var tiempo_proteger_corredor_sur = 45.0

@export_group("Referencias")
@export var escena_fuego: PackedScene
@export var punto_inicial: Node3D

var _encendidos: Array[Node3D] = []
var _presion_puertas: Dictionary = {}
var _tiempo = 0.0
var _tiempo_partida = 0.0
var _iniciado = false


func _ready():
	if escena_fuego == null:
		escena_fuego = load("res://escenas/foco_fuego.tscn")


func _process(delta):
	_tiempo += delta
	_tiempo_partida += delta

	if not _iniciado:
		if _tiempo >= retraso_inicial:
			_iniciado = true
			_tiempo = 0.0
			if punto_inicial != null:
				_encender_punto(punto_inicial, 0.0)
		return

	if _encendidos.is_empty():
		return

	if _tiempo >= intervalo_propagacion:
		_tiempo = 0.0
		var cantidad = 2 if randf() < probabilidad_doble_ruta else 1
		for i in range(cantidad):
			_propagar_siguiente()


func _propagar_siguiente():
	var opciones_libres: Array[Dictionary] = []
	var opciones_puerta: Array[Dictionary] = []

	for origen in _encendidos:
		if not is_instance_valid(origen) or not ("vecinos" in origen):
			continue
		for v_path in origen.vecinos:
			var destino: Node3D = origen.get_node_or_null(v_path)
			if destino == null or _encendidos.has(destino):
				continue
			if _ya_en_lista(opciones_libres, destino) or _ya_en_lista(opciones_puerta, destino):
				continue

			var obstaculo = _verificar_obstaculo_entre(origen, destino)
			if obstaculo == null:
				opciones_libres.append({"origen": origen, "destino": destino})
			elif obstaculo.is_in_group("puertas"):
				opciones_puerta.append({"origen": origen, "destino": destino, "puerta": obstaculo})

	# Filtrar Corredor Sur durante el tiempo de protección si hay otras rutas disponibles
	if _tiempo_partida < tiempo_proteger_corredor_sur:
		var sin_sur = opciones_libres.filter(func(d): return not d["destino"].get("es_corredor_sur"))
		if not sin_sur.is_empty():
			opciones_libres = sin_sur

	# 1. Priorizar puntos que están cerca de un civil aún esperando (evita dejar civiles en limbo)
	for op in opciones_libres:
		if _hay_civil_esperando_cerca(op["destino"].global_position, 4.5):
			_encender_punto(op["destino"], 3.0)
			return

	# 2. Si hay caminos abiertos, elegir entre ellos (con variedad para expandir por múltiples rutas)
	if not opciones_libres.is_empty():
		var elegida = opciones_libres[randi() % opciones_libres.size()]
		_encender_punto(elegida["destino"], 3.0)
		return

	# 3. Si los caminos están frenados por puertas cerradas, presionar/abrir la puerta y avanzar
	if not opciones_puerta.is_empty():
		var op = opciones_puerta[0]
		var puerta = op["puerta"]
		var id_p = puerta.get_instance_id()
		var golpes = _presion_puertas.get(id_p, 0) + 1
		_presion_puertas[id_p] = golpes
		if golpes >= resistencia_puerta_cerrada:
			if puerta.has_method("alternar") and not puerta.get("abierta"):
				puerta.alternar()
			_encender_punto(op["destino"], 3.0)
		return

	# 4. Respaldo anti-bloqueo: si ya se encendieron todos los nodos de la ruta y queda un civil esperando aislado
	_consumir_civil_aislado_si_existe()


func _ya_en_lista(lista: Array[Dictionary], destino: Node3D) -> bool:
	for item in lista:
		if item["destino"] == destino:
			return true
	return false


func _hay_civil_esperando_cerca(pos: Vector3, radio: float) -> bool:
	for c in get_tree().get_nodes_in_group("civiles"):
		if is_instance_valid(c) and c.get("estado") == 0:
			if c.global_position.distance_to(pos) <= radio:
				return true
	return false


func _consumir_civil_aislado_si_existe():
	for c in get_tree().get_nodes_in_group("civiles"):
		if is_instance_valid(c) and c.get("estado") == 0:
			var marcador = Marker3D.new()
			add_child(marcador)
			marcador.global_position = Vector3(c.global_position.x, 0.0, c.global_position.z)
			_encender_punto(marcador, 2.5)
			return


func _verificar_obstaculo_entre(a: Node3D, b: Node3D) -> Node3D:
	var mundo = a.get_world_3d()
	if mundo == null:
		return null
	var desde = a.global_position + Vector3(0, 1.2, 0)
	var hasta = b.global_position + Vector3(0, 1.2, 0)
	var query = PhysicsRayQueryParameters3D.create(desde, hasta, 1)
	var resultado = mundo.direct_space_state.intersect_ray(query)
	if resultado.is_empty():
		return null
	return resultado.collider


func _encender_punto(punto: Node3D, preaviso: float):
	_encendidos.append(punto)
	var fuego = escena_fuego.instantiate()
	fuego.tiempo_preaviso = preaviso
	punto.add_child(fuego)
	fuego.position = Vector3.ZERO
