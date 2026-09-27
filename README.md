# Tipo — Brilliant

Interfaz Flutter hasta la selección de los seis números iniciales.

## Uso

1. Toca una de las seis casillas con borde oscuro y signo +.
2. Elige un número del 1 al 6. Puedes volver a tocarla para cambiarlo o borrarlo.
3. Distribuye los seis números sin repetir. Los duplicados muestran un aviso
   y mantienen deshabilitado el botón **Inicio**.
4. Pulsa **Inicio** para guardar los valores en el modelo Tablero.
   Se muestra una confirmación con las coordenadas y se bloquea la selección.

Los datos se conservan en memoria mientras la pantalla está abierta.
El alcance termina en la inicialización: aún no hay tiradas, turnos ni puntuación
de una partida completa.

## Estructura

- `lib/tablero_config.dart`: matriz bidimensional inmutable 7 × 7, paleta
  solicitada y las seis posiciones señaladas en la imagen de referencia.
- `TableroVisual` en `lib/main.dart`: 49 cuadrados con esquinas de 8 px,
  separación de 6 px y ancho adaptable, hasta 540 px.
- `ValoresInicialesBloc`: BLoC local mediante StreamController; valida que estén
  los seis enteros entre 1 y 6 sin repetir y devuelve una copia de solo lectura.
- `Tablero`: almacena los números por Coordenada.
- `Region`: vincula las coordenadas con su Tipo.

La paleta visual usa los hexadecimales pedidos, incluido #E67E22 para Rojo.
No modifica los colores ni las reglas de las clases Tipo existentes.

Las posiciones iniciales son (columna, fila), desde cero:
(2,0), (5,1), (1,3), (4,3), (2,5), (4,6).
Los números no están preasignados: el jugador decide su distribución.

Las regiones se construyen agrupando casillas del mismo color conectadas
horizontal o verticalmente. No se infieren enlaces externos ausentes en la
matriz. Las seis casillas de inicio pertenecen a seis regiones diferentes.
Este modelo sirve para la preparación solicitada; las reglas completas y
conexiones del juego podrán ampliarse al implementar la partida.

## Verificación

```sh
flutter pub get
flutter test
flutter run
```

Las pruebas comprueban la matriz y la paleta exactas, la asignación de regiones,
el almacenamiento, los datos inválidos, el botón Inicio, cambiar/borrar números,
la confirmación y el tamaño cuadrado de las celdas en una pantalla de 360 px.
GitHub Actions ejecuta flutter test en main y en solicitudes hacia main.
