extends Node

signal estado_actualizado(rescatados: int, eliminados: int, total: int, salud: int, tiempo: float)
signal partida_terminada(victoria: bool, motivo: String, rescatados: int, eliminados: int, total: int, tiempo: float)
signal pausa_cambiada(en_pausa: bool)

var total_civiles = 0
var rescatados = 0
var eliminados = 0
var salud_jugador = 3
var tiempo = 0.0
var juego_terminado = false


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_manager")
	# Esperar un frame para asegurar que todos los civiles de la escena están listos
	await get_tree().process_frame
	total_civiles = get_tree().get_nodes_in_group("civiles").size()
	_emitir_estado()


func _process(delta):
	if juego_terminado:
		return

	if Input.is_action_just_pressed("pausa"):
		alternar_pausa()

	if not get_tree().paused:
		tiempo += delta
		_emitir_estado()


func alternar_pausa():
	if juego_terminado:
		return
	get_tree().paused = not get_tree().paused
	pausa_cambiada.emit(get_tree().paused)


func registrar_rescate():
	if juego_terminado:
		return
	rescatados += 1
	_emitir_estado()
	_verificar_fin()


func registrar_baja():
	if juego_terminado:
		return
	eliminados += 1
	_emitir_estado()
	_verificar_fin()


func actualizar_salud(nueva_salud: int):
	if juego_terminado:
		return
	salud_jugador = max(0, nueva_salud)
	_emitir_estado()
	if salud_jugador <= 0:
		_terminar(false, "El fuego alcanzó al rescatista.")


func _verificar_fin():
	if total_civiles <= 0:
		return
	# Regla del GDD: más del 20% de bajas es derrota inmediata
	if float(eliminados) / float(total_civiles) > 0.2:
		_terminar(false, "Más del 20% de los civiles fueron alcanzados por el fuego.")
		return
	if rescatados + eliminados >= total_civiles:
		_terminar(true, "¡Evacuación completada con éxito!")


func _terminar(victoria: bool, motivo: String):
	juego_terminado = true
	get_tree().paused = true
	partida_terminada.emit(victoria, motivo, rescatados, eliminados, total_civiles, tiempo)


func _emitir_estado():
	estado_actualizado.emit(rescatados, eliminados, total_civiles, salud_jugador, tiempo)
