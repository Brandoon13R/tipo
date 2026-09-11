import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/tipo.dart';

void main() {
  group('TipoAzul', () {
    test('expone color, descripcion y puntuaciones esperadas', () {
      final tipo = TipoAzul();

      expect(tipo.color, const Color(0xFF0000FF));
      expect(tipo.descripcion, 'Todos los números deben ser iguales');
      expect(tipo.puntuaciones, {
        1: 7,
        2: 5,
        3: 3,
      });
    });

    test('solo acepta elementos iguales o una lista vacía', () {
      final tipo = TipoAzul();

      expect(tipo.esPosibleAgregar([], 1), isTrue);
      expect(tipo.esPosibleAgregar([1, 1, 1], 1), isTrue);
      expect(tipo.esPosibleAgregar([1, 1, 1], 2), isFalse);
      expect(tipo.esPosibleAgregar([1, 2], 1), isFalse);
    });
  });

  group('TipoAmarillo', () {
    test('expone color, descripcion y puntuaciones esperadas', () {
      final tipo = TipoAmarillo();

      expect(tipo.color, Colors.yellow);
      expect(tipo.descripcion, 'Todos los números deben de ser distintos');
      expect(tipo.puntuaciones, {
        1: 8,
        2: 6,
        3: 4,
      });
    });

    test('solo permite agregar un número que aún no existe en la lista', () {
      final tipo = TipoAmarillo();

      expect(tipo.esPosibleAgregar([], 1), isTrue);
      expect(tipo.esPosibleAgregar([1, 2], 3), isTrue);
      expect(tipo.esPosibleAgregar([1, 2], 2), isFalse);
      expect(tipo.esPosibleAgregar([1, 2, 3], 1), isFalse);
    });
  });

  group('TipoRojo', () {
    test('expone color, descripcion y puntuaciones esperadas', () {
      final tipo = TipoRojo();

      expect(tipo.color, const Color(0xFFF44336));
      expect(tipo.descripcion, 'Todos los números deben de ser distintos');
      expect(tipo.puntuaciones, {
        1: 8,
        2: 6,
        3: 4,
      });
    });

    test('permite la lista vacía y rechaza duplicados', () {
      final tipo = TipoRojo();

      expect(tipo.esPosibleAgregar([], 1), isTrue);
      expect(tipo.esPosibleAgregar([1, 2], 3), isTrue);
      expect(tipo.esPosibleAgregar([1, 2], 1), isFalse);
      expect(tipo.esPosibleAgregar([1, 2, 3], 2), isFalse);
    });
  });

  group('TipoVerde', () {
    test('expone color, descripcion y puntuaciones esperadas', () {
      final tipo = TipoVerde();

      expect(tipo.color, const Color(0xFF4CAF50));
      expect(tipo.descripcion, 'Se puede colocar cualquier número');
      expect(tipo.puntuaciones, {
        1: 4,
        2: 3,
        3: 2,
      });
    });

    test('siempre permite agregar cualquier valor', () {
      final tipo = TipoVerde();

      expect(tipo.esPosibleAgregar([], 99), isTrue);
      expect(tipo.esPosibleAgregar([1, 2, 3], 99), isTrue);
      expect(tipo.esPosibleAgregar([1, 2, 3], -1), isTrue);
    });
  });

  group('TipoMorado', () {
    test('expone color, descripcion y puntuaciones esperadas', () {
      final tipo = TipoMorado();

      expect(tipo.color, const Color(0xFF9C27B0));
      expect(tipo.descripcion, 'Máximo dos números diferentes por zona');
      expect(tipo.puntuaciones, {
        1: 8,
        2: 6,
        3: 4,
      });
    });

    test('permite hasta dos números distintos en la zona', () {
      final tipo = TipoMorado();

      expect(tipo.esPosibleAgregar([], 1), isTrue);
      expect(tipo.esPosibleAgregar([1], 2), isTrue);
      expect(tipo.esPosibleAgregar([1, 2], 3), isFalse);
      expect(tipo.esPosibleAgregar([1, 2, 2], 3), isFalse);
    });
  });
}
