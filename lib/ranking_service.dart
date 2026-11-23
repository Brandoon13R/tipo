import 'dart:convert';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/multijugador_service.dart';

class EntradaRankingElo {
  const EntradaRankingElo({
    required this.posicion,
    required this.usuario,
    required this.elo,
  });

  final int posicion;
  final String usuario;
  final int elo;
}

class ResumenRankingUsuario {
  const ResumenRankingUsuario({
    required this.top10,
    required this.perfilActual,
  });

  final List<EntradaRankingElo> top10;
  final EntradaRankingElo perfilActual;

  bool get estaEnTop10 => perfilActual.posicion <= 10;
}

class PuestoJugadorClasificatoria {
  const PuestoJugadorClasificatoria({
    required this.puesto,
    required this.usuario,
    required this.puntosPartida,
    required this.bonoPuesto,
    required this.deltaElo,
    required this.terminado,
    required this.eliminado,
  });

  final int puesto;
  final String usuario;
  final int puntosPartida;
  final int bonoPuesto;
  final int deltaElo;
  final bool terminado;
  final bool eliminado;
}

class ResultadoPodioClasificatoria {
  const ResultadoPodioClasificatoria({
    required this.clasificacion,
    required this.propio,
  });

  final List<PuestoJugadorClasificatoria> clasificacion;
  final PuestoJugadorClasificatoria propio;
}

class RankingService {
  RankingService(this._supabase, {String? token}) : _token = token;

  final SupabaseClient _supabase;
  final String? _token;

  /// Método 2 de calificación de Elo:
  /// - 1.º puesto: +12 Elo + puntos logrados en la partida
  /// - 2.º puesto: +8 Elo + puntos logrados en la partida
  /// - 3.º puesto: +5 Elo + puntos logrados en la partida
  /// - 4.º a 6.º puesto (o eliminado por rendición/desconexión):
  ///   pierde puntos conforme a los puntos que logró en la partida.
  static ({int bonoPuesto, int deltaElo}) calcularCambioElo({
    required int puesto,
    required int puntosPartida,
    bool eliminado = false,
    int totalJugadores = 2,
  }) {
    final puntos = max(0, puntosPartida);
    if (eliminado) {
      final perdida = -max(5, 15 - (puntos ~/ 2));
      return (bonoPuesto: perdida, deltaElo: perdida);
    }
    switch (puesto) {
      case 1:
        return (bonoPuesto: 12, deltaElo: 12 + puntos);
      case 2:
        return (bonoPuesto: 8, deltaElo: 8 + puntos);
      case 3:
        return (bonoPuesto: 5, deltaElo: 5 + puntos);
      default:
        // 4.º, 5.º o 6.º lugar: pierden menos Elo cuantos más puntos hayan hecho
        final basePenalizacion = 15 + max(0, puesto - 4) * 2;
        final perdida = -max(2, basePenalizacion - (puntos ~/ 2));
        return (bonoPuesto: perdida, deltaElo: perdida);
    }
  }

  /// Determina si ya se ocuparon los puestos del podio (1.º, 2.º y 3.º, o
  /// todos los jugadores activos si la sala tiene menos de 3) para finalizar
  /// automáticamente la partida clasificatoria.
  static bool podioCompleto({
    required bool propioTerminado,
    required bool propioEliminado,
    required List<JugadorMultijugador> rivales,
  }) {
    final rivalesActivos = rivales.where((r) => !r.eliminado).toList();
    final totalActivos = (propioEliminado ? 0 : 1) + rivalesActivos.length;
    if (totalActivos <= 1) return true;

    final terminados =
        (!propioEliminado && propioTerminado ? 1 : 0) +
        rivalesActivos.where((r) => r.terminado).length;
    final metaPodio = min(3, totalActivos);
    return terminados >= metaPodio;
  }

