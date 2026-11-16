extends CanvasLayer

@onready var lbl_rescatados: Label = $PanelEstado/Margin/VBox/Rescatados
@onready var lbl_bajas: Label = $PanelEstado/Margin/VBox/Bajas
@onready var lbl_salud: Label = $PanelEstado/Margin/VBox/Salud
@onready var lbl_tiempo: Label = $PanelEstado/Margin/VBox/Tiempo
@onready var panel_overlay: PanelContainer = $PanelOverlay
@onready var lbl_titulo: Label = $PanelOverlay/VBox/Titulo
@onready var lbl_detalle: Label = $PanelOverlay/VBox/Detalle
@onready var btn_continuar: Button = $PanelOverlay/VBox/Botones/BtnContinuar
@onready var btn_reiniciar: Button = $PanelOverlay/VBox/Botones/BtnReiniciar

var _gm: Node = null


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel_overlay.visible = false
	btn_continuar.pressed.connect(_on_continuar)
	btn_reiniciar.pressed.connect(_on_reiniciar)

	await get_tree().process_frame
	_gm = get_tree().get_first_node_in_group("game_manager")
	if _gm != null:
		_gm.estado_actualizado.connect(_on_estado_actualizado)
		_gm.pausa_cambiada.connect(_on_pausa_cambiada)
		_gm.partida_terminada.connect(_on_partida_terminada)


func _on_estado_actualizado(rescatados: int, eliminados: int, total: int, salud: int, tiempo: float):
	lbl_rescatados.text = "Rescatados: %d / %d" % [rescatados, total]
	lbl_bajas.text = "Bajas: %d" % eliminados
	var corazones = ""
	for i in range(salud):
		corazones += "♥ "
	lbl_salud.text = "Salud: " + (corazones.strip_edges() if salud > 0 else "0")
	var mins = int(tiempo) / 60
	var segs = int(tiempo) % 60
	lbl_tiempo.text = "Tiempo: %02d:%02d" % [mins, segs]


func _on_pausa_cambiada(en_pausa: bool):
	panel_overlay.visible = en_pausa
	btn_continuar.visible = true
	lbl_titulo.text = "PAUSA TÁCTICA"
	lbl_detalle.text = "Presiona ESPACIO o Continuar para seguir evacuando."


func _on_partida_terminada(victoria: bool, motivo: String, rescatados: int, eliminados: int, total: int, tiempo: float):
	panel_overlay.visible = true
	btn_continuar.visible = false
	lbl_titulo.text = "¡VICTORIA!" if victoria else "DERROTA"
	var mins = int(tiempo) / 60
	var segs = int(tiempo) % 60
	lbl_detalle.text = "%s\n\nRescatados: %d / %d\nBajas: %d\nTiempo: %02d:%02d" % [motivo, rescatados, total, eliminados, mins, segs]


func _on_continuar():
	if _gm != null:
		_gm.alternar_pausa()


func _on_reiniciar():
	get_tree().paused = false
	get_tree().reload_current_scene()
