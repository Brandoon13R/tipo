import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/multijugador_service.dart';

void main() {
  Map<String, dynamic> response({
    required String status,
    required Object? initialValues,
    int? maxPlayers,
    List<Map<String, dynamic>>? players,
    List<Map<String, dynamic>>? opponents,
    String? opponentUsername,
    Map<String, dynamic>? opponentState,
  }) => {
    'code': '123456',
    'status': status,
    'config_id': 'nivel_1',
    'initial_values': initialValues,
    'host_username': 'anfitrion',
    'is_host': false,
    'opponent_connected': true,
    'my_version': 0,
    if (maxPlayers != null) 'max_players': maxPlayers,
    if (players != null) 'players': players,
    if (opponents != null) 'opponents': opponents,
    if (opponentUsername != null) 'opponent_username': opponentUsername,
    if (opponentState != null) 'opponent_state': opponentState,
  };

  test('permite que el segundo jugador configure antes del inicio', () {
    final sala = EstadoSalaMultijugador.fromJson(
      response(status: 'configurando', initialValues: null),
    );

    expect(sala.estado, 'configurando');
    expect(sala.valoresIniciales, isNull);
    expect(sala.maxJugadores, 6);
  });

  test('requiere números iniciales para cargar una partida activa', () {
    expect(
      () => EstadoSalaMultijugador.fromJson(
        response(status: 'activa', initialValues: null),
      ),
      throwsA(isA<MultijugadorException>()),
    );
  });

  test('soporta hasta 6 jugadores por sala y expone los 5 rivales', () {
    final jugadores = [
      for (var i = 1; i <= 6; i++)
        {
          'username': 'jugador_$i',
          'is_host': i == 1,
          'connected': true,
          'ready': true,
          'initial_values': [1, 2, 3, 4, 5, 6],
          'state': {
            'cells': [
              {'x': 2, 'y': 0, 'value': 1},
            ],
            'score': i * 3,
            'turns_played': i,
            'turns_skipped': 0,
            'finished': false,
          },
          'version': 1,
          'eliminated': i == 6,
          'elimination_reason': i == 6 ? 'concesion' : null,
        },
    ];

    final sala = EstadoSalaMultijugador.fromJson(
      response(
        status: 'activa',
        initialValues: [1, 2, 3, 4, 5, 6],
        maxPlayers: 6,
        players: jugadores,
        opponents: jugadores.sublist(1),
      ),
    );

    expect(sala.maxJugadores, 6);
    expect(sala.jugadoresEfectivos.length, 6);
    expect(sala.rivalesEfectivos.length, 5);
    expect(sala.salaLlena, isTrue);
    expect(sala.rivalesEfectivos.first.usuario, 'jugador_2');
    expect(sala.rivalesEfectivos.first.puntos, 6);
    expect(sala.rivalesEfectivos.last.usuario, 'jugador_6');
    expect(sala.rivalesEfectivos.last.eliminado, isTrue);
    expect(sala.rivalesEfectivos.last.motivoEliminacion, 'concesion');
  });

  test('rechaza salas que superan el límite de 6 jugadores', () {
    final sieteJugadores = [
      for (var i = 1; i <= 7; i++)
        {
          'username': 'jugador_$i',
          'is_host': i == 1,
          'connected': true,
          'ready': true,
          'initial_values': [1, 2, 3, 4, 5, 6],
        },
    ];

    expect(
      () => EstadoSalaMultijugador.fromJson(
        response(
          status: 'activa',
          initialValues: [1, 2, 3, 4, 5, 6],
          players: sieteJugadores,
        ),
      ),
      throwsA(isA<MultijugadorException>()),
    );

    expect(
      () => EstadoSalaMultijugador.fromJson(
        response(
          status: 'activa',
          initialValues: [1, 2, 3, 4, 5, 6],
          maxPlayers: 7,
        ),
      ),
      throwsA(isA<MultijugadorException>()),
    );
  });
}
