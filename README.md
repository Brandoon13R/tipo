# tipo

Proyecto Flutter con reglas por color, regiones y un modelo de tablero.

## Entrega: tablero, zonas y pruebas

- **Tablero** (`lib/tablero.dart`) almacena los números de cada casilla en
  un `Map<Coordenada, int>` privado y valida cada jugada antes de guardarla.
- **Region** (`lib/region.dart`) es la clase que une el tablero con las zonas:
  cada región asocia un `Tipo` con un conjunto de `Coordenada`.
  El tablero recibe esas regiones y localiza la correspondiente a cada casilla.
- **Coordenada** representa una posición: `x` es la columna e `y` es la fila,
  ambas desde cero. Su igualdad y hash permiten consultar una misma casilla
  usando distintas instancias con los mismos valores.
- **Tipo** (`lib/tipo.dart`) contiene las reglas existentes de cada color.

Los datos se guardan **en memoria durante la partida**; no hay persistencia
en disco ni base de datos. Esta entrega corresponde al modelo de datos.
La pantalla inicial de Flutter aún muestra el ejemplo original.

### Ejemplo

```dart
import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tipo.dart';

final zonaAzul = Region(
  tipo: TipoAzul(),
  coordenadas: [Coordenada(0, 0), Coordenada(1, 0)],
);
final tablero = Tablero(filas: 1, columnas: 2, regiones: [zonaAzul]);

tablero.agregar(Coordenada(0, 0), 3); // true: guarda el dato.
tablero.agregar(Coordenada(1, 0), 2); // false: azul exige iguales.
tablero.agregar(Coordenada(1, 0), 3); // true.
tablero.valorEn(Coordenada(0, 0)); // 3.
tablero.regionEn(Coordenada(0, 0)); // zonaAzul.
```

### Criterios de esta implementación

- Dimensiones configurables y positivas; regiones no vacías y sin solaparse.
- Las casillas sin región no admiten jugadas.
- No se permite sobrescribir una casilla ni jugar fuera del tablero.
- Se conservan las reglas y los valores permitidos por los tipos existentes.
- Una jugada rechazada no altera los datos.
- Las colecciones expuestas son de solo lectura; `datos` devuelve una copia.
- `reiniciar()` vacía los datos sin borrar las regiones.

### Pruebas

Se necesita Flutter con Dart compatible con `^3.11.1`, según `pubspec.yaml`.

```sh
flutter pub get
flutter test
```

- `test/tipo_test.dart`: reglas de color existentes.
- `test/region_test.dart`: igualdad de coordenadas, vínculo con el tipo,
  regiones vacías y protección de coordenadas.
- `test/tablero_test.dart`: almacenamiento y consulta, validación de colores,
  independencia de zonas, límites, casillas ocupadas, configuración inválida,
  protección de datos y reinicio.

El flujo `.github/workflows/flutter-tests.yml` ejecuta las pruebas en GitHub
Actions al subir esta rama y en solicitudes de incorporación a `main`.
Consultar el resultado de la ejecución antes de integrar.
