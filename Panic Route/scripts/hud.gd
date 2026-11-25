extends CanvasLayer

@onready var lbl_rescatados: Label = $TopBar/PillCiviles/Margin/HBox/VBox/Rescatados
@onready var lbl_tiempo: Label = $TopBar/PillTiempo/Margin/HBox/VBox/Tiempo
@onready var lbl_porcentaje_fuego: Label = $TopBar/PillFuego/Margin/HBox/VBox/HBoxBarra/PorcentajeFuego
@onready var bar_fuego: ProgressBar = $TopBar/PillFuego/Margin/HBox/VBox/HBoxBarra/BarFuego
@onready var btn_pausa_top: Button = $TopBar/BtnPausaTop

@onready var minimapa_canvas: Control = $WrapDerecha/WrapMinimapa/PanelMinimapa/Margin/MinimapaCanvas
@onready var lbl_icono_alerta: Label = $WrapDerecha/PanelAlerta/Margin/HBox/IconoAlerta
@onready var lbl_texto_alerta: Label = $WrapDerecha/PanelAlerta/Margin/HBox/TextoAlerta

@onready var lbl_salud: Label = $PanelSaludBottom/Margin/HBox/Salud
@onready var lbl_bajas: Label = $PanelSaludBottom/Margin/HBox/Bajas

@onready var panel_overlay: PanelContainer = $PanelOverlay
@onready var lbl_titulo: Label = $PanelOverlay/Margin/VBox/Titulo
@onready var lbl_detalle: Label = $PanelOverlay/Margin/VBox/Detalle
@onready var btn_continuar: Button = $PanelOverlay/Margin/VBox/Botones/BtnContinuar
@onready var btn_reiniciar: Button = $PanelOverlay/Margin/VBox/Botones/BtnReiniciar

var _gm: Node = null
var _fuego_mgr: Node = null
var _ultimo_focos_activos := 1
var _ultimo_rescatados := 0
var _ultima_salud := 3


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel_overlay.visible = false
	btn_continuar.pressed.connect(_on_continuar)
	btn_reiniciar.pressed.connect(_on_reiniciar)
	btn_pausa_top.pressed.connect(_on_continuar)
	minimapa_canvas.draw.connect(_dibujar_minimapa)

	await get_tree().process_frame
	_gm = get_tree().get_first_node_in_group("game_manager")
	if _gm != null:
		_gm.estado_actualizado.connect(_on_estado_actualizado)
		_gm.pausa_cambiada.connect(_on_pausa_cambiada)
		_gm.partida_terminada.connect(_on_partida_terminada)

	if get_tree().current_scene != null:
		_fuego_mgr = get_tree().current_scene.get_node_or_null("FuegoManager")


func _process(_delta: float):
	_actualizar_fuego()
	minimapa_canvas.queue_redraw()


func _actualizar_fuego():
	# Porcentaje de avance del fuego
	if _fuego_mgr != null:
		var total_puntos := 0
		for c in _fuego_mgr.get_children():
			if c is Marker3D:
				total_puntos += 1
		var activos := 0
		if "_encendidos" in _fuego_mgr:
			activos = _fuego_mgr._encendidos.size()
		if total_puntos > 0:
			var pct := int(round((float(activos) / float(total_puntos)) * 100.0))
			lbl_porcentaje_fuego.text = "%d%%" % pct
			bar_fuego.value = pct
			if activos > _ultimo_focos_activos:
				_ultimo_focos_activos = activos
				_mostrar_alerta("⚠", "¡El fuego se está expandiendo! (%d%%)" % pct, Color(1.0, 0.76, 0.18))


func _mostrar_alerta(icono: String, texto: String, color_icono: Color):
	lbl_icono_alerta.text = icono
	lbl_icono_alerta.add_theme_color_override("font_color", color_icono)
	lbl_texto_alerta.text = texto


