import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/multijugador.dart';
import 'package:tipo/multijugador_service.dart';

class _FakeMultijugadorService extends MultijugadorService {
  _FakeMultijugadorService(super.supabase, super.token, this.salaActual);

  EstadoSalaMultijugador salaActual;

  @override
  Future<EstadoSalaMultijugador> consultar(String codigo) async => salaActual;

  @override
  Future<EstadoSalaMultijugador> guardarEstado({
    required String codigo,
    required int version,
    required Map<String, dynamic> estado,
  }) async => salaActual;
}

void main() {
  SupabaseClient crearClientePrueba() => SupabaseClient(
    'https://example.supabase.co',
    'test-key',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );

  testWidgets('el segundo jugador ve los pivotes y espera su confirmación', (
    tester,
  ) async {
    final client = crearClientePrueba();
    final sala = EstadoSalaMultijugador(
      codigo: '123456',
      estado: 'configurando',
      configId: 'nivel_1',
      valoresIniciales: null,
      usuarioAnfitrion: 'anfitrion',
      usuarioOponente: 'invitado',
      esAnfitrion: false,
      oponenteConectado: true,
      reclamarDesde: null,
      horaServidor: null,
      horaLocalRecibida: DateTime.now(),
      estadoPropio: null,
      versionPropia: 0,
      estadoOponente: null,
      ganador: null,
      motivoFinalizacion: null,
    );
    final service = _FakeMultijugadorService(client, 'test-token', sala);

    await tester.pumpWidget(
      MaterialApp(
        home: ConfigurarTableroMultijugadorPage(
          service: service,
          salaInicial: sala,
          usuario: 'invitado',
        ),
      ),
    );

    expect(find.text('Nivel 1 · Tu tablero'), findsOneWidget);
    for (final pivot in [
      'celda-2-0',
      'celda-5-1',
      'celda-1-3',
      'celda-4-3',
      'celda-2-5',
      'celda-4-6',
    ]) {
      expect(find.byKey(ValueKey(pivot)), findsOneWidget);
    }
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('iniciar-partida-multijugador')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'permite ver los tableros de otros jugadores, su puntuación y jugadas',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final client = crearClientePrueba();
      final estadoPropio = {
        'cells': [
          {'x': 2, 'y': 0, 'value': 1},
          {'x': 5, 'y': 1, 'value': 2},
          {'x': 1, 'y': 3, 'value': 3},
          {'x': 4, 'y': 3, 'value': 4},
          {'x': 2, 'y': 5, 'value': 5},
          {'x': 4, 'y': 6, 'value': 6},
        ],
        'die_a': 2,
        'die_b': 5,
        'pivot': null,
        'turns_played': 1,
        'turns_skipped': 0,
        'score': 0,
        'finished': false,
      };
      final estadoRivalUno = {
        'cells': [
          {'x': 2, 'y': 0, 'value': 6},
          {'x': 5, 'y': 1, 'value': 5},
          {'x': 1, 'y': 3, 'value': 4},
          {'x': 4, 'y': 3, 'value': 3},
          {'x': 2, 'y': 5, 'value': 2},
          {'x': 4, 'y': 6, 'value': 1},
          {'x': 3, 'y': 0, 'value': 4},
        ],
        'die_a': 1,
        'die_b': 6,
        'pivot': 0,
        'turns_played': 4,
        'turns_skipped': 2,
        'score': 7,
        'finished': false,
      };
      final estadoRivalDos = {
        'cells': [
          {'x': 2, 'y': 0, 'value': 3},
          {'x': 5, 'y': 1, 'value': 1},
          {'x': 1, 'y': 3, 'value': 6},
          {'x': 4, 'y': 3, 'value': 2},
          {'x': 2, 'y': 5, 'value': 4},
          {'x': 4, 'y': 6, 'value': 5},
        ],
        'die_a': 3,
        'die_b': 3,
        'pivot': null,
        'turns_played': 2,
        'turns_skipped': 1,
        'score': 5,
        'finished': false,
      };

      final sala = EstadoSalaMultijugador(
        codigo: '654321',
        estado: 'activa',
        configId: 'nivel_1',
        valoresIniciales: const [1, 2, 3, 4, 5, 6],
        usuarioAnfitrion: 'anfitrion',
        usuarioOponente: 'rival_1',
        esAnfitrion: true,
        oponenteConectado: true,
        reclamarDesde: null,
        horaServidor: DateTime.now(),
        horaLocalRecibida: DateTime.now(),
        estadoPropio: estadoPropio,
        versionPropia: 1,
        estadoOponente: estadoRivalUno,
        ganador: null,
        motivoFinalizacion: null,
        rivales: [
          JugadorMultijugador(
            usuario: 'rival_1',
            esAnfitrion: false,
            conectado: true,
            listo: true,
            valoresIniciales: const [6, 5, 4, 3, 2, 1],
            estado: estadoRivalUno,
          ),
          JugadorMultijugador(
            usuario: 'rival_2',
            esAnfitrion: false,
            conectado: true,
            listo: true,
            valoresIniciales: const [3, 1, 6, 2, 4, 5],
            estado: estadoRivalDos,
            eliminado: true,
            motivoEliminacion: 'concesion',
          ),
        ],
      );
      final service = _FakeMultijugadorService(client, 'test-token', sala);

      await tester.pumpWidget(
        MaterialApp(
          home: PartidaMultijugadorPage(
            service: service,
            salaInicial: sala,
            usuario: 'anfitrion',
          ),
        ),
      );

      expect(find.byKey(const ValueKey('selector-tableros')), findsOneWidget);
      expect(find.text('Nivel 1 · Tu tablero'), findsOneWidget);
      expect(find.byKey(const ValueKey('ver-tablero-rival_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('ver-tablero-rival_2')), findsOneWidget);

      // Cambia a ver el tablero de rival_1
      await tester.tap(find.byKey(const ValueKey('ver-tablero-rival_1')));
      await tester.pump();

      expect(find.text('Nivel 1 · Tablero de rival_1'), findsOneWidget);
      expect(find.text('rival_1: 7 pts'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('tablero-rival-rival_1')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('rival-tabla-puntos')), findsOneWidget);
      expect(find.text('Jugadas: 4 · Omitidas: 2'), findsOneWidget);
      // Verifica que se muestra el número colocado por rival_1 en (3, 0)
      final celdaRival = find.byKey(const ValueKey('celda-rival-3-0'));
      expect(celdaRival, findsOneWidget);
      expect(
        find.descendant(of: celdaRival, matching: find.text('4')),
        findsOneWidget,
      );

      // Cambia a ver el tablero de rival_2 (eliminado por concesión)
      await tester.tap(find.byKey(const ValueKey('ver-tablero-rival_2')));
      await tester.pump();

      expect(find.text('Nivel 1 · Tablero de rival_2'), findsOneWidget);
      expect(find.text('Estado: Eliminado (se rindió)'), findsOneWidget);
      expect(find.text('Jugadas: 2 · Omitidas: 1'), findsOneWidget);

      // Vuelve al tablero propio
      await tester.tap(find.byKey(const ValueKey('volver-tablero-propio')));
      await tester.pump();

      expect(find.text('Nivel 1 · Tu tablero'), findsOneWidget);
    },
  );

  testWidgets(
    'muestra tu tablero y el tablero del rival lado a lado en pantallas anchas',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final client = crearClientePrueba();
      final estadoPropio = {
        'cells': [
          {'x': 2, 'y': 0, 'value': 1},
          {'x': 5, 'y': 1, 'value': 2},
          {'x': 1, 'y': 3, 'value': 3},
          {'x': 4, 'y': 3, 'value': 4},
          {'x': 2, 'y': 5, 'value': 5},
          {'x': 4, 'y': 6, 'value': 6},
        ],
        'die_a': 2,
        'die_b': 5,
        'pivot': null,
        'turns_played': 0,
        'turns_skipped': 0,
        'score': 0,
        'finished': false,
      };
      final estadoRival = {
        'cells': [
          {'x': 2, 'y': 0, 'value': 6},
          {'x': 5, 'y': 1, 'value': 5},
          {'x': 1, 'y': 3, 'value': 4},
          {'x': 4, 'y': 3, 'value': 3},
          {'x': 2, 'y': 5, 'value': 2},
          {'x': 4, 'y': 6, 'value': 1},
        ],
        'die_a': 1,
        'die_b': 4,
        'pivot': null,
        'turns_played': 3,
        'turns_skipped': 1,
        'score': 9,
        'finished': false,
      };

      final sala = EstadoSalaMultijugador(
        codigo: '112233',
        estado: 'activa',
        configId: 'nivel_1',
        valoresIniciales: const [1, 2, 3, 4, 5, 6],
        usuarioAnfitrion: 'anfitrion',
        usuarioOponente: 'rival_1',
        esAnfitrion: true,
        oponenteConectado: true,
        reclamarDesde: null,
        horaServidor: DateTime.now(),
        horaLocalRecibida: DateTime.now(),
        estadoPropio: estadoPropio,
        versionPropia: 1,
        estadoOponente: estadoRival,
        ganador: null,
        motivoFinalizacion: null,
      );
      final service = _FakeMultijugadorService(client, 'test-token', sala);

      await tester.pumpWidget(
        MaterialApp(
          home: PartidaMultijugadorPage(
            service: service,
            salaInicial: sala,
            usuario: 'anfitrion',
          ),
        ),
      );

      expect(find.text('Nivel 1 · Tu tablero'), findsOneWidget);
      expect(find.text('Nivel 1 · Tablero de rival_1'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('tablero-rival-rival_1')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('tabla-puntos')), findsOneWidget);
      expect(find.byKey(const ValueKey('rival-tabla-puntos')), findsOneWidget);
    },
  );

  testWidgets(
    'el lobby muestra hasta 6 jugadores y habilita iniciar cuando todos están listos',
    (tester) async {
      final client = crearClientePrueba();
      final jugadores = [
        for (var i = 1; i <= 6; i++)
          JugadorMultijugador(
            usuario: 'jugador_$i',
            esAnfitrion: i == 1,
            conectado: true,
            listo: true,
            valoresIniciales: const [1, 2, 3, 4, 5, 6],
          ),
      ];
      final sala = EstadoSalaMultijugador(
        codigo: '998877',
        estado: 'configurando',
        configId: 'nivel_1',
        valoresIniciales: const [1, 2, 3, 4, 5, 6],
        usuarioAnfitrion: 'jugador_1',
        usuarioOponente: 'jugador_2',
        esAnfitrion: true,
        oponenteConectado: true,
        reclamarDesde: null,
        horaServidor: DateTime.now(),
        horaLocalRecibida: DateTime.now(),
        estadoPropio: null,
        versionPropia: 0,
        estadoOponente: null,
        ganador: null,
        motivoFinalizacion: null,
        maxJugadores: 6,
        jugadores: jugadores,
        rivales: jugadores.sublist(1),
      );
      final service = _FakeMultijugadorService(client, 'test-token', sala);

      await tester.pumpWidget(
        MaterialApp(
          home: SalaMultijugadorPage(
            service: service,
            salaInicial: sala,
            usuario: 'jugador_1',
          ),
        ),
      );

      expect(find.text('Jugadores en la sala (6/6)'), findsOneWidget);
      expect(find.text('jugador_1 (Anfitrión)'), findsOneWidget);
      expect(find.text('jugador_6'), findsOneWidget);
      final botonIniciar = find.byKey(
        const ValueKey('anfitrion-iniciar-partida'),
      );
      expect(botonIniciar, findsOneWidget);
      expect(tester.widget<FilledButton>(botonIniciar).onPressed, isNotNull);
    },
  );

  testWidgets(
    'comparte las posiciones de cada zona (1.º recibe +4 y 2.º recibe +3 en Verde der.)',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final client = crearClientePrueba();
      // Coordenadas de Verde der. en Nivel 1: (6,1), (5,2), (6,2), (4,3), (5,3), (6,3)
      // Coordenadas de Azul inf. en Nivel 1: (6,4), (5,5), (6,5), (5,6)
      // Coordenadas de Rojo inf. en Nivel 1: (4,4), (5,4), (3,5), (4,5), (3,6), (4,6)
      final estadoJugador1 = {
        'cells': [
          {'x': 2, 'y': 0, 'value': 1},
          {'x': 5, 'y': 1, 'value': 2},
          {'x': 1, 'y': 3, 'value': 3},
          {'x': 4, 'y': 3, 'value': 4},
          {'x': 2, 'y': 5, 'value': 5},
          {'x': 4, 'y': 6, 'value': 6},
          // Completa Verde der.
          {'x': 6, 'y': 1, 'value': 1},
          {'x': 5, 'y': 2, 'value': 2},
          {'x': 6, 'y': 2, 'value': 3},
          {'x': 5, 'y': 3, 'value': 5},
          {'x': 6, 'y': 3, 'value': 6},
          // Completa Azul inf. (todos iguales = 2)
          {'x': 6, 'y': 4, 'value': 2},
          {'x': 5, 'y': 5, 'value': 2},
          {'x': 6, 'y': 5, 'value': 2},
          {'x': 5, 'y': 6, 'value': 2},
        ],
        'die_a': 2,
        'die_b': 5,
        'pivot': null,
        'turns_played': 9,
        'turns_skipped': 0,
        'score': 11,
        'finished': false,
        'zone_times': {
          'verde_derecho': 1000,
          'azul_inferior': 1200,
        },
      };

      final estadoJugador2 = {
        'cells': [
          {'x': 2, 'y': 0, 'value': 1},
          {'x': 5, 'y': 1, 'value': 2},
          {'x': 1, 'y': 3, 'value': 3},
          {'x': 4, 'y': 3, 'value': 4},
          {'x': 2, 'y': 5, 'value': 5},
          {'x': 4, 'y': 6, 'value': 2},
          // Completa Verde der. después que el jugador 1
          {'x': 6, 'y': 1, 'value': 1},
          {'x': 5, 'y': 2, 'value': 4},
          {'x': 6, 'y': 2, 'value': 1},
          {'x': 5, 'y': 3, 'value': 1},
          {'x': 6, 'y': 3, 'value': 5},
          // Completa Rojo inf. (todos distintos: 1, 2, 3, 4, 5, 6)
          {'x': 4, 'y': 4, 'value': 1},
          {'x': 5, 'y': 4, 'value': 5},
          {'x': 3, 'y': 5, 'value': 6},
          {'x': 4, 'y': 5, 'value': 4},
          {'x': 3, 'y': 6, 'value': 3},
        ],
        'die_a': 1,
        'die_b': 4,
        'pivot': null,
        'turns_played': 10,
        'turns_skipped': 0,
        'score': 10,
        'finished': false,
        'zone_times': {
          'verde_derecho': 2000,
          'rojo_inferior': 1500,
        },
      };

      final sala = EstadoSalaMultijugador(
        codigo: '183873',
        estado: 'activa',
        configId: 'nivel_1',
        valoresIniciales: const [1, 2, 3, 4, 5, 6],
        usuarioAnfitrion: 'jugador_izq',
        usuarioOponente: 'jugador_der',
        esAnfitrion: true,
        oponenteConectado: true,
        reclamarDesde: null,
        horaServidor: DateTime.now(),
        horaLocalRecibida: DateTime.now(),
        estadoPropio: estadoJugador1,
        versionPropia: 1,
        estadoOponente: estadoJugador2,
        ganador: null,
        motivoFinalizacion: null,
      );
      final service = _FakeMultijugadorService(client, 'test-token', sala);

      await tester.pumpWidget(
        MaterialApp(
          home: PartidaMultijugadorPage(
            service: service,
            salaInicial: sala,
            usuario: 'jugador_izq',
          ),
        ),
      );

      // Jugador izquierdo: 1.º en Verde der. (+4) y 1.º en Azul inf. (+7) = 11 pts
      expect(find.text('Puntos: 11'), findsOneWidget);
      expect(find.text('Verde der. (1.º)'), findsOneWidget);
      expect(find.text('+4'), findsOneWidget);
      expect(find.text('+7'), findsOneWidget);

      // Jugador derecho: 2.º en Verde der. (+3) y 1.º en Rojo inf. (+6) = 9 pts
      expect(find.text('Puntos: 9'), findsOneWidget);
      expect(find.text('Verde der. (2.º)'), findsOneWidget);
      expect(find.text('+3'), findsOneWidget);
      expect(find.text('+6'), findsOneWidget);
    },
  );
}
