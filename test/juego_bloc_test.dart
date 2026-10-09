import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/juego_bloc.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero_config.dart';

class DadosFijos {
  DadosFijos(this.valores);
  final List<int> valores;
  int indice = 0;

  int nextInt(int max) {
    expect(max, 6);
    return valores[indice++ % valores.length] - 1;
  }
}

void main() {
  const a = Coordenada(2, 0);
  const b = Coordenada(5, 1);

  JuegoBloc partida({List<int> dados = const [1, 5]}) {
    final tablero = TableroConfig.crearTablero();
    expect(tablero.agregar(a, 1), isTrue);
    expect(tablero.agregar(b, 5), isTrue);
    return JuegoBloc(tablero, siguiente: DadosFijos(dados).nextInt);
  }

  test('lanza automáticamente y el pivote ilumina casillas válidas', () async {
    final juego = partida();
    addTearDown(juego.dispose);
    expect([juego.dadoA, juego.dadoB], [1, 5]);
    expect(juego.tiradaPendiente, isTrue);
    expect(juego.casillasIluminadas, isEmpty);

    juego.elegirPivote(0);
    expect(juego.valorAColocar, 5);
    expect(juego.casillasIluminadas, contains(const Coordenada(1, 0)));
    expect(juego.casillasIluminadas, contains(const Coordenada(3, 0)));
    expect(juego.casillasIluminadas, isNot(contains(const Coordenada(2, 1))));
    expect(juego.colocar(const Coordenada(2, 1)), isFalse);
    expect(juego.colocar(const Coordenada(1, 0)), isTrue);

    expect(juego.tablero.valorEn(const Coordenada(1, 0)), 5);
    expect(juego.turnosJugados, 1);
    expect([juego.dadoA, juego.dadoB], [1, 5]);
    expect(juego.pivote, isNull);
    expect(juego.tiradaPendiente, isTrue);
  });

  test('omitir conserva el tablero y genera el siguiente par', () async {
    final juego = partida(dados: [1, 5, 2, 2]);
    addTearDown(juego.dispose);
    juego.elegirPivote(1);
    expect(juego.valorAColocar, 1);
    final antes = juego.tablero.datos;

    juego.omitir();
    expect(juego.tablero.datos, antes);
    expect(juego.turnosOmitidos, 1);
    expect(juego.pivote, isNull);
    expect(juego.casillasIluminadas, isEmpty);
    expect([juego.dadoA, juego.dadoB], [2, 2]);
    expect(juego.tiradaPendiente, isTrue);

    juego.elegirPivote(0);
    expect(juego.valorAColocar, 2);
    juego.omitir();
    expect([juego.dadoA, juego.dadoB], [1, 5]);
    expect(juego.turnosOmitidos, 2);
  });

  test('una colocación inválida conserva los dados actuales', () async {
    final juego = partida(dados: [1, 5, 2, 2]);
    addTearDown(juego.dispose);
    expect(juego.colocar(const Coordenada(0, 0)), isFalse);
    expect(() => juego.elegirPivote(2), throwsStateError);
    juego.elegirPivote(0);
    expect(juego.colocar(const Coordenada(2, 1)), isFalse);
    expect([juego.dadoA, juego.dadoB], [1, 5]);
    expect(juego.turnosJugados, 0);

    juego.omitir();
    expect([juego.dadoA, juego.dadoB], [2, 2]);
  });

  test('sólo ilumina casillas libres y respeta la regla de color', () async {
    final juego = partida(dados: [1, 1]);
    addTearDown(juego.dispose);
    juego.elegirPivote(0);
    final posibles = juego.casillasIluminadas;
    expect(posibles, contains(const Coordenada(2, 1)));
    expect(posibles, isNot(contains(a)));
    expect(posibles, isNot(contains(const Coordenada(3, 1))));
    expect(juego.colocar(const Coordenada(2, 1)), isTrue);
    expect(juego.tablero.valorEn(const Coordenada(2, 1)), 1);
    expect(juego.pivote, isNull);
    expect([juego.dadoA, juego.dadoB], [1, 1]);
  });
}
