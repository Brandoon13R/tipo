import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

const int kMinJugadoresMultijugador = 2;
const int kMaxJugadoresMultijugador = 6;

class MultijugadorException implements Exception {
  const MultijugadorException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class JugadorMultijugador {
  const JugadorMultijugador({
    required this.usuario,
    required this.esAnfitrion,
    required this.conectado,
    required this.listo,
    this.valoresIniciales,
    this.estado,
    this.version = 0,
    this.eliminado = false,
    this.motivoEliminacion,
    this.reclamarDesde,
  });

  final String usuario;
  final bool esAnfitrion;
  final bool conectado;
  final bool listo;
  final List<int>? valoresIniciales;
  final Map<String, dynamic>? estado;
  final int version;
  final bool eliminado;
  final String? motivoEliminacion;
  final DateTime? reclamarDesde;

  int get puntos => estado?['score'] is int ? estado!['score'] as int : 0;

  int get turnosJugados =>
      estado?['turns_played'] is int ? estado!['turns_played'] as int : 0;

  int get turnosOmitidos =>
      estado?['turns_skipped'] is int ? estado!['turns_skipped'] as int : 0;

  bool get terminado => estado?['finished'] == true;

  factory JugadorMultijugador.fromJson(Map<String, dynamic> json) {
    final usuario = json['username'];
    final esAnfitrion = json['is_host'] ?? false;
    final conectado = json['connected'] ?? false;
    final valores = json['initial_values'];
    final estadoRaw = json['state'];
    final version = json['version'] ?? 0;
    final eliminado = json['eliminated'] ?? false;
    final motivo = json['elimination_reason'];
    final reclamar = json['reconnect_claim_at'];

    final valoresValidos =
        valores == null ||
        (valores is List &&
            valores.length == 6 &&
            valores.every((value) => value is int));
    if (usuario is! String ||
        usuario.isEmpty ||
        esAnfitrion is! bool ||
        conectado is! bool ||
        !valoresValidos ||
        version is! int ||
        eliminado is! bool ||
        (motivo != null && motivo is! String)) {
      throw const MultijugadorException(
        'El servidor devolvió datos de jugador inválidos.',
      );
    }

    Map<String, dynamic>? estado;
    if (estadoRaw != null) {
      if (estadoRaw is Map<String, dynamic>) {
        estado = estadoRaw;
      } else if (estadoRaw is Map) {
        estado = Map<String, dynamic>.from(estadoRaw);
      } else {
        throw const MultijugadorException(
          'El servidor devolvió un estado de jugador inválido.',
        );
      }
    }

    final valoresLista = valores == null
        ? null
        : List<int>.unmodifiable((valores as List).cast<int>());
    final listoRaw = json['ready'];
    final listo = listoRaw is bool
        ? listoRaw
        : (valoresLista != null || estado != null);

    return JugadorMultijugador(
      usuario: usuario,
      esAnfitrion: esAnfitrion,
      conectado: conectado,
      listo: listo,
      valoresIniciales: valoresLista,
      estado: estado,
      version: version,
      eliminado: eliminado,
      motivoEliminacion: motivo as String?,
      reclamarDesde: reclamar is String ? DateTime.tryParse(reclamar) : null,
    );
  }
}

class EstadoSalaMultijugador {
  const EstadoSalaMultijugador({
    required this.codigo,
    required this.estado,
    required this.configId,
    required this.valoresIniciales,
    required this.usuarioAnfitrion,
    required this.usuarioOponente,
    required this.esAnfitrion,
    required this.oponenteConectado,
    required this.reclamarDesde,
    required this.horaServidor,
    required this.horaLocalRecibida,
    required this.estadoPropio,
    required this.versionPropia,
    required this.estadoOponente,
    required this.ganador,
    required this.motivoFinalizacion,
    this.maxJugadores = kMaxJugadoresMultijugador,
    this.jugadores = const [],
    this.rivales = const [],
    this.eliminadoPropio = false,
    this.motivoEliminacionPropio,
  });

  final String codigo;
  final String estado;
  final String configId;
  final List<int>? valoresIniciales;
  final String usuarioAnfitrion;
  final String? usuarioOponente;
  final bool esAnfitrion;
  final bool oponenteConectado;
  final DateTime? reclamarDesde;
  final DateTime? horaServidor;
  final DateTime horaLocalRecibida;
  final Map<String, dynamic>? estadoPropio;
  final int versionPropia;
  final Map<String, dynamic>? estadoOponente;
  final String? ganador;
  final String? motivoFinalizacion;
  final int maxJugadores;
  final List<JugadorMultijugador> jugadores;
  final List<JugadorMultijugador> rivales;
  final bool eliminadoPropio;
  final String? motivoEliminacionPropio;