  /// Calcula la tabla de posiciones final (1.º, 2.º, 3.º y demás puestos)
  /// y el cambio de Elo de cada participante en la sala clasificatoria.
  static ResultadoPodioClasificatoria calcularPodioSala({
    required String usuarioPropio,
    required int puntosPropios,
    required int turnosOmitidosPropios,
    required bool propioTerminado,
    required bool propioEliminado,
    int? propioTerminadoEn,
    int propioZonasPrimerLugar = 0,
    required List<
      ({
        String usuario,
        int puntos,
        int turnosOmitidos,
        bool terminado,
        bool eliminado,
        int? terminadoEn,
        int zonasPrimerLugar,
      })
    >
    rivales,
  }) {
    final participantes =
        <
          ({
            String usuario,
            int puntos,
            int turnosOmitidos,
            bool terminado,
            bool eliminado,
            int? terminadoEn,
            int zonasPrimerLugar,
          })
        >[
          (
            usuario: usuarioPropio,
            puntos: puntosPropios,
            turnosOmitidos: turnosOmitidosPropios,
            terminado: propioTerminado,
            eliminado: propioEliminado,
            terminadoEn: propioTerminadoEn,
            zonasPrimerLugar: propioZonasPrimerLugar,
          ),
          ...rivales.where((r) => r.usuario != usuarioPropio),
        ];

    participantes.sort((a, b) {
      // 1. Los jugadores no eliminados van por delante de los eliminados
      if (a.eliminado != b.eliminado) {
        return a.eliminado ? 1 : -1;
      }
      // 2. Mayor puntuación lograda en el tablero
      if (a.puntos != b.puntos) {
        return b.puntos.compareTo(a.puntos);
      }
      // 3. Quien haya terminado su tablero frente a quien no
      if (a.terminado != b.terminado) {
        return a.terminado ? -1 : 1;
      }
      // 4. Quien haya terminado el tablero primero (marca de tiempo menor)
      if (a.terminadoEn != null &&
          b.terminadoEn != null &&
          a.terminadoEn != b.terminadoEn) {
        return a.terminadoEn!.compareTo(b.terminadoEn!);
      }
      // 5. Mayor cantidad de zonas ganadas en 1.º lugar
      if (a.zonasPrimerLugar != b.zonasPrimerLugar) {
        return b.zonasPrimerLugar.compareTo(a.zonasPrimerLugar);
      }
      // 6. Menos turnos omitidos
      if (a.turnosOmitidos != b.turnosOmitidos) {
        return a.turnosOmitidos.compareTo(b.turnosOmitidos);
      }
      return a.usuario.compareTo(b.usuario);
    });

    final totalJugadores = participantes.length;
    final clasificacion = <PuestoJugadorClasificatoria>[];
    PuestoJugadorClasificatoria? propio;

    for (var index = 0; index < participantes.length; index++) {
      final p = participantes[index];
      final puesto = index + 1;
      final cambio = calcularCambioElo(
        puesto: puesto,
        puntosPartida: p.puntos,
        eliminado: p.eliminado,
        totalJugadores: totalJugadores,
      );
      final entrada = PuestoJugadorClasificatoria(
        puesto: puesto,
        usuario: p.usuario,
        puntosPartida: p.puntos,
        bonoPuesto: cambio.bonoPuesto,
        deltaElo: cambio.deltaElo,
        terminado: p.terminado,
        eliminado: p.eliminado,
      );
      clasificacion.add(entrada);
      if (p.usuario == usuarioPropio) {
        propio = entrada;
      }
    }

    return ResultadoPodioClasificatoria(
      clasificacion: List.unmodifiable(clasificacion),
      propio: propio ?? clasificacion.first,
    );
  }

