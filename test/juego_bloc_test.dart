import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/juego_bloc.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero_config.dart';

class DadosFijos {
  DadosFijos(this.valores);
  final List<int> valores;
  int indice = 0;
  @override
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

  test('1 como pivote ilumina vecinos ortogonales válidos para colocar 5',
      () async {
    final juego = partida();
    addTearDown(juego.dispose);
    juego.tirar();
    expect([juego.dadoA, juego.dadoB], [1, 5]);
    expect(juego.casillasIluminadas, isEmpty);
    juego.elegirPivote(0);
    expect(juego.valorAColocar, 5);
    // (2,1) es azul, (1,0) es verde; (3,0) pertenece a morado.
    expect(juego.casillasIluminadas, contains(const Coordenada(1, 0)));
    expect(juego.casillasIluminadas, contains(const Coordenada(3, 0)));
    expect(juego.casillasIluminadas, isNot(contains(const Coordenada(2, 1))));
    expect(juego.casillasIluminadas, isNot(contains(const Coordenada(3, 1))));
    expect(juego.colocar(const Coordenada(2, 1)), isFalse);
    expect(juego.colocar(const Coordenada(1, 0)), isTrue);
    expect(juego.tablero.valorEn(const Coordenada(1, 0)), 5);
    expect(juego.tiradaPendiente, isFalse);
    expect(juego.turnosJugados, 1);
  });

  test('puede elegir el otro pivote o pasar; omitir conserva el tablero',
      () async {
    final juego = partida(dados: [1, 5, 2, 2]);
    addTearDown(juego.dispose);
    juego.tirar();
    juego.elegirPivote(1);
    expect(juego.valorAColocar, 1);
    expect(juego.casillasIluminadas, isNot(contains(a)));
    expect(juego.casillasIluminadas, isNot(contains(const Coordenada(4, 0))));
    final antes = juego.tablero.datos;
    juego.omitir();
    expect(juego.tablero.datos, antes);
    expect(juego.turnosOmitidos, 1);
    expect(juego.casillasIluminadas, isEmpty);
    juego.tirar();
    expect([juego.dadoA, juego.dadoB], [2, 2]);
    juego.elegirPivote(0);
    expect(juego.valorAColocar, 2);
  });

  test('la tirada no cambia hasta colocar u omitir', () async {
    final juego = partida();
    addTearDown(juego.dispose);
    expect(() => juego.omitir(), throwsStateError);
    expect(() => juego.elegirPivote(0), throwsStateError);
    juego.tirar();
    expect(() => juego.tirar(), throwsStateError);
    expect(juego.colocar(const Coordenada(0, 0)), isFalse);
    expect(juego.tiradaPendiente, isTrue);
    juego.omitir();
    expect(juego.tiradaPendiente, isFalse);
  });

  test('sólo ilumina casillas libres y respeta la regla de color', () async {
    final juego = partida(dados: [1, 1]);
    addTearDown(juego.dispose);
    juego.tirar();
    juego.elegirPivote(0);
    final posibles = juego.casillasIluminadas;
    expect(posibles, contains(const Coordenada(2, 1))); // Azul acepta 1.
    expect(posibles, isNot(contains(a))); // Ocupada.
    expect(posibles, isNot(contains(const Coordenada(3, 1)))); // Diagonal.
    expect(juego.colocar(const Coordenada(2, 1)), isTrue);
    expect(juego.tablero.valorEn(const Coordenada(2, 1)), 1);
  });
}