  /// Lista de rivales en la partida (de 1 a 5 rivales, para un total de hasta 6 jugadores).
  List<JugadorMultijugador> get rivalesEfectivos {
    if (rivales.isNotEmpty) return rivales;
    if (usuarioOponente != null) {
      return [
        JugadorMultijugador(
          usuario: usuarioOponente!,
          esAnfitrion: !esAnfitrion,
          conectado: oponenteConectado,
          listo: estadoOponente != null,
          estado: estadoOponente,
          reclamarDesde: reclamarDesde,
        ),
      ];
    }
    return const [];
  }

  /// Lista completa de jugadores en la sala (hasta 6 jugadores).
  List<JugadorMultijugador> get jugadoresEfectivos {
    if (jugadores.isNotEmpty) return jugadores;
    final propio = JugadorMultijugador(
      usuario: esAnfitrion ? usuarioAnfitrion : (usuarioOponente ?? 'Tú'),
      esAnfitrion: esAnfitrion,
      conectado: true,
      listo: valoresIniciales != null || estadoPropio != null,
      valoresIniciales: valoresIniciales,
      estado: estadoPropio,
      version: versionPropia,
      eliminado: eliminadoPropio,
      motivoEliminacion: motivoEliminacionPropio,
    );
    return [propio, ...rivalesEfectivos];
  }

  bool get todosListos {
    final listaRivales = rivalesEfectivos;
    if (listaRivales.isEmpty) return false;
    final propioListo = valoresIniciales != null || estadoPropio != null;
    return propioListo &&
        listaRivales.every(
          (rival) =>
              rival.listo ||
              rival.valoresIniciales != null ||
              rival.estado != null,
        );
  }

  bool get salaLlena => jugadoresEfectivos.length >= maxJugadores;

  factory EstadoSalaMultijugador.fromJson(Map<String, dynamic> json) {
    final codigo = json['code'];
    final estado = json['status'];
    final configId = json['config_id'];
    final valores = json['initial_values'];
    final host = json['host_username'];
    final maxPlayersRaw = json['max_players'];
    final maxJugadores = maxPlayersRaw == null
        ? kMaxJugadoresMultijugador
        : maxPlayersRaw;
    final valoresValidos =
        valores == null && (estado == 'configurando' || estado == 'esperando') ||
        valores is List &&
            valores.length == 6 &&
            valores.every((value) => value is int);
    if (codigo is! String ||
        estado is! String ||
        configId is! String ||
        !valoresValidos ||
        host is! String ||
        json['is_host'] is! bool ||
        json['opponent_connected'] is! bool ||
        json['my_version'] is! int ||
        maxJugadores is! int ||
        maxJugadores < kMinJugadoresMultijugador ||
        maxJugadores > kMaxJugadoresMultijugador) {
      throw const MultijugadorException(
        'El servidor devolvió datos de sala inválidos.',
      );
    }

    Map<String, dynamic>? parseState(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      throw const MultijugadorException(
        'El servidor devolvió un estado de partida inválido.',
      );
    }

    List<JugadorMultijugador> parsePlayers(dynamic value) {
      if (value == null) return const [];
      if (value is! List) {
        throw const MultijugadorException(
          'El servidor devolvió una lista de jugadores inválida.',
        );
      }
      final parsed = <JugadorMultijugador>[];
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          parsed.add(JugadorMultijugador.fromJson(item));
        } else if (item is Map) {
          parsed.add(
            JugadorMultijugador.fromJson(Map<String, dynamic>.from(item)),
          );
        } else {
          throw const MultijugadorException(
            'El servidor devolvió un jugador inválido.',
          );
        }
      }
      return List<JugadorMultijugador>.unmodifiable(parsed);
    }

    final jugadores = parsePlayers(json['players']);
    if (jugadores.length > kMaxJugadoresMultijugador) {
      throw const MultijugadorException(
        'La sala excede el límite máximo de 6 jugadores.',
      );
    }
    final rivales = parsePlayers(json['opponents']);
    if (rivales.length >= kMaxJugadoresMultijugador) {
      throw const MultijugadorException(
        'La sala excede el límite máximo de 6 jugadores.',
      );
    }

