import 'package:flutter_test/flutter_test.dart';

import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tipo.dart';
import 'package:tipo/valores_iniciales_bloc.dart';

void main() {
  const primera = Coordenada(0, 0);
  const segunda = Coordenada(1, 0);

  late ValoresInicialesBloc bloc;

  setUp(() {
    bloc = ValoresInicialesBloc(
      casillasIniciales: [primera, segunda],
      crearTablero: () => Tablero(
        filas: 1,
        columnas: 3,
        regiones: [
          Region(
            tipo: TipoAzul(),
            coordenadas: [
              primera,
              segunda,
              const Coordenada(2, 0),
            ],
          ),
        ],
      ),
    );
  });

  tearDown(() async {
    await bloc.dispose();
  });

  test('bloquea el avance cuando faltan valores', () {
    expect(bloc.puedeAvanzar, isFalse);
    expect(() => bloc.avanzar(), throwsStateError);

    bloc.actualizar(primera, '3');

    expect(bloc.puedeAvanzar, isFalse);
    expect(() => bloc.avanzar(), throwsStateError);
  });

  test('rechaza texto, espacios y decimales', () {
    bloc.actualizar(primera, '3');

    for (final texto in ['abc', '   ', '3.5']) {
      bloc.actualizar(segunda, texto);

      expect(bloc.puedeAvanzar, isFalse);
      expect(() => bloc.avanzar(), throwsStateError);
    }
  });

  test('rechaza valores que incumplen la regla azul', () {
    bloc.actualizar(primera, '3');
    bloc.actualizar(segunda, '4');

    expect(bloc.puedeAvanzar, isFalse);
    expect(() => bloc.avanzar(), throwsStateError);

    // Se puede corregir el valor sin dejar datos parciales.
    bloc.actualizar(segunda, '3');

    expect(bloc.puedeAvanzar, isTrue);
  });

  test('permite avanzar y conserva los valores iniciales', () {
    bloc.actualizar(primera, '3');
    bloc.actualizar(segunda, '3');

    final tablero = bloc.avanzar();

    expect(tablero.valorEn(primera), 3);
    expect(tablero.valorEn(segunda), 3);
    expect(tablero.valorEn(const Coordenada(2, 0)), isNull);
  });

  test('notifica los cambios y bloquea al borrar un valor', () async {
    final notificaciones = expectLater(
      bloc.cambios,
      emitsInOrder([false, true, false]),
    );

    bloc.actualizar(primera, '3');
    bloc.actualizar(segunda, '3');
    bloc.actualizar(segunda, '');

    expect(bloc.puedeAvanzar, isFalse);
    expect(() => bloc.avanzar(), throwsStateError);

    await notificaciones;
  });
}