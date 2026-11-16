# Concepto Videojuego 3D

## Página 1

DOCUMENTO DE CONCEPTO – CORTE 1: "PANIC ROUTE" 
 
 
Estudiantes 
Oscar Ferney Rodríguez Pabon 
Manuela Alejandra Medina Barbosa 
 
Profesor 
Álvaro Triana Sánchez 
 
Materia 
Diseño y desarrollo de videojuegos.  Desarrollo conceptual 
Cuarto semestre  
Grupo 10 
Universidad 
Uniempresarial 
Fecha 
Octubre 2026 
 
 
 
 
 
 
 
 
 
 
 

---

## Página 2

 
 
 
1. Ficha 
- Título del juego: Panic Route 3D 
- Género y subgénero: Gestión de Flujo y Evacuación en Tiempo Real (RTS 
Táctico / Puzle de Emergencia) 
- Plataforma: PC 
- Motor: Godot Engine (3D)    
- Duración de una partida o sesión de juego: 3 a 5 minutos por nivel. 
- Integrantes del equipo y roles (Taller 2): 
- Integrante 1: Oscar Ferney Rodriguez Pabon → Rol 1 (Género, Referentes, 
Mecánicas) 
- Integrante 2: Mnauela Alejandra Medina Barbosa →  Rol 2 (Narrativa y 
Mundo, Ciclo del juego e Intención Visual). 
 
2. El juego en una frase 
 
- Posicionamiento:  
"Es como un Mini Motorways con la presión cronometrada de Overcooked!, para 
jugadores que disfrutan resolver rompecabezas logísticos con evacuación en tiempo 
real." 
 
- Estética principal y secundaria (MDA): 
  
- Principal — Reto: El jugador experimenta la tensión intelectual constante de 
mantener un sistema de evacuación funcionando bajo presión, sintiendo alivio y 
satisfacción cuando logra sincronizar el flujo perfecto antes de que el fuego 
alcance a los civiles. 
  
- Secundaria — Sometimiento / Control: Inmersión tranquila al diseñar una red 
eficiente y observar cómo la multitud fluye de manera ordenada hacia la 
seguridad. 
 
3. Jugador objetivo  
 
- Perfil y hábitos: Personas aficionadas a los juegos de estrategia ligera y puzles 
urbanos. Sesiones de juego cortas (de 5 a 15 minutos). 
 

---

## Página 3

- Otros juegos que juega: Mini Motorways, Cities: Skylines, Overcooked! 2, 
Clash Royale. 
 
- Taxonomía de Bartle: Triunfador / Explorador. El Triunfador busca la 
eficiencia absoluta (evacuar el 100% sin bajas y dominar el cronómetro); el 
Explorador analiza el comportamiento de la multitud ante bloqueos y cuellos de 
botella en la red de navegación. 
 
- Modelo Hexad de Marczewski: Filántropo / Triunfador. El Filántropo se conecta 
con el propósito humanitario de proteger y salvar vidas; el Triunfador se motiva 
por superar los retos lógicos del mapa. 
 
- Relación con la estética: Este perfil explica la búsqueda de la estética de Retro y 
Control, ya que disfrutan optimizando sistemas lógicos bajo restricciones severas 
de tiempo. 
 
4. Género y Referentes  
 
- Género justificado por las acciones: Es un juego de Gestión de Flujos y 
Estrategia en Tiempo Real porque las acciones directas del jugador consisten en 
manipular activamente la infraestructura del entorno (puertas, barreras, señales) 
para reorientar multitudes automatizadas en un plano 3D. 
 
- Convenciones del género: 
 
- Control directo e individual de unidades: La rompe. El jugador no puede 
hacer clic en personajes individuales; interactúa exclusivamente con el entorno 
estático. 
- Economía de recursos complejos (oro/materiales): La rompe / Simplifica. 
No hay recolección; el recurso a gestionar es el tiempo y la infraestructura 
disponible. 
- Carriles y navegación autónoma de multitudes: La respeta. Las entidades 
se desplazan de forma autónoma usando mallas de navegación 
(NavigationServer3D). 
- Progresión RPG / Metajuego de estadísticas: La rompe. Las partidas se 
juegan con parámetros simétricos y fijos para enfocarse en la táctica pura. 
- Amenaza ambiental restrictiva: La respeta. El fuego limita y destruye 
permanentemente el espacio de juego. 
 
