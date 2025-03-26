Maze2D es un videojuego de laberintos que permite la visualización de las técnicas empleadas por los algoritmos de búsqueda en Anchura, en Profundidad, de Dijkstra y A Estrella.

Este videojuego permite el registro e inicio de sesión del usuario mediante las credenciales de usuario y contraseña.
El acceso con estos credenciales está permitido unicamente localmente en el dispositivo donde se creo el usuario.
El juego dispone de las siguientes funciones:
- Creación de partidas:
  - Selección del tamaño del laberinto.
  - Selección del algoritmo del jugador en Modo Simulación.
  - Selección del algoritmo del enemigo en Modo Enfrentamiento.
  - Selección del número de juegos de la partida (1, 3 o 5).
- Guardado de partida.
- Reinicio de partida.
- Cambio de configuración.
- Carga de partidas guardadas.

El videojuego Maze2D se puede descargar y ejecutar desde la sección Releases para la versión 1.0 https://github.com/SergioMollo/Maze2D/releases, disponible para el sistema operativo 
Windows en la versión de 64 bits. Para su correcto funcionamiento, es necesario tener descargados los archivos .exe y .dll que se encuentran en la carpeta llamada Maze2D_x64_Windows.zip, 
y asegurándose de ubicarlos en la misma carpeta. Además, se recomienda tener instalado el componente más reciente de Microsoft Visual C++ Redistributable desde la pagina oficial 
https://www.microsoft.com/es-es/download/details.aspx?id=48145, los controladores gráficos actualizados y un sistema operativo basado en 64 bits.

Tras las multiples pruebas realizadas en diferentes ordenadores se han encontrado dificultades de ejecución en algunos de ellos los cuales presentan una tarjeta gráfica NVIDIA (en concreto la tarjeta GeForce RTX 4060) y otros con 
ella integrada en el propio ordenador. Las pruebas realizadas y correctamente funcionales se han realizado en ordenadores con el sistema operativo Windows y las siguientes caracteristicas:
  1. HP con Windows 11 de 8 GB de RAM, con AMD Ryzen 7 5700U y Radeon Graphics.
  2. Lenovo con Windows 8 Pro de 4 GB de RAM, con Intel Celeron.
  3. HP con Windows 10 de 4 GB de RAM, con Intel Core I3-6006U.

La primera interfaz de usuario que aparece al ejecutar el videojuego, es la interfaz de inicio de sesión, donde se debe introducir un nombre de usuario y una contraseña registrados en el 
sistema para proceder a la pantalla principal del videojuego. La primera ejecución del videojuego, requiere de la creación de un nuevo usuario, pues no existe ninguno registrado previamente 
debido al uso de una base de datos local. Para registrar un usuario, se pulsa el botón Registrarse, donde aparece la pantalla de Registro, y se introducen los datos del usuario (nombre, 
usuario y contraseña), con los que posteriormente se podrá iniciar sesión. Una vez registrado al usuario, redirige, de nuevo, a la pantalla inicial, e introduciendo el usuario y contraseña 
creados, aparece la pantalla principal del videojuego.

La pantalla principal del videojuego, muestra varias opciones, como son Crear Partida, Cargar Partida, Configuración. 
Cada una de ellas corresponde a las siguientes acciones:
- Crear Partida: Redirige a la pantalla de creación de la partida, donde se configuran y establecen los datos del juego como el tamaño del laberinto, el numero de juegos, o los algoritmos
  del jugador y del enemigo.
- Cargar Partida: Muestra la pantalla de continuación de partida, con la lista de todas las partidas guardadas por el usuario que ha iniciado sesión en el juego anteriormente, permitiendo
  continuar una partida desde el punto de progreso alcanzado .
- Configuración: Muestra el menú de configuración de resolución de pantalla y volumen de música.
- Salir: Cierra completamente el juego.

Por otro lado, en la pantalla principal aparecen dos menús con las interfaces que representan a cada personaje durante el juego (jugador y enemigo), permitiendo acceder a la pantalla 
de selección de la apariencia de cada uno. 

Para iniciar una partida, se pulsa en el botón de Crear Partida de la pantalla principal, donde aparecerá las opción de configuración del juego. En esta pantalla se configura 
inicialmente el tamaño del laberinto, donde se dispone de tres niveles predefinidos, y un nivel aleatorio, cuyo tamaño se encuentra entre 15x15 y 40x40 casillas. Por otro lado, se configura el 
modo de juego, permitiendo establecer un juego con o sin rival, y en caso de determinar la existencia del enemigo, se establece el algoritmo de búsqueda empleado por el rival, Además, permite 
elegir entre el modo de iteración habilitado o el modo simulación, donde será controlado por la maquina (generando una simulación de los movimientos), para lo cual se podrá establecer un algoritmo 
de búsqueda. Por último, se establece el numero de juegos permitido entre 1, 3 o 5.

Tras configurar los datos de la partida, y pulsando el botón de Crear Partida, se inicia el juego, mostrando el laberinto junto a los personajes, el tiempo y la puntuación. En este momento, 
el juego esta listo e iniciado, por lo que el usuario podrá interactuar con el.
