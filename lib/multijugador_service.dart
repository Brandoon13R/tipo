import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class MultijugadorException implements Exception {
  const MultijugadorException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
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
  });

  final String codigo;
  final String estado;
  final String configId;
  final List<int> valoresIniciales;
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

  factory EstadoSalaMultijugador.fromJson(Map<String, dynamic> json) {
    final codigo = json['code'];
    final estado = json['status'];
    final configId = json['config_id'];
    final valores = json['initial_values'];
    final host = json['host_username'];
    final valoresValidos =
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
        json['my_version'] is! int) {
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

    final claimTime = json['reconnect_claim_at'];
    final serverTime = json['server_now'];
    final opponent = json['opponent_username'];
    final winner = json['winner_username'];
    final reason = json['result_reason'];
    if (opponent != null && opponent is! String) {
      throw const MultijugadorException(
        'El servidor devolvió el nombre del rival inválido.',
      );
    }
    return EstadoSalaMultijugador(
      codigo: codigo,
      estado: estado,
      configId: configId,
      valoresIniciales: List<int>.unmodifiable(valores.cast<int>()),
      usuarioAnfitrion: host,
      usuarioOponente: opponent as String?,
      esAnfitrion: json['is_host'] as bool,
      oponenteConectado: json['opponent_connected'] as bool,
      reclamarDesde: claimTime is String ? DateTime.tryParse(claimTime) : null,
      horaServidor: serverTime is String ? DateTime.tryParse(serverTime) : null,
      horaLocalRecibida: DateTime.now(),
      estadoPropio: parseState(json['my_state']),
      versionPropia: json['my_version'] as int,
      estadoOponente: parseState(json['opponent_state']),
      ganador: winner is String ? winner : null,
      motivoFinalizacion: reason is String ? reason : null,
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
  }) => _invoke('create', {
    'config_id': configId,
    'initial_values': valoresIniciales,
  });

  Future<EstadoSalaMultijugador> unirse(String codigo) =>
      _invoke('join', {'code': codigo});

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