- Tres Referentes: 
- Mini Motorways: Se toma la claridad visual en la gestión de redes y flujos 
urbanos; no se toma la generación procedural infinita. 

---

## Página 4

- Clash Royale: Se toma la economía de gestión por segundo y la toma de 
decisiones bajo presión de tiempo; no se toma el PvP en red ni cofres. 
- Overcooked! 2: Se toma la tensión operativa en espacios confinados y el 
retardo en las acciones; no se toma el multijugador local ni la temática de 
cocina. 
 
- Competidor más cercano y diferenciador: Mini Motorways (2019, ~$10 USD, 
equipo pequeño). Alguien que ya posee ese juego jugaría el nuestro porque Panic 
Route 3D introduce una narrativa de emergencia inmersiva en entorno 3D donde 
la amenaza activa del fuego destruye físicamente las rutas, exigiendo decisiones 
críticas de bloqueo estructural en tiempo real. 
 
5. Sinopsis y Mundo  
 
- Logline: "Un operador de emergencias urbanas debe reconfigurar las rutas de 
evacuación de un complejo industrial antes de que el fuego descontrolado aisle y 
consuma a los civiles atrapados." 
 
- Sinopsis : 
 
 En el año 2042, el distrito tecnológico de una megaciudad sufre un fallo sistémico 
crítico en su red de contención de incendios, dejando a decenas de trabajadores 
desorientados en el interior de un complejo industrial. El conflicto principal surge 
cuando los pasillos y vías de escape comienzan a colapsar debido al avance 
implacable del fuego, que destruye de manera permanente las estructuras. La 
historia sigue al Operador de Sistemas de Seguridad desde la sala de control 
central, cuya única herramienta es la interfaz remota de puertas cortafuegos, 
esclusas y paneles de señalización. Sin poder abandonar su puesto ni guiar 
manualmente a los trabajadores, su misión es diseñar un flujo de evacuación 
perfecto y dinámico. A medida que los minutos pasan y el calor extremo funde los 
accesos principales, el margen de error se reduce drásticamente, convirtiendo cada 
decisión en un dilema crítico para evitar una tragedia corporativa masiva. 
 
- Protagonista: Operador de la torre de control de seguridad.  
- Deseo: Evacuar con vida al 100% de los empleados.  
- Obstáculo: El fuego implacable, la congestión de las rutas y el retardo mecánico 
de las puertas.  
- Capacidad exclusiva: Posee acceso maestro para conmutar el estado de puertas 
de seguridad a distancia. 
 
 

---

## Página 5

- Reglas del mundo que también son mecánicas: 
- Infraestructura automatizada: Las puertas se operan mediante consola 
remota (Mecánica de conmutación con retardo de 1.5s). 
- Propagación térmica letal: El fuego destruye una casilla de forma 
permanente cada 3 segundos. 
- Pánico masivo por saturación: Si se agrupan más de 5 civiles en una celda, 
su velocidad cae un 50%. 
 
 
- Estructura narrativa y dónde se cuenta: Lineal por niveles (escenarios de 
emergencia con dificultad progresiva). Se cuenta a través del ambiente (paredes 
con hollín, luces rojas de emergencia), los objetos (terminales de control), los 
textos de interfaz (mensajes de estado breves) y la mecánica (la urgencia del fuego 
transmite la narrativa jugable). 
 
6. Mecánicas y Controles 
 
 Mecánicas definitivas (Reglas con números - Condición y Efecto): 
 
- Avance de la Amenaza: Si transcurren 3 segundos de juego, el sistema 
incrementa en 1 casilla la posición de la celda afectada por el fuego, 
convirtiéndola en un obstáculo permanente e intransitable. 
 
- Congestión de Multitud: Si en una misma celda del mapa se acumulan 5 o más 
civiles simultáneamente, la velocidad de movimiento de todo ese grupo se reduce 
automáticamente en un 50% (de 1.5 m/s a 0.75 m/s). 
 
- Retardo de Conmutación: Si el jugador hace clic en una puerta o barrera para 
cambiar su estado (abrir/cerrar), la acción entra en un estado de espera de 1.5 
segundos antes de aplicarse físicamente en el entorno. 
 
- Condición de Derrota: Si el número de civiles eliminados o alcanzados por el 
fuego supera el 20% del total inicial de la oleada, la partida termina 
inmediatamente con pantalla de derrota. 
 
