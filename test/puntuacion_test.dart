import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/juego_bloc.dart';
import 'package:tipo/puntuacion.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero_config.dart';
import 'package:tipo/tabla_puntos.dart';

void main() {
  test(
    'una jugada que completa azul suma el primer premio una sola vez',
    () async {
      final tablero = TableroConfig.crearTablero();
      for (final posicion in [
        const Coordenada(2, 0),
        const Coordenada(3, 1),
        const Coordenada(3, 2),
      ]) {
        expect(tablero.agregar(posicion, 1), isTrue);
      }

      final juego = JuegoBloc(tablero, siguiente: (_) => 0);
      addTearDown(juego.dispose);
      expect(juego.puntos, 0);
      expect([juego.dadoA, juego.dadoB], [1, 1]);
      juego.elegirPivote(0);
      expect(juego.colocar(const Coordenada(2, 1)), isTrue);
      expect(juego.puntos, 7);
      expect(juego.puntosPorZona['azul_superior'], 7);

      juego.puntuacion.revisarZonasCompletadas();
      expect(juego.puntos, 7);
      juego.omitir();
      expect(juego.tiradaPendiente, isTrue);
      expect(juego.puntos, 7);
    },
  );

  test('amarillo premia una sola vez al ocupar sus cinco casillas', () {
    final tablero = TableroConfig.crearTablero();
    final puntuacion = PuntuacionPartida(tablero);
    final amarillo = premiosZonas.singleWhere((zona) => zona.id == 'amarillo');
    final posiciones = amarillo.posicionesEn(tablero).toList();
    expect(posiciones, hasLength(5));

    for (var i = 0; i < posiciones.length; i++) {
      expect(tablero.agregar(posiciones[i], i + 1), isTrue);
      puntuacion.revisarZonasCompletadas();
      expect(puntuacion.total, i == 4 ? 8 : 0);
    }
    puntuacion.revisarZonasCompletadas();
    expect(puntuacion.obtenidos, {'amarillo': 8});
  });

  test('las dos zonas verdes puntúan por separado al completarse', () {
    final tablero = TableroConfig.crearTablero();
    final puntuacion = PuntuacionPartida(tablero);
    final verdes = premiosZonas.where(
      (zona) => zona.id == 'verde_izquierdo' || zona.id == 'verde_derecho',
    );

    for (final zona in verdes) {
      expect(zona.posicionesEn(tablero), hasLength(6));
      for (final posicion in zona.posicionesEn(tablero)) {
        expect(tablero.agregar(posicion, 1), isTrue);
      }
      puntuacion.revisarZonasCompletadas();
    }
    expect(puntuacion.obtenidos['verde_izquierdo'], 4);
    expect(puntuacion.obtenidos['verde_derecho'], 4);
    expect(puntuacion.total, 8);
  });

  testWidgets('el panel muestra total y premio cobrado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 205,
            child: TablaPuntos(puntos: 7, obtenidos: {'azul_superior': 7}),
          ),
        ),
      ),
    );

    expect(find.text('Puntos: 7'), findsOneWidget);
    expect(find.text('+7'), findsOneWidget);
    expect(find.byKey(const ValueKey('premio-azul_superior')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'asigna los premios de 1.º, 2.º y 3.º lugar según el orden de finalización entre jugadores',
    () {
      final zonaVerdeDer = premiosZonas.singleWhere(
        (zona) => zona.id == 'verde_derecho',
      );

      final tablero1 = TableroConfig.crearTablero();
      final tablero2 = TableroConfig.crearTablero();
      final tablero3 = TableroConfig.crearTablero();

      for (final pos in zonaVerdeDer.posicionesEn(tablero1)) {
        expect(tablero1.agregar(pos, 1), isTrue);
        expect(tablero2.agregar(pos, 1), isTrue);
        expect(tablero3.agregar(pos, 1), isTrue);
      }

      final puntuacion1 = PuntuacionPartida(
        tablero1,
        tiemposIniciales: const {'verde_derecho': 1000},
      );
      final puntuacion2 = PuntuacionPartida(
        tablero2,
        tiemposIniciales: const {'verde_derecho': 2000},
      );
      final puntuacion3 = PuntuacionPartida(
        tablero3,
        tiemposIniciales: const {'verde_derecho': 3000},
      );

      final participantes = [
        (usuario: 'jugador_1', tiemposZonas: puntuacion1.tiemposCompletado),
        (usuario: 'jugador_2', tiemposZonas: puntuacion2.tiemposCompletado),
        (usuario: 'jugador_3', tiemposZonas: puntuacion3.tiemposCompletado),
      ];

      puntuacion1.sincronizarConRivales(
        usuarioPropio: 'jugador_1',
        rivales: participantes,
      );
      puntuacion2.sincronizarConRivales(
        usuarioPropio: 'jugador_2',
        rivales: participantes,
      );
      puntuacion3.sincronizarConRivales(
        usuarioPropio: 'jugador_3',
        rivales: participantes,
      );

      expect(puntuacion1.posicionesObtenidas['verde_derecho'], 1);
      expect(puntuacion1.obtenidos['verde_derecho'], 4);
      expect(puntuacion1.total, 4);

      expect(puntuacion2.posicionesObtenidas['verde_derecho'], 2);
      expect(puntuacion2.obtenidos['verde_derecho'], 3);
      expect(puntuacion2.total, 3);

      expect(puntuacion3.posicionesObtenidas['verde_derecho'], 3);
      expect(puntuacion3.obtenidos['verde_derecho'], 2);
      expect(puntuacion3.total, 2);
    },
  );
}