func _dibujar_minimapa():
	var rect_size := minimapa_canvas.size
	if rect_size.x <= 10.0 or rect_size.y <= 10.0:
		return

	# Fondo del radar
	minimapa_canvas.draw_rect(Rect2(Vector2.ZERO, rect_size), Color(0.03, 0.08, 0.16, 0.95), true)

	# Escala del edificio: X en [-20, 20] (40m), Z en [-14, 14] (28m)
	var pad := Vector2(12.0, 12.0)
	var area := rect_size - pad * 2.0
	var map_w := 40.0
	var map_h := 28.0

	# Silueta del edificio y divisiones de habitaciones
	minimapa_canvas.draw_rect(Rect2(pad, area), Color(0.14, 0.28, 0.46, 0.65), true)
	minimapa_canvas.draw_rect(Rect2(pad, area), Color(0.32, 0.62, 0.88, 0.85), false, 1.5)

	# Paredes internas representativas en el minimapa
	var col_pared := Color(0.26, 0.5, 0.74, 0.6)
	var x_w := pad.x + ((20.0 - 8.0) / map_w) * area.x
	var x_e := pad.x + ((20.0 + 11.0) / map_w) * area.x
	var z_n := pad.y + ((14.0 - 7.0) / map_h) * area.y
	var z_s := pad.y + ((14.0 + 7.0) / map_h) * area.y
	minimapa_canvas.draw_line(Vector2(x_w, pad.y), Vector2(x_w, pad.y + area.y), col_pared, 1.2)
	minimapa_canvas.draw_line(Vector2(x_e, pad.y), Vector2(x_e, pad.y + area.y), col_pared, 1.2)
	minimapa_canvas.draw_line(Vector2(pad.x, z_n), Vector2(pad.x + area.x, z_n), col_pared, 1.2)
	minimapa_canvas.draw_line(Vector2(pad.x, z_s), Vector2(pad.x + area.x, z_s), col_pared, 1.2)

	# Núcleo central
	var core_tl := Vector2(
		pad.x + ((20.0 - 4.0) / map_w) * area.x,
		pad.y + ((14.0 - 3.0) / map_h) * area.y
	)
	var core_sz := Vector2((10.0 / map_w) * area.x, (6.0 / map_h) * area.y)
	minimapa_canvas.draw_rect(Rect2(core_tl, core_sz), Color(0.08, 0.16, 0.28, 0.9), true)
	minimapa_canvas.draw_rect(Rect2(core_tl, core_sz), col_pared, false, 1.2)

	# Zona Segura (EXIT) en (17.5, 4.0)
	var exit_pos := Vector2(
		pad.x + ((17.5 + 20.0) / map_w) * area.x,
		pad.y + ((4.0 + 14.0) / map_h) * area.y
	)
	minimapa_canvas.draw_rect(Rect2(exit_pos - Vector2(9, 7), Vector2(18, 14)), Color(0.1, 0.85, 0.4, 0.9), true)

	# Focos de fuego activos
	if _fuego_mgr != null and "_encendidos" in _fuego_mgr:
		for punto in _fuego_mgr._encendidos:
			if is_instance_valid(punto):
				var p3: Vector3 = punto.global_position
				var fp := Vector2(
					pad.x + clampf((p3.x + 20.0) / map_w, 0.0, 1.0) * area.x,
					pad.y + clampf((p3.z + 14.0) / map_h, 0.0, 1.0) * area.y
				)
				minimapa_canvas.draw_circle(fp, 6.5, Color(1.0, 0.25, 0.1, 0.45))
				minimapa_canvas.draw_circle(fp, 4.0, Color(1.0, 0.55, 0.1, 0.95))

	# Civiles en el minimapa
	for c in get_tree().get_nodes_in_group("civiles"):
		if not is_instance_valid(c):
			continue
		var est: int = c.get("estado") if "estado" in c else 0
		if est == 2:
			continue # Ya evacuado
		var cp3: Vector3 = c.global_position
		var cp := Vector2(
			pad.x + clampf((cp3.x + 20.0) / map_w, 0.0, 1.0) * area.x,
			pad.y + clampf((cp3.z + 14.0) / map_h, 0.0, 1.0) * area.y
		)
		var col_c := Color(0.2, 0.95, 0.45) if est != 3 else Color(0.95, 0.2, 0.2)
		minimapa_canvas.draw_circle(cp, 3.5, col_c)

	# Jugador en el minimapa
	var jugador = get_tree().get_first_node_in_group("jugador")
	if is_instance_valid(jugador):
		var jp3: Vector3 = jugador.global_position
		var jp := Vector2(
			pad.x + clampf((jp3.x + 20.0) / map_w, 0.0, 1.0) * area.x,
			pad.y + clampf((jp3.z + 14.0) / map_h, 0.0, 1.0) * area.y
		)
		minimapa_canvas.draw_circle(jp, 5.5, Color(0.2, 0.85, 1.0, 0.4))
		minimapa_canvas.draw_circle(jp, 3.8, Color(0.85, 0.98, 1.0, 1.0))


func _on_estado_actualizado(rescatados: int, eliminados: int, total: int, salud: int, tiempo: float):
	var vivos := maxi(0, total - eliminados)
	lbl_rescatados.text = "%d / %d" % [vivos, total]
	lbl_bajas.text = "Evacuados: %d/%d" % [rescatados, total]

	if rescatados > _ultimo_rescatados:
		_ultimo_rescatados = rescatados
		_mostrar_alerta("✔", "¡Civil puesto a salvo! (%d/%d evacuados)" % [rescatados, total], Color(0.25, 0.95, 0.55))

	if salud < _ultima_salud:
		_ultima_salud = salud
		_mostrar_alerta("🔥", "¡Cuidado! El fuego te está quemando", Color(1.0, 0.35, 0.2))
	else:
		_ultima_salud = salud

	var corazones = ""
	for i in range(salud):
		corazones += "♥ "
	lbl_salud.text = "Salud: " + (corazones.strip_edges() if salud > 0 else "0")

	var mins = int(tiempo) / 60
	var segs = int(tiempo) % 60
	lbl_tiempo.text = "%02d:%02d" % [mins, segs]


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