  static int _extraerElo(Map<String, dynamic> fila) {
    final valor = fila['Elo'] ?? fila['elo'] ?? 0;
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor) ?? 0;
    return 0;
  }

  static ResumenRankingUsuario construirResumenDesdeFilas({
    required List<Map<String, dynamic>> filas,
    required String usuarioActual,
  }) {
    final ordenadas = List<Map<String, dynamic>>.from(filas);
    ordenadas.sort((a, b) {
      final eloA = _extraerElo(a);
      final eloB = _extraerElo(b);
      if (eloA != eloB) return eloB.compareTo(eloA);
      final nombreA = (a['usuario_name'] ?? '').toString();
      final nombreB = (b['usuario_name'] ?? '').toString();
      return nombreA.compareTo(nombreB);
    });

    final entradas = <EntradaRankingElo>[];
    EntradaRankingElo? actual;

    for (var i = 0; i < ordenadas.length; i++) {
      final fila = ordenadas[i];
      final nombre = (fila['usuario_name'] ?? '').toString();
      if (nombre.isEmpty) continue;
      final entrada = EntradaRankingElo(
        posicion: entradas.length + 1,
        usuario: nombre,
        elo: _extraerElo(fila),
      );
      entradas.add(entrada);
      if (nombre.toLowerCase() == usuarioActual.toLowerCase()) {
        actual = entrada;
      }
    }

    actual ??= EntradaRankingElo(
      posicion: entradas.length + 1,
      usuario: usuarioActual,
      elo: 0,
    );

    return ResumenRankingUsuario(
      top10: List<EntradaRankingElo>.unmodifiable(entradas.take(10)),
      perfilActual: actual,
    );
  }

  Future<ResumenRankingUsuario> obtenerRanking(String usuarioActual) async {
    // 1. Intenta consultar directamente la tabla usuarios (atributo "Elo" o "elo")
    try {
      final dynamic data = await _supabase
          .from('usuarios')
          .select('usuario_name, Elo')
          .order('Elo', ascending: false);
      if (data is List) {
        final filas = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        return construirResumenDesdeFilas(
          filas: filas,
          usuarioActual: usuarioActual,
        );
      }
    } catch (_) {
      try {
        final dynamic data = await _supabase
            .from('usuarios')
            .select('usuario_name, elo')
            .order('elo', ascending: false);
        if (data is List) {
          final filas = data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          return construirResumenDesdeFilas(
            filas: filas,
            usuarioActual: usuarioActual,
          );
        }
      } catch (_) {
        // Continúa al fallback mediante Edge Function / RPC
      }
    }

    // 2. Fallback mediante Edge Function usuario-auth (con service_role)
    try {
      final response = await _supabase.functions.invoke(
        'usuario-auth',
        body: {
          'action': 'leaderboard',
          'usuario_name': usuarioActual,
          if (_token != null) 'session_token': _token,
        },
      );
      final raw = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (raw is Map && raw['players'] is List) {
        final filas = (raw['players'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        return construirResumenDesdeFilas(
          filas: filas,
          usuarioActual: usuarioActual,
        );
      }
    } catch (_) {
      // Continúa al fallback RPC
    }

    // 3. Fallback mediante RPC obtener_clasificacion_elo
    try {
      final dynamic data = await _supabase.rpc('obtener_clasificacion_elo');
      if (data is List) {
        final filas = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        return construirResumenDesdeFilas(
          filas: filas,
          usuarioActual: usuarioActual,
        );
      }
    } catch (_) {}

    return ResumenRankingUsuario(
      top10: [EntradaRankingElo(posicion: 1, usuario: usuarioActual, elo: 0)],
      perfilActual: EntradaRankingElo(
        posicion: 1,
        usuario: usuarioActual,
        elo: 0,
      ),
    );
  }

  Future<int?> aplicarCambioElo({
    required String usuario,
    required int deltaElo,
  }) async {
    // 1. Intenta actualizar directamente en la tabla usuarios ("Elo")
    try {
      final actual = await obtenerRanking(usuario);
      final nuevoElo = max(0, actual.perfilActual.elo + deltaElo);
      try {
        await _supabase
            .from('usuarios')
            .update({'Elo': nuevoElo})
            .eq('usuario_name', usuario);
        return nuevoElo;
      } catch (_) {
        await _supabase
            .from('usuarios')
            .update({'elo': nuevoElo})
            .eq('usuario_name', usuario);
        return nuevoElo;
      }
    } catch (_) {}

    // 2. Fallback mediante Edge Function usuario-auth
    try {
      final response = await _supabase.functions.invoke(
        'usuario-auth',
        body: {
          'action': 'update_elo',
          'usuario_name': usuario,
          'delta_elo': deltaElo,
          if (_token != null) 'session_token': _token,
        },
      );
      final raw = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (raw is Map && raw['elo'] is num) {
        return (raw['elo'] as num).toInt();
      }
    } catch (_) {}

    // 3. Fallback mediante RPC actualizar_elo_usuario
    try {
      final dynamic res = await _supabase.rpc(
        'actualizar_elo_usuario',
        params: {'p_usuario_name': usuario, 'p_delta': deltaElo},
      );
      if (res is num) return res.toInt();
    } catch (_) {}

    return null;
  }
}
