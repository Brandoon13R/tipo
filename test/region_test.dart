import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tipo.dart';

void main() {
  group('Coordenada', () {
    test('compara posiciones por valor y permite consultarlas en mapas', () {
      final primera = Coordenada(2, 1);
      final segunda = Coordenada(2, 1);
      expect(primera, segunda);
      expect(primera.hashCode, segunda.hashCode);
      expect({primera: 7}[segunda], 7);
      expect(primera, isNot(const Coordenada(1, 2)));
    });
  });

  group('Region', () {
    test('vincula el tipo con sus coordenadas y elimina duplicados', () {
      final tipo = TipoAzul();
      final region = Region(
        tipo: tipo,
        coordenadas: [Coordenada(0, 0), Coordenada(0, 0)],
      );
      expect(region.tipo, same(tipo));
      expect(region.coordenadas, hasLength(1));
      expect(region.contiene(const Coordenada(0, 0)), isTrue);
      expect(region.contiene(const Coordenada(1, 0)), isFalse);
    });

    test('rechaza una zona sin coordenadas', () {
      expect(
        () => Region(tipo: TipoVerde(), posiciones: []),
        throwsArgumentError,
      );
    });

    test('protege las coordenadas frente a modificaciones externas', () {
      final posiciones = [const Coordenada(0, 0)];
      final region = Region(tipo: TipoVerde(), coordenadas: posiciones);
      posiciones.clear();
      expect(region.coordenadas, hasLength(1));
      expect(() => region.coordenadas.clear(), throwsUnsupportedError);
    });
  });
}