    final claimTime = json['reconnect_claim_at'];
    final serverTime = json['server_now'];
    final opponent = json['opponent_username'];
    final winner = json['winner_username'];
    final reason = json['result_reason'];
    final myEliminated = json['my_eliminated'] ?? false;
    final myEliminationReason = json['my_elimination_reason'];
    if (opponent != null && opponent is! String) {
      throw const MultijugadorException(
        'El servidor devolvió el nombre del rival inválido.',
      );
    }
    if (myEliminated is! bool ||
        (myEliminationReason != null && myEliminationReason is! String)) {
      throw const MultijugadorException(
        'El servidor devolvió un estado de eliminación inválido.',
      );
    }

    final estadoOponente =
        parseState(json['opponent_state']) ??
        (rivales.isNotEmpty ? rivales.first.estado : null);
    final usuarioOponente =
        (opponent as String?) ??
        (rivales.isNotEmpty ? rivales.first.usuario : null);

    return EstadoSalaMultijugador(
      codigo: codigo,
      estado: estado,
      configId: configId,
      valoresIniciales: valores == null
          ? null
          : List<int>.unmodifiable(valores.cast<int>()),
      usuarioAnfitrion: host,
      usuarioOponente: usuarioOponente,
      esAnfitrion: json['is_host'] as bool,
      oponenteConectado: json['opponent_connected'] as bool,
      reclamarDesde: claimTime is String ? DateTime.tryParse(claimTime) : null,
      horaServidor: serverTime is String ? DateTime.tryParse(serverTime) : null,
      horaLocalRecibida: DateTime.now(),
      estadoPropio: parseState(json['my_state']),
      versionPropia: json['my_version'] as int,
      estadoOponente: estadoOponente,
      ganador: winner is String ? winner : null,
      motivoFinalizacion: reason is String ? reason : null,
      maxJugadores: maxJugadores,
      jugadores: jugadores,
      rivales: rivales,
      eliminadoPropio: myEliminated,
      motivoEliminacionPropio: myEliminationReason as String?,
    );
  }
}

class MultijugadorService {
  MultijugadorService(this._supabase, this._token);

  final SupabaseClient _supabase;
  final String _token;

  Future<EstadoSalaMultijugador> crear({
    required String configId,
    required List<int> valoresIniciales,
    int maxJugadores = kMaxJugadoresMultijugador,
  }) => _invoke('create', {
    'config_id': configId,
    'initial_values': valoresIniciales,
    'max_players': maxJugadores,
  });

  Future<EstadoSalaMultijugador> unirse(String codigo) =>
      _invoke('join', {'code': codigo});

  Future<EstadoSalaMultijugador> iniciar({
    required String codigo,
    List<int>? valoresIniciales,
  }) => _invoke('start', {
    'code': codigo,
    if (valoresIniciales != null) 'initial_values': valoresIniciales,
  });

  Future<EstadoSalaMultijugador> consultar(String codigo) =>
      _invoke('state', {'code': codigo});

  Future<EstadoSalaMultijugador> guardarEstado({
    required String codigo,
    required int version,
    required Map<String, dynamic> estado,
  }) => _invoke('save', {'code': codigo, 'version': version, 'state': estado});

  Future<EstadoSalaMultijugador> conceder(String codigo) =>
      _invoke('concede', {'code': codigo});

  Future<EstadoSalaMultijugador> reclamarDesconexion(String codigo) =>
      _invoke('claim_disconnect', {'code': codigo});

  Future<EstadoSalaMultijugador> cancelar(String codigo) =>
      _invoke('cancel', {'code': codigo});

  Future<EstadoSalaMultijugador> _invoke(
    String action,
    Map<String, dynamic> arguments,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'multijugador',
        body: {'action': action, 'session_token': _token, ...arguments},
      );
      if (response.data is Map<String, dynamic>) {
        return EstadoSalaMultijugador.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      if (response.data is Map) {
        return EstadoSalaMultijugador.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const MultijugadorException(
        'El servidor devolvió una respuesta inválida.',
      );
    } on FunctionException catch (error) {
      dynamic details = error.details;
      if (details is String) {
        try {
          details = jsonDecode(details);
        } on FormatException {
          details = null;
        }
      }
      final message = details is Map && details['error'] is String
          ? details['error'] as String
          : error.status == 0
          ? 'No se pudo conectar con el servidor de partidas.'
          : 'No se pudo completar la solicitud de partida.';
      throw MultijugadorException(message, statusCode: error.status);
    } on MultijugadorException {
      rethrow;
    } catch (error) {
      throw MultijugadorException(
        'No se pudo conectar con el servidor de partidas: $error',
      );
    }
  }
}