- Condición de Victoria: Si el 100% de los civiles habilitados en el nivel alcanzan 
la zona segura antes de que el fuego destruya las salidas principales, la partida se 
declara como victoria total. 
 
- Tabla de controles 
 
 
 

---

## Página 6

 
Acción 
 
Tecla o Botón 
 
Comportamiento 
 
Seleccionar / Alternar 
Puerta 
 
Botón Izquierdo del 
Ratón (Click) 
 
Al presionar una sola 
vez sobre el objeto 
interactivo. 
 
Mover Cámara / Rotar 
Vista 
 
Botón Derecho del 
Ratón / Rueda 
 
Mantener presionado 
para paneo y zoom 
cenital. 
 
Pausa Táctica Tecla ESPACIO Presionar para congelar 
el tiempo y planificar 
rutas. 
 
-  
-  
-  
 
7. Ciclo Principal y Progresión 
- Ciclo principal: 
 
- Ciclo de progresión 


---

## Página 7

 
- Cambios entre la primera y quinta partida: En la primera partida el mapa es lineal 
con un solo punto de conflicto y fuego lento; en la quinta partida el complejo 
arquitectónico incluye múltiples bifurcaciones simultáneas, mayor densidad de civiles 
y una velocidad de propagación del fuego acelerada que exige multitarea táctica. 
 
 
8. El Primer Minuto  
 
- 00:00 - 00:10: La cámara cenital enfoca el plano general del edificio en estilo 
Low Poly. Aparecen los primeros civiles saliendo de las oficinas en orden y de 
color azul neutral. 
- 00:10 - 00:30: El jugador observa el movimiento natural sin instrucciones 
escritas; nota cómo los civiles siguen los pasillos principales hacia la salida verde 
inferior. 
- 00:30 - 00:60: Un indicador sonoro y visual avisa de un foco de fuego en el sector 
norte. El jugador comprende intuitivamente que debe hacer clic en la puerta lateral 
para abrir una ruta alternativa antes de que el fuego bloquee el paso. 
 
 
9. Intención visual 
 
- Estilo: Low Poly de sombreado plano (Flat-shaded Low Poly) con geometrías 
limpias y siluetas muy contrastadas; ideal para garantizar lectura táctica 
instantánea desde una perspectiva cenital. 
 
- Paleta de 5 colores: 
#2B2D42 (Gris oscuro estructural: paredes y suelo base). 
#8D99AE (Gris acero: pasillos seguros). 
#EF233C (Rojo intenso: celdas afectadas por fuego y peligro). 
#06D6A0 (Verde esmeralda: zonas seguras de evacuación). 


---

## Página 8

#3A86FF (Azul corporativo: civiles en tránsito). 
  
- Dos referencias visuales: Mini Motorways (simplicidad geométrica de redes) y 
Overcooked! 2 (claridad cenital de escenarios). 
 
- Atmósfera de la luz: Luz ambiental neutra y fría (tono gris clínico, 5500K) en el 
interior del edificio que contrasta drásticamente con un brillo cálido y anaranjado 
(#FF7B00) en las zonas donde se propaga el fuego, generando alerta visual 
inmediata. 
 
- Comunicación visual para Programación Gráfica: 
- Peligro (Fuego): Partículas rojas/naranjas con parpadeo rápido y luz emisiva 
creciente medio segundo antes de propagarse. 
- Congestión (Cuello de botella): Cuando un grupo supere 5 civiles en una 
celda, los personajes cambian a tono ámbar (#FFB703) con icono flotante de 
exclamación. 
- Interacción de Puertas: Al hacer clic en un interruptor, la puerta muestra una 
animación de parpadeo intermitente durante 1.5 segundos antes de cambiar su 
estado físico. 
 
 
10. Alcance 
 
 
Entra (Sí se desarrollará) 
 
No entra (Fuera de alcance) 
Sistema de navegación por celdas 
(NavigationServer3D) 
Multijugador en línea 
Mecánica de propagación de fuego 
automatizada 
Control directo o selección individual de 
civiles 
Sistema de conmutación de puertas con 
retardo de 1.5s 
Sistema de físicas de masas complejas 
(RigidBody3D). 
Interfaz cenital con paleta de colores 
contrastada 
Pisos múltiples o navegación vertical en 
3D. 
 
Tres niveles jugables con dificultad 
progresiva 
 
 
 
11.  Anexo IA 
 
- Enlace conversación en Gemini:  https://share.gemini.google/TZgqCvl66cms 