import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/valores_iniciales_bloc.dart';

void main() {
  late ValoresInicialesBloc bloc;

  setUp(() {
    bloc = ValoresInicialesBloc();
  });

  tearDown(() async {
    await bloc.dispose();
  });

  void completar(List<int> numeros) {
    for (var i = 0; i < numeros.length; i++) {
      bloc.actualizar(
        ValoresInicialesBloc.regiones[i],
        numeros[i].toString(),
      );
    }
  }

  test('no permite confirmar sin datos', () {
    expect(bloc.puedeContinuar, isFalse);
    expect(() => bloc.confirmar(), throwsStateError);
  });

  test('cinco números no son suficientes', () {
    completar([1, 2, 3, 4, 5]);

    expect(bloc.puedeContinuar, isFalse);
    expect(() => bloc.confirmar(), throwsStateError);
  });

  test('rechaza números repetidos', () {
    completar([1, 2, 3, 4, 5, 5]);

    expect(bloc.puedeContinuar, isFalse);
    expect(() => bloc.confirmar(), throwsStateError);
  });

  test('rechaza valores fuera del rango y texto inválido', () {
    completar([1, 2, 3, 4, 5, 6]);

    for (final texto in ['0', '7', '-1', 'abc', '2.5', '']) {
      bloc.actualizar('Región 6', texto);

      expect(bloc.puedeContinuar, isFalse);
      expect(() => bloc.confirmar(), throwsStateError);
    }
  });

  test('acepta los seis números en cualquier distribución', () {
    completar([5, 2, 3, 4, 1, 6]);

    expect(bloc.puedeContinuar, isTrue);
    expect(bloc.confirmar(), {
      'Región 1': 5,
      'Región 2': 2,
      'Región 3': 3,
      'Región 4': 4,
      'Región 5': 1,
      'Región 6': 6,
    });
  });

  test('bloquea de nuevo cuando se borra un dato', () async {
    completar([1, 2, 3, 4, 5, 6]);

    final notificacion = expectLater(
      bloc.cambios,
      emits(false),
    );

    bloc.actualizar('Región 3', '');

    expect(bloc.puedeContinuar, isFalse);
    await notificacion;
  });

  test('los datos confirmados son una copia de solo lectura', () {
    completar([1, 2, 3, 4, 5, 6]);
    final guardados = bloc.confirmar();

    expect(
      () => guardados['Región 1'] = 6,
      throwsUnsupportedError,
    );

    bloc.actualizar('Región 1', '');

    expect(guardados['Región 1'], 1);
    expect(bloc.puedeContinuar, isFalse);
  });
}