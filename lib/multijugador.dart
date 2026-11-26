import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/juego_bloc.dart';
import 'package:tipo/multijugador_service.dart';
import 'package:tipo/musica_lobby.dart';
import 'package:tipo/nivel_config.dart';
import 'package:tipo/puntuacion.dart';
import 'package:tipo/ranking_service.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tabla_puntos.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tablero_config.dart';
import 'package:tipo/tablero_visual.dart';
import 'package:tipo/tema_app.dart';

PaletaTema get _paleta => ControladorTema.instance.actual;

bool _partidaSinJugadas(Map<String, dynamic>? state) =>
    state == null ||
    state['turns_played'] == 0 &&
        state['turns_skipped'] == 0 &&
        state['score'] == 0 &&
        state['finished'] == false;

class SeleccionModoMultijugadorPage extends StatelessWidget {
  const SeleccionModoMultijugadorPage({
    super.key,
    required this.supabaseClient,
    required this.token,
    required this.usuario,
    this.rankingService,
  });

  final SupabaseClient supabaseClient;
  final String token;
  final String usuario;
  final RankingService? rankingService;

  @override
  Widget build(BuildContext context) => ZonaMusicaLobby(
    habilitarMusica: true,
    child: AnimatedBuilder(
      animation: ControladorTema.instance,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Multijugador'),
          leading: IconButton(
            key: const ValueKey('volver-menu-multijugador'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: const [
            BotonMusicaLobby(),
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: SelectorTemaButton(),
            ),
          ],
        ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  size: 52,
                  color: _paleta.acento,
                ),
                const SizedBox(height: 12),
                Text(
                  'Elige el modo de juego',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _paleta.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compite por puntos de Elo en Clasificatorias o juega '
                  'partidas personalizadas en Salas Amistosas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _paleta.textoSecundario),
                ),
                const SizedBox(height: 28),
                Card(
                  elevation: 0,
                  color: _paleta.panelSecundario,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: _paleta.acento, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: _paleta.acento,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Clasificatorias (Elo)',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _paleta.textoPrincipal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gana Elo según tu puesto (1.º +12, 2.º +8, 3.º +5 '
                          '+ los puntos de tu tablero). Cuando se ocupan los '
                          '3 primeros puestos, la partida finaliza '
                          'automáticamente para todos.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _paleta.textoSecundario,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          key: const ValueKey('opcion-clasificatorias'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ClasificatoriasPage(
                                  supabaseClient: supabaseClient,
                                  token: token,
                                  usuario: usuario,
                                  rankingService: rankingService,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.leaderboard_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Entrar a Clasificatorias'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: _paleta.panelSecundario,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: _paleta.bordeSecundario),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sports_esports_outlined,
                              color: _paleta.acento,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Salas Amistosas',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _paleta.textoPrincipal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea o únete a una sala privada con código para '
                          'jugar con amigos (hasta 6 jugadores) sin alterar tu '
                          'puntuación de Elo.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _paleta.textoSecundario,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          key: const ValueKey('opcion-salas-amistosas'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => LobbyMultijugadorPage(
                                  supabaseClient: supabaseClient,
                                  token: token,
                                  usuario: usuario,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.meeting_room_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Entrar a Salas Amistosas'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    ),
  );
}

class ClasificatoriasPage extends StatefulWidget {
  const ClasificatoriasPage({
    super.key,
    required this.supabaseClient,
    required this.token,
    required this.usuario,
    this.service,
    this.rankingService,
  });

  final SupabaseClient supabaseClient;
  final String token;
  final String usuario;
  final MultijugadorService? service;
  final RankingService? rankingService;

  @override
  State<ClasificatoriasPage> createState() => _ClasificatoriasPageState();
}

class _ClasificatoriasPageState extends State<ClasificatoriasPage> {
  final _codigoController = TextEditingController();
  late final MultijugadorService _service;
  late final RankingService _rankingService;
  NivelConfig _config = Nivel1Config();
  final Map<String, int?> _valoresIniciales = {};
  bool _ocupado = false;
  bool _cargandoRanking = true;
  String? _error;
  ResumenRankingUsuario? _resumenRanking;

  @override
  void initState() {
    super.initState();
    _service =
        widget.service ??
        MultijugadorService(widget.supabaseClient, widget.token);
    _rankingService =
        widget.rankingService ??
        RankingService(widget.supabaseClient, token: widget.token);
    unawaited(_cargarRanking());
  }

  Future<void> _cargarRanking() async {
    setState(() => _cargandoRanking = true);
    try {
      final resumen = await _rankingService.obtenerRanking(widget.usuario);
      if (!mounted) return;
      setState(() {
        _resumenRanking = resumen;
        _cargandoRanking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargandoRanking = false);
    }
  }

  List<int>? _valoresSeleccionados() {
    final values = [
      for (final region in _config.iniciales.keys) _valoresIniciales[region],
    ];
    if (values.any((value) => value == null) || values.toSet().length != 6) {
      return null;
    }
    return values.cast<int>();
  }

  bool _tableroInicialValido(List<int> values) {
    final tablero = Tablero.desdeConfig(_config);
    var index = 0;
    for (final position in _config.iniciales.values) {
      if (!tablero.agregar(position, values[index++])) return false;
    }
    return true;
  }

  Future<void> _elegirNumero(String region) async {
    if (_ocupado) return;
    final usadosEnOtrasRegiones = {
      for (final entry in _valoresIniciales.entries)
        if (entry.key != region && entry.value != null) entry.value,
    };
    final valor = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Número inicial · $region'),
        children: [
          for (var number = 1; number <= 6; number++)
            SimpleDialogOption(
              key: ValueKey('opcion-clasificatoria-$number'),
              onPressed: usadosEnOtrasRegiones.contains(number)
                  ? null
                  : () => Navigator.pop(context, number),
              child: Text(
                usadosEnOtrasRegiones.contains(number)
                    ? '$number · ya asignado'
                    : '$number',
              ),
            ),
          SimpleDialogOption(
            key: const ValueKey('borrar-clasificatoria'),
            onPressed: () => Navigator.pop(context, 0),
            child: const Text('Borrar número'),
          ),
        ],
      ),
    );
    if (!mounted || valor == null) return;
    setState(() {
      _valoresIniciales[region] = valor == 0 ? null : valor;
      _error = null;
    });
  }

  Future<void> _crearPartidaClasificatoria() async {
    final valores = _valoresSeleccionados();
    if (valores == null) {
      setState(() => _error = 'Asigna los números del 1 al 6 sin repetir.');
      return;
    }
    if (!_tableroInicialValido(valores)) {
      setState(
        () =>
            _error = 'Esa distribución inicial no cumple las reglas del nivel.',
      );
      return;
    }

    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final room = await _service.crear(
        configId: _config.id,
        valoresIniciales: valores,
      );
      if (!mounted) return;
      await _abrirSalaClasificatoria(room);
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _unirseClasificatoria() async {
    final code = _codigoController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Escribe un código de seis dígitos.');
      return;
    }
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final room = await _service.unirse(code);
      if (!mounted) return;
      await _abrirSalaClasificatoria(room);
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _abrirSalaClasificatoria(EstadoSalaMultijugador room) async {
    final perteneceASala =
        room.esAnfitrion ||
        room.usuarioOponente == widget.usuario ||
        room.jugadores.isEmpty ||
        room.jugadores.any((j) => j.usuario == widget.usuario);
    if (!perteneceASala &&
        (room.estado == 'activa' || room.estado == 'finalizada')) {
      setState(() {
        _error = 'La partida ya comenzó. No puedes unirte a una sala en curso.';
      });
      return;
    }
    final invitadoSinTablero =
        !room.esAnfitrion &&
        room.valoresIniciales == null &&
        (room.estado == 'configurando' ||
            room.estado == 'esperando' ||
            (room.estado == 'activa' && _partidaSinJugadas(room.estadoPropio)));
    final segundoSinTablero =
        !room.esAnfitrion &&
        room.estado == 'activa' &&
        _partidaSinJugadas(room.estadoPropio) &&
        room.estadoPropio == null;
    if (invitadoSinTablero || segundoSinTablero) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ConfigurarTableroMultijugadorPage(
            service: _service,
            salaInicial: room,
            usuario: widget.usuario,
            esClasificatoria: true,
            rankingService: _rankingService,
          ),
        ),
      );
      return;
    }
    if (room.estado == 'activa' || room.estado == 'finalizada') {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PartidaMultijugadorPage(
            service: _service,
            salaInicial: room,
            usuario: widget.usuario,
            esClasificatoria: true,
            rankingService: _rankingService,
          ),
        ),
      );
    } else {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SalaMultijugadorPage(
            service: _service,
            salaInicial: room,
            usuario: widget.usuario,
            esClasificatoria: true,
            rankingService: _rankingService,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Widget _tarjetaCrearPartidaClasificatoria() => Card(
    key: const ValueKey('panel-crear-clasificatoria'),
    elevation: 0,
    color: _paleta.panelSecundario,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: _paleta.bordeSecundario),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: _paleta.acento,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Crear Partida Clasificatoria',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _paleta.textoPrincipal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '1.º puesto: +12 Elo + puntos · '
            '2.º puesto: +8 Elo + puntos · '
            '3.º puesto: +5 Elo + puntos. '
            'La partida termina al ocuparse los 3 primeros puestos.',
            style: TextStyle(
              fontSize: 12.5,
              color: _paleta.textoSecundario,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey('nivel-clasificatoria-${_config.id}'),
            initialValue: _config.id,
            dropdownColor: _paleta.panelSecundario,
            decoration: const InputDecoration(labelText: 'Nivel'),
            items: [
              for (final config in _niveles)
                DropdownMenuItem(
                  value: config.id,
                  child: Text(config.nombre),
                ),
            ],
            onChanged: _ocupado
                ? null
                : (id) {
                    if (id == null) return;
                    setState(() {
                      _config = _configuracion(id);
                      _valoresIniciales.clear();
                      _error = null;
                    });
                  },
          ),
          const SizedBox(height: 10),
          Text(
            '${_valoresIniciales.values.whereType<int>().length} '
            'de 6 números asignados',
            key: const ValueKey('progreso-inicial-clasificatoria'),
            style: TextStyle(
              color: _paleta.acento,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TableroVisual(
            key: ValueKey('tablero-clasificatoria-${_config.id}'),
            valores: _valoresIniciales,
            habilitado: !_ocupado,
            onSeleccionar: _elegirNumero,
            config: _config,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('crear-partida-clasificatoria'),
            onPressed: _ocupado ? null : _crearPartidaClasificatoria,
            icon: const Icon(Icons.emoji_events_outlined),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _ocupado ? 'Creando partida...' : 'Crear Partida',
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              key: const ValueKey('error-clasificatoria'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _tarjetaUnirseClasificatoria() => Card(
    key: const ValueKey('panel-unirse-clasificatoria'),
    elevation: 0,
    color: _paleta.panelSecundario,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: _paleta.bordeSecundario),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.meeting_room_outlined, color: _paleta.acento),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unirse a una partida clasificatoria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _paleta.textoPrincipal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa el código de 6 dígitos de la sala para entrar y elegir '
            'tus números pivote iniciales.',
            style: TextStyle(
              fontSize: 12.5,
              color: _paleta.textoSecundario,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey('codigo-invitacion-clasificatoria'),
            controller: _codigoController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Código de sala',
              hintText: '123456',
              prefixIcon: Icon(Icons.tag_rounded),
              border: OutlineInputBorder(),
              counterText: '',
              isDense: true,
            ),
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('unirse-sala-clasificatoria'),
            onPressed: _ocupado ? null : _unirseClasificatoria,
            icon: const Icon(Icons.login),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Unirse'),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _tarjetaTablaClasificacion({
    required ResumenRankingUsuario? resumen,
    required List<EntradaRankingElo> top10,
    required EntradaRankingElo miPerfil,
  }) => Card(
    key: const ValueKey('tabla-clasificacion-top10'),
    elevation: 0,
    color: _paleta.panelSecundario,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: _paleta.bordeSecundario),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.leaderboard_rounded,
                color: _paleta.acento,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tabla de Clasificaciones · Top 10',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _paleta.textoPrincipal,
                  ),
                ),
              ),
              if (_cargandoRanking)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
          const Divider(height: 20),
          if (top10.isEmpty && !_cargandoRanking)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aún no hay jugadores registrados en el ranking.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _paleta.textoSecundario,
                ),
              ),
            )
          else
            for (final entrada in top10)
              Container(
                key: ValueKey('fila-top10-${entrada.posicion}'),
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      entrada.usuario.toLowerCase() ==
                          widget.usuario.toLowerCase()
                      ? _paleta.superficieAcentoSuave
                      : _paleta.superficieInterior,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      entrada.usuario.toLowerCase() ==
                          widget.usuario.toLowerCase()
                      ? Border.all(color: _paleta.acento)
                      : Border.all(
                          color: _paleta.bordeSecundario,
                          width: 0.6,
                        ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: entrada.posicion == 1
                            ? const Color(0xFFF1C40F)
                            : entrada.posicion == 2
                            ? const Color(0xFFBDC3C7)
                            : entrada.posicion == 3
                            ? const Color(0xFFE67E22)
                            : _paleta.panelSecundario,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${entrada.posicion}.º',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: entrada.posicion <= 3
                              ? Colors.black87
                              : _paleta.acento,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entrada.usuario,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _paleta.textoPrincipal,
                        ),
                      ),
                    ),
                    Text(
                      '${entrada.elo} Elo',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _paleta.acento,
                      ),
                    ),
                  ],
                ),
              ),
          const Divider(height: 24),
          Container(
            key: const ValueKey('tarjeta-mi-ranking'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _paleta.superficieInterior,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _paleta.acento),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _paleta.acento,
                  child: Text(
                    widget.usuario.isNotEmpty
                        ? widget.usuario[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: _paleta.textoSobreAcento,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu perfil · ${miPerfil.usuario}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _paleta.textoPrincipal,
                        ),
                      ),
                      Text(
                        resumen?.estaEnTop10 == true
                            ? 'Puesto #${miPerfil.posicion} (En el Top 10)'
                            : 'Puesto #${miPerfil.posicion} en la clasificación general',
                        key: const ValueKey('mi-puesto-ranking'),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: _paleta.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _paleta.superficieAcentoSuave,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _paleta.acento),
                  ),
                  child: Text(
                    '${miPerfil.elo} Elo',
                    key: const ValueKey('mi-elo-ranking'),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _paleta.acento,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final resumen = _resumenRanking;
    final top10 = resumen?.top10 ?? const <EntradaRankingElo>[];
    final miPerfil =
        resumen?.perfilActual ??
        EntradaRankingElo(posicion: 1, usuario: widget.usuario, elo: 0);

    return ZonaMusicaLobby(
      habilitarMusica: true,
      child: AnimatedBuilder(
        animation: ControladorTema.instance,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Clasificatorias · Ranking Elo'),
            leading: IconButton(
              key: const ValueKey('salir-clasificatorias'),
              onPressed: _ocupado ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              const BotonMusicaLobby(),
              const SizedBox(width: 6),
              const SelectorTemaButton(),
              IconButton(
                key: const ValueKey('recargar-ranking'),
                tooltip: 'Actualizar tabla de clasificación',
                onPressed: _cargandoRanking ? null : _cargarRanking,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final esEscritorio = constraints.maxWidth >= 960;
                final tarjetaRanking = _tarjetaTablaClasificacion(
                  resumen: resumen,
                  top10: top10,
                  miPerfil: miPerfil,
                );
                final tarjetaCrear = _tarjetaCrearPartidaClasificatoria();
                final tarjetaUnirse = _tarjetaUnirseClasificatoria();

                if (esEscritorio) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1360),
                        child: Row(
                          key: const ValueKey('layout-clasificatorias-pc'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: tarjetaRanking,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 5,
                              child: tarjetaCrear,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: tarjetaUnirse,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: ListView(
                      key: const ValueKey('layout-clasificatorias-movil'),
                      padding: const EdgeInsets.all(20),
                      children: [
                        tarjetaCrear,
                        const SizedBox(height: 16),
                        tarjetaUnirse,
                        const SizedBox(height: 16),
                        tarjetaRanking,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class LobbyMultijugadorPage extends StatefulWidget {
  const LobbyMultijugadorPage({
    super.key,
    required this.supabaseClient,
    required this.token,
    required this.usuario,
  });

  final SupabaseClient supabaseClient;
  final String token;
  final String usuario;

  @override
  State<LobbyMultijugadorPage> createState() => _LobbyMultijugadorPageState();
}

class _LobbyMultijugadorPageState extends State<LobbyMultijugadorPage> {
  final _codigoController = TextEditingController();
  late final MultijugadorService _service;
  NivelConfig _config = Nivel1Config();
  final Map<String, int?> _valoresIniciales = {};
  bool _ocupado = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = MultijugadorService(widget.supabaseClient, widget.token);
  }

  Future<void> _crearSala() async {
    final valores = _valoresSeleccionados();
    if (valores == null) {
      setState(() => _error = 'Asigna los números del 1 al 6 sin repetir.');
      return;
    }
    if (!_tableroInicialValido(valores)) {
      setState(
        () =>
            _error = 'Esa distribución inicial no cumple las reglas del nivel.',
      );
      return;
    }

    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final room = await _service.crear(
        configId: _config.id,
        valoresIniciales: valores,
      );
      if (!mounted) return;
      await _abrirSala(room);
    } on MultijugadorException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  List<int>? _valoresSeleccionados() {
    final values = [
      for (final region in _config.iniciales.keys) _valoresIniciales[region],
    ];
    if (values.any((value) => value == null) || values.toSet().length != 6) {
      return null;
    }
    return values.cast<int>();
  }

  bool _tableroInicialValido(List<int> values) {
    final tablero = Tablero.desdeConfig(_config);
    var index = 0;
    for (final position in _config.iniciales.values) {
      if (!tablero.agregar(position, values[index++])) {
        return false;
      }
    }
    return true;
  }

  Future<void> _elegirNumero(String region) async {
    if (_ocupado) return;
    final usadosEnOtrasRegiones = {
      for (final entry in _valoresIniciales.entries)
        if (entry.key != region && entry.value != null) entry.value,
    };
    final valor = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Número inicial · $region'),
        children: [
          for (var number = 1; number <= 6; number++)
            SimpleDialogOption(
              key: ValueKey('opcion-inicial-$number'),
              onPressed: usadosEnOtrasRegiones.contains(number)
                  ? null
                  : () => Navigator.pop(context, number),
              child: Text(
                usadosEnOtrasRegiones.contains(number)
                    ? '$number · ya asignado'
                    : '$number',
              ),
            ),
          SimpleDialogOption(
            key: const ValueKey('borrar-inicial'),
            onPressed: () => Navigator.pop(context, 0),
            child: const Text('Borrar número'),
          ),
        ],
      ),
    );
    if (!mounted || valor == null) return;
    setState(() {
      _valoresIniciales[region] = valor == 0 ? null : valor;
      _error = null;
    });
  }

  Future<void> _unirse() async {
    final code = _codigoController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Escribe un código de seis dígitos.');
      return;
    }
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final room = await _service.unirse(code);
      if (!mounted) return;
      await _abrirSala(room);
    } on MultijugadorException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _abrirSala(EstadoSalaMultijugador room) async {
    final perteneceASala =
        room.esAnfitrion ||
        room.usuarioOponente == widget.usuario ||
        room.jugadores.isEmpty ||
        room.jugadores.any((j) => j.usuario == widget.usuario);
    if (!perteneceASala &&
        (room.estado == 'activa' || room.estado == 'finalizada')) {
      setState(() {
        _error = 'La partida ya comenzó. No puedes unirte a una sala en curso.';
      });
      return;
    }
    final invitadoSinTablero =
        !room.esAnfitrion &&
        room.valoresIniciales == null &&
        (room.estado == 'configurando' ||
            room.estado == 'esperando' ||
            (room.estado == 'activa' && _partidaSinJugadas(room.estadoPropio)));
    final segundoSinTablero =
        !room.esAnfitrion &&
        room.estado == 'activa' &&
        _partidaSinJugadas(room.estadoPropio) &&
        room.estadoPropio == null;
    if (invitadoSinTablero || segundoSinTablero) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ConfigurarTableroMultijugadorPage(
            service: _service,
            salaInicial: room,
            usuario: widget.usuario,
          ),
        ),
      );
      return;
    }
    if (room.estado == 'activa' || room.estado == 'finalizada') {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PartidaMultijugadorPage(
            service: _service,
            salaInicial: room,
            usuario: widget.usuario,
          ),
        ),
      );
    } else {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SalaMultijugadorPage(
            service: _service,
            salaInicial: room,
            usuario: widget.usuario,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ZonaMusicaLobby(
    habilitarMusica: true,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Multijugador'),
        leading: IconButton(
          key: const ValueKey('salir-multijugador'),
          onPressed: _ocupado ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: const [
          BotonMusicaLobby(),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: SelectorTemaButton(),
          ),
        ],
      ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Configura tu tablero inicial',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Al crear una sala (hasta 6 jugadores), elige el nivel y tus '
                'números iniciales. Al unirte, ingresa el código: después '
                'podrás elegir tus números en tu propio tablero.',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey('nivel-multijugador-${_config.id}'),
                initialValue: _config.id,
                decoration: const InputDecoration(labelText: 'Nivel'),
                items: [
                  for (final config in _niveles)
                    DropdownMenuItem(
                      value: config.id,
                      child: Text(config.nombre),
                    ),
                ],
                onChanged: _ocupado
                    ? null
                    : (id) {
                        if (id == null) return;
                        setState(() {
                          _config = _configuracion(id);
                          _valoresIniciales.clear();
                          _error = null;
                        });
                      },
              ),
              const SizedBox(height: 12),
              Text(
                '${_valoresIniciales.values.whereType<int>().length} '
                'de 6 números asignados',
                key: const ValueKey('progreso-inicial-multijugador'),
              ),
              const SizedBox(height: 12),
              TableroVisual(
                key: ValueKey('tablero-inicial-${_config.id}'),
                valores: _valoresIniciales,
                habilitado: !_ocupado,
                onSeleccionar: _elegirNumero,
                config: _config,
              ),
              const SizedBox(height: 8),
              const Text(
                'Las casillas pivote permanecen en la posición del nivel. '
                'Solo se elige qué número va en cada una.',
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const ValueKey('crear-sala'),
                onPressed: _ocupado ? null : _crearSala,
                icon: const Icon(Icons.add),
                label: Text(_ocupado ? 'Conectando...' : 'Crear sala'),
              ),
              const Divider(height: 40),
              const Text(
                'Únete con un código',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const ValueKey('codigo-invitacion'),
                controller: _codigoController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código de invitación',
                  hintText: '123456',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey('unirse-sala'),
                onPressed: _ocupado ? null : _unirse,
                icon: const Icon(Icons.login),
                label: const Text('Unirse / reconectar'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  key: const ValueKey('error-multijugador'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  ),
);
}

class ConfigurarTableroMultijugadorPage extends StatefulWidget {
  const ConfigurarTableroMultijugadorPage({
    super.key,
    required this.service,
    required this.salaInicial,
    required this.usuario,
    this.esClasificatoria = false,
    this.rankingService,
  });

  final MultijugadorService service;
  final EstadoSalaMultijugador salaInicial;
  final String usuario;
  final bool esClasificatoria;
  final RankingService? rankingService;

  @override
  State<ConfigurarTableroMultijugadorPage> createState() =>
      _ConfigurarTableroMultijugadorPageState();
}

class _ConfigurarTableroMultijugadorPageState
    extends State<ConfigurarTableroMultijugadorPage> {
  late final NivelConfig _config;
  final Map<String, int?> _valores = {};
  bool _ocupado = false;
  bool _consultando = false;
  String? _error;
  Timer? _presencia;

  @override
  void initState() {
    super.initState();
    _config = _configuracion(widget.salaInicial.configId);
    _presencia = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _actualizarPresencia(),
    );
    unawaited(_actualizarPresencia());
  }

  Future<void> _actualizarPresencia() async {
    if (_consultando || !mounted) return;
    _consultando = true;
    try {
      await widget.service.consultar(widget.salaInicial.codigo);
      if (mounted && _error?.startsWith('Sin conexión') == true) {
        setState(() => _error = null);
      }
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _error = 'Sin conexión: ${error.message}');
    } finally {
      _consultando = false;
    }
  }

  List<int>? _valoresSeleccionados() {
    final values = [
      for (final region in _config.iniciales.keys) _valores[region],
    ];
    if (values.any((value) => value == null) || values.toSet().length != 6) {
      return null;
    }
    return values.cast<int>();
  }

  bool _tableroInicialValido(List<int> values) {
    final tablero = Tablero.desdeConfig(_config);
    var index = 0;
    for (final position in _config.iniciales.values) {
      if (!tablero.agregar(position, values[index++])) return false;
    }
    return true;
  }

  Future<void> _elegirNumero(String region) async {
    if (_ocupado) return;
    final usadosEnOtrasRegiones = {
      for (final entry in _valores.entries)
        if (entry.key != region && entry.value != null) entry.value,
    };
    final value = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Número inicial · $region'),
        children: [
          for (var number = 1; number <= 6; number++)
            SimpleDialogOption(
              key: ValueKey('opcion-inicial-$number'),
              onPressed: usadosEnOtrasRegiones.contains(number)
                  ? null
                  : () => Navigator.pop(context, number),
              child: Text(
                usadosEnOtrasRegiones.contains(number)
                    ? '$number · ya asignado'
                    : '$number',
              ),
            ),
          SimpleDialogOption(
            key: const ValueKey('borrar-inicial'),
            onPressed: () => Navigator.pop(context, 0),
            child: const Text('Borrar número'),
          ),
        ],
      ),
    );
    if (!mounted || value == null) return;
    setState(() {
      _valores[region] = value == 0 ? null : value;
      _error = null;
    });
  }

  Future<void> _iniciarPartida() async {
    final values = _valoresSeleccionados();
    if (values == null) {
      setState(() => _error = 'Asigna los números del 1 al 6 sin repetir.');
      return;
    }
    if (!_tableroInicialValido(values)) {
      setState(
        () =>
            _error = 'Esa distribución inicial no cumple las reglas del nivel.',
      );
      return;
    }

    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final room = await _confirmarInicio(values);
      if (!mounted) return;
      if (room.estado == 'activa' || room.estado == 'finalizada') {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => PartidaMultijugadorPage(
              service: widget.service,
              salaInicial: room,
              usuario: widget.usuario,
              esClasificatoria: widget.esClasificatoria,
              rankingService: widget.rankingService,
            ),
          ),
        );
      } else {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => SalaMultijugadorPage(
              service: widget.service,
              salaInicial: room,
              usuario: widget.usuario,
              esClasificatoria: widget.esClasificatoria,
              rankingService: widget.rankingService,
            ),
          ),
        );
      }
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<EstadoSalaMultijugador> _confirmarInicio(List<int> values) async {
    try {
      return await widget.service.iniciar(
        codigo: widget.salaInicial.codigo,
        valoresIniciales: values,
      );
    } on MultijugadorException catch (error) {
      if (error.message != 'Acción no reconocida.') rethrow;
      if (widget.salaInicial.estado != 'activa' ||
          !_partidaSinJugadas(widget.salaInicial.estadoPropio)) {
        rethrow;
      }

      final juego = _crearJuegoInicial(values);
      try {
        return await widget.service.guardarEstado(
          codigo: widget.salaInicial.codigo,
          version: widget.salaInicial.versionPropia,
          estado: juego.toJson(),
        );
      } finally {
        juego.dispose();
      }
    }
  }

  JuegoBloc _crearJuegoInicial(List<int> values) {
    final tablero = Tablero.desdeConfig(_config);
    var index = 0;
    for (final position in _config.iniciales.values) {
      if (!tablero.agregar(position, values[index++])) {
        throw StateError('La configuración inicial del servidor no es válida.');
      }
    }
    return JuegoBloc(tablero);
  }

  @override
  void dispose() {
    _presencia?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ZonaMusicaLobby(
    habilitarMusica: true,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu tablero'),
        automaticallyImplyLeading: false,
        actions: const [
          BotonMusicaLobby(),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: SelectorTemaButton(),
          ),
        ],
      ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${_config.nombre} · Tu tablero',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Elige los números para las seis casillas pivote. '
                    'El anfitrión espera a que confirmes para iniciar la partida.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_valores.values.whereType<int>().length} de 6 números asignados',
                    key: const ValueKey('progreso-inicial-multijugador'),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: TableroVisual(
                        valores: _valores,
                        habilitado: !_ocupado,
                        onSeleccionar: _elegirNumero,
                        config: _config,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toca cada pivote para asignarle un número. '
                    'No se pueden repetir.',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      key: const ValueKey('error-configuracion-inicial'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const ValueKey('iniciar-partida-multijugador'),
                    onPressed: _ocupado || _valoresSeleccionados() == null
                        ? null
                        : _iniciarPartida,
                    child: Text(_ocupado ? 'Iniciando...' : 'Iniciar partida'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

class SalaMultijugadorPage extends StatefulWidget {
  const SalaMultijugadorPage({
    super.key,
    required this.service,
    required this.salaInicial,
    required this.usuario,
    this.esClasificatoria = false,
    this.rankingService,
  });

  final MultijugadorService service;
  final EstadoSalaMultijugador salaInicial;
  final String usuario;
  final bool esClasificatoria;
  final RankingService? rankingService;

  @override
  State<SalaMultijugadorPage> createState() => _SalaMultijugadorPageState();
}

class _SalaMultijugadorPageState extends State<SalaMultijugadorPage> {
  late EstadoSalaMultijugador _sala;
  Timer? _timer;
  bool _consultando = false;
  bool _navegando = false;
  bool _iniciando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sala = widget.salaInicial;
    _programarConsulta();
    if (_puedeEntrarAPartida(_sala)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _abrirPartida(_sala);
      });
    }
  }

  bool _puedeEntrarAPartida(EstadoSalaMultijugador sala) =>
      sala.estado == 'activa' &&
      (sala.todosListos || sala.estadoOponente != null);

  void _programarConsulta() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _consultar());
  }

  Future<void> _consultar() async {
    if (_consultando || _navegando || _iniciando || !mounted) return;
    _consultando = true;
    try {
      final sala = await widget.service.consultar(_sala.codigo);
      if (!mounted) return;
      setState(() {
        _sala = sala;
        _error = null;
      });
      if (_puedeEntrarAPartida(sala)) {
        await _abrirPartida(sala);
      }
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      _consultando = false;
    }
  }

  Future<void> _iniciarComoAnfitrion() async {
    if (_iniciando || _navegando || !mounted) return;
    setState(() {
      _iniciando = true;
      _error = null;
    });
    try {
      final sala = await widget.service.iniciar(codigo: _sala.codigo);
      if (!mounted) return;
      setState(() => _sala = sala);
      if (sala.estado == 'activa') {
        await _abrirPartida(sala);
      }
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _iniciando = false);
    }
  }

  Future<void> _abrirPartida(EstadoSalaMultijugador sala) async {
    if (_navegando || !mounted) return;
    _navegando = true;
    _timer?.cancel();
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PartidaMultijugadorPage(
          service: widget.service,
          salaInicial: sala,
          usuario: widget.usuario,
          esClasificatoria: widget.esClasificatoria,
          rankingService: widget.rankingService,
        ),
      ),
    );
  }

  Future<void> _copiarCodigo() async {
    await Clipboard.setData(ClipboardData(text: _sala.codigo));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Código copiado.')));
  }

  Future<void> _cancelarSala() async {
    try {
      await widget.service.cancelar(_sala.codigo);
      if (mounted) Navigator.of(context).pop();
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rivales = _sala.rivalesEfectivos;
    final jugadores = _sala.jugadoresEfectivos;
    final esperando = _sala.estado == 'esperando' || rivales.isEmpty;
    final rivalConfigurando =
        !esperando &&
        (!_sala.todosListos &&
            (_sala.estado == 'configurando' ||
                (_sala.estado == 'activa' && _sala.estadoOponente == null)));
    return ZonaMusicaLobby(
      habilitarMusica: true,
      child: AnimatedBuilder(
        animation: ControladorTema.instance,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Lobby'),
            actions: const [
              BotonMusicaLobby(),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: SelectorTemaButton(),
              ),
            ],
          ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      esperando ? Icons.hourglass_top : Icons.sports_esports,
                      size: 52,
                      color: _paleta.acento,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      esperando
                          ? 'Esperando jugadores'
                          : rivalConfigurando
                          ? 'Configurando tableros'
                          : 'Partida lista para iniciar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _paleta.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Comparte este código (máximo ${_sala.maxJugadores} jugadores):',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _paleta.textoSecundario),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      _sala.codigo,
                      key: const ValueKey('codigo-sala'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w800,
                        color: _paleta.acento,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const ValueKey('copiar-codigo'),
                      onPressed: _copiarCodigo,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar código'),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Jugadores en la sala (${jugadores.length}/${_sala.maxJugadores})',
                              key: const ValueKey('contador-jugadores-sala'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _paleta.textoPrincipal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final jugador in jugadores)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      jugador.listo
                                          ? Icons.check_circle
                                          : Icons.hourglass_bottom,
                                      size: 18,
                                      color: jugador.listo
                                          ? _paleta.acento
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${jugador.usuario}'
                                        '${jugador.esAnfitrion ? " (Anfitrión)" : ""}',
                                        style: TextStyle(
                                          color: _paleta.textoPrincipal,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      jugador.listo
                                          ? 'Listo'
                                          : 'Configurando tablero...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: jugador.listo
                                            ? _paleta.acento
                                            : _paleta.textoSecundario,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (esperando)
                      const Text(
                        'La sala admite de 2 a 6 jugadores. '
                        'Si cierras la app, podrás volver a entrar usando el '
                        'mismo código.',
                        textAlign: TextAlign.center,
                      )
                    else if (rivalConfigurando)
                      const Text(
                        'Esperando a que todos los jugadores unidos elijan sus '
                        'números iniciales.',
                        textAlign: TextAlign.center,
                      )
                    else if (_sala.esAnfitrion)
                      const Text(
                        'Todos los jugadores unidos están listos. Puedes '
                        'iniciar la partida o esperar a más jugadores (hasta 6).',
                        textAlign: TextAlign.center,
                      )
                    else
                      const Text(
                        'Tu tablero está listo. Esperando a que el anfitrión '
                        'inicie la partida.',
                        textAlign: TextAlign.center,
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Sincronización interrumpida: $_error. '
                        'Reintentando automáticamente...',
                        key: const ValueKey('error-conexion-sala'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    if (_sala.esAnfitrion && !esperando) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        key: const ValueKey('anfitrion-iniciar-partida'),
                        onPressed: _sala.todosListos && !_iniciando
                            ? _iniciarComoAnfitrion
                            : null,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          _iniciando ? 'Iniciando...' : 'Iniciar partida',
                        ),
                      ),
                    ],
                    if (_sala.esAnfitrion &&
                        (esperando ||
                            rivalConfigurando ||
                            _sala.estado != 'activa')) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        key: const ValueKey('cancelar-sala'),
                        onPressed: _cancelarSala,
                        child: const Text('Cancelar sala'),
                      ),
                    ],
                  ],
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VistaTableroRival {
  _VistaTableroRival({
    required this.rival,
    required NivelConfig config,
    Map<String, int>? tiemposObservados,
  }) : tablero = _construirTablero(rival, config) {
    puntuacion = PuntuacionPartida(
      tablero,
      tiemposIniciales: tiemposObservados,
    );
    if (rival.estado != null) {
      puntuacion.restaurarDesdeEstado(rival.estado!);
    }
  }

  final JugadorMultijugador rival;
  final Tablero tablero;
  late final PuntuacionPartida puntuacion;

  int get puntos => puntuacion.obtenidos.isNotEmpty
      ? puntuacion.total
      : (rival.estado?['score'] is int
            ? rival.estado!['score'] as int
            : puntuacion.total);

  Map<String, int> get puntosPorZona => puntuacion.obtenidos;
  Map<String, int> get posicionesPorZona => puntuacion.posicionesObtenidas;
  Map<String, int> get tiemposPorZona => puntuacion.tiemposCompletado;
  int get turnosJugados => rival.turnosJugados;
  int get turnosOmitidos => rival.turnosOmitidos;
  bool get terminado => rival.terminado;

  static Tablero _construirTablero(
    JugadorMultijugador rival,
    NivelConfig config,
  ) {
    final tablero = Tablero.desdeConfig(config);
    final celdas = rival.estado?['cells'];
    if (celdas is List) {
      final datos = <Coordenada, int>{};
      for (final celda in celdas) {
        if (celda is Map &&
            celda['x'] is int &&
            celda['y'] is int &&
            celda['value'] is int) {
          datos[Coordenada(celda['x'] as int, celda['y'] as int)] =
              celda['value'] as int;
        }
      }
      if (datos.isNotEmpty) {
        try {
          tablero.restaurarDatos(datos);
          return tablero;
        } on FormatException {
          tablero.reiniciar();
        }
      }
    }

    final iniciales = rival.valoresIniciales;
    if (iniciales != null && iniciales.length == config.iniciales.length) {
      for (var index = 0; index < config.iniciales.length; index++) {
        final posicion = config.iniciales.values.elementAt(index);
        tablero.agregar(posicion, iniciales[index]);
      }
    }
    return tablero;
  }
}

class PartidaMultijugadorPage extends StatefulWidget {
  const PartidaMultijugadorPage({
    super.key,
    required this.service,
    required this.salaInicial,
    required this.usuario,
    this.esClasificatoria = false,
    this.rankingService,
  });

  final MultijugadorService service;
  final EstadoSalaMultijugador salaInicial;
  final String usuario;
  final bool esClasificatoria;
  final RankingService? rankingService;

  @override
  State<PartidaMultijugadorPage> createState() =>
      _PartidaMultijugadorPageState();
}

class _PartidaMultijugadorPageState extends State<PartidaMultijugadorPage>
    with WidgetsBindingObserver {
  late final NivelConfig _config;
  late EstadoSalaMultijugador _sala;
  late JuegoBloc _juego;
  Timer? _timer;
  Timer? _reloj;
  Map<String, dynamic>? _pendiente;
  bool _sincronizando = false;
  bool _concediendo = false;
  String? _errorConexion;
  String? _rivalSeleccionado;
  final Map<String, Map<String, int>> _tiemposObservadosRivales = {};
  bool _observacionInicialCompleta = false;
  late final int _marcaInicioVista = DateTime.now().millisecondsSinceEpoch;
  bool _finalizadaPorPodio = false;
  bool _eloActualizado = false;
  int? _nuevoEloGuardado;
  bool _errorGuardandoElo = false;

  bool get _esPartidaClasificatoria =>
      widget.esClasificatoria ||
      _sala.estadoPropio?['ranked'] == true ||
      _sala.rivalesEfectivos.any((r) => r.estado?['ranked'] == true);

  bool _podioClasificatorioCompleto(EstadoSalaMultijugador sala) {
    if (!_esPartidaClasificatoria) return false;
    final rivales = sala.rivalesEfectivos;
    if (rivales.isEmpty) return false;
    final propioTerminado =
        _juego.finalizada || sala.estadoPropio?['finished'] == true;
    return RankingService.podioCompleto(
      propioTerminado: propioTerminado,
      propioEliminado: sala.eliminadoPropio,
      rivales: rivales,
    );
  }

  int? _extraerMarcaFin(
    Map<String, dynamic>? estado,
    Map<String, int> tiemposZonas,
    bool terminado,
  ) {
    if (!terminado) return null;
    final explicito = estado?['finished_at'];
    if (explicito is int) return explicito;
    if (tiemposZonas.isEmpty) return null;
    var maximo = 0;
    for (final tiempo in tiemposZonas.values) {
      if (tiempo > maximo) maximo = tiempo;
    }
    return maximo > 0 ? maximo : null;
  }

  Map<String, dynamic> _serializarEstadoPropio({bool forzarFinalizado = false}) {
    final json = _juego.toJson();
    if (_esPartidaClasificatoria) {
      json['ranked'] = true;
    }
    if (forzarFinalizado) {
      json['finished'] = true;
    }
    if (_juego.finalizada) {
      final marcaFin = _extraerMarcaFin(
        _sala.estadoPropio,
        _juego.tiemposPorZona,
        true,
      );
      json['finished_at'] = marcaFin ?? DateTime.now().millisecondsSinceEpoch;
    }
    return json;
  }

  void _verificarFinClasificatoria(EstadoSalaMultijugador sala) {
    final terminada =
        sala.estado == 'finalizada' || _podioClasificatorioCompleto(sala);
    if (!terminada) return;

    final requiereMarcarFinServidor =
        _esPartidaClasificatoria &&
        sala.estado == 'activa' &&
        !_juego.finalizada &&
        sala.estadoPropio?['finished'] != true &&
        !sala.eliminadoPropio;

    _finalizadaPorPodio = true;
    if (requiereMarcarFinServidor && _pendiente == null) {
      _pendiente = _serializarEstadoPropio(forzarFinalizado: true);
    }

    if (_esPartidaClasificatoria && !_eloActualizado) {
      _eloActualizado = true;
      final podio = _calcularPodioActual(sala);
      final servicio =
          widget.rankingService ??
          RankingService(
            widget.service.supabaseClient,
            token: widget.service.sessionToken,
          );
      unawaited(
        servicio
            .aplicarCambioElo(
              usuario: widget.usuario,
              deltaElo: podio.propio.deltaElo,
            )
            .then((nuevoElo) {
              if (!mounted) return;
              setState(() {
                _nuevoEloGuardado = nuevoElo;
                _errorGuardandoElo = nuevoElo == null;
              });
            }),
      );
    }
  }

  ResultadoPodioClasificatoria _calcularPodioActual(
    EstadoSalaMultijugador sala,
  ) {
    final vistas = _construirVistasRivales(sala);
    final puntosPropios = _juego.puntosPorZona.isNotEmpty
        ? _juego.puntos
        : (sala.estadoPropio?['score'] is int
              ? sala.estadoPropio!['score'] as int
              : _juego.puntos);
    final propioTerminado =
        _juego.finalizada || sala.estadoPropio?['finished'] == true;
    final propioTerminadoEn = _extraerMarcaFin(
      sala.estadoPropio,
      _juego.tiemposPorZona,
      propioTerminado,
    );
    final propioZonasPrimero = _juego.posicionesPorZona.values
        .where((pos) => pos == 1)
        .length;

    return RankingService.calcularPodioSala(
      usuarioPropio: widget.usuario,
      puntosPropios: puntosPropios,
      turnosOmitidosPropios: _juego.turnosOmitidos,
      propioTerminado: propioTerminado,
      propioEliminado: sala.eliminadoPropio,
      propioTerminadoEn: propioTerminadoEn,
      propioZonasPrimerLugar: propioZonasPrimero,
      rivales: [
        for (final rival in sala.rivalesEfectivos)
          (
            usuario: rival.usuario,
            puntos: vistas[rival.usuario]?.puntos ?? rival.puntos,
            turnosOmitidos: rival.turnosOmitidos,
            terminado: rival.terminado,
            eliminado: rival.eliminado,
            terminadoEn: _extraerMarcaFin(
              rival.estado,
              vistas[rival.usuario]?.tiemposPorZona ?? const {},
              rival.terminado,
            ),
            zonasPrimerLugar:
                (vistas[rival.usuario]?.posicionesPorZona.values ?? const [])
                    .where((pos) => pos == 1)
                    .length,
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sala = widget.salaInicial;
    _config = _configuracion(_sala.configId);
    _juego = _crearJuego(_sala);
    _sincronizarPosicionesDeZonas(_sala);
    _observacionInicialCompleta = true;
    _verificarFinClasificatoria(_sala);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _sincronizar());
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _hayRivalDesconectado && _sala.estado == 'activa') {
        setState(() {});
      }
    });
    if ((_sala.estadoPropio == null ||
            _sala.estadoPropio!['zone_times'] == null ||
            _sala.estadoPropio!['score'] != _juego.puntos ||
            (_esPartidaClasificatoria &&
                _sala.estadoPropio!['ranked'] != true)) &&
        _sala.estado == 'activa') {
      _pendiente ??= _serializarEstadoPropio(
        forzarFinalizado: _finalizadaPorPodio,
      );
      unawaited(_sincronizar());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_sincronizar());
  }

  JuegoBloc _crearJuego(EstadoSalaMultijugador sala) {
    final tablero = Tablero.desdeConfig(_config);
    if (sala.estadoPropio != null) {
      final estado = Map<String, dynamic>.from(sala.estadoPropio!);
      if (estado['zone_times'] is! Map) {
        estado['zone_times'] = <String, int>{
          for (final region in _config.regiones) region.id: _marcaInicioVista,
        };
      }
      return JuegoBloc.restaurar(tablero, estado);
    }
    final valoresIniciales = sala.valoresIniciales;
    if (valoresIniciales == null) {
      throw StateError('El tablero inicial aún no fue confirmado.');
    }
    for (var index = 0; index < _config.iniciales.length; index++) {
      final position = _config.iniciales.values.elementAt(index);
      if (!tablero.agregar(position, valoresIniciales[index])) {
        throw StateError('La configuración inicial del servidor no es válida.');
      }
    }
    return JuegoBloc(tablero);
  }

  void _reemplazarEstado(Map<String, dynamic> state) {
    final next = JuegoBloc.restaurar(Tablero.desdeConfig(_config), state);
    _juego.dispose();
    _juego = next;
  }

  Future<void> _sincronizar() async {
    if (_sincronizando || !mounted) return;
    _sincronizando = true;
    try {
      if (_pendiente != null) {
        while (_pendiente != null && mounted) {
          final aGuardar = _pendiente!;
          _pendiente = null;
          try {
            final saved = await widget.service.guardarEstado(
              codigo: _sala.codigo,
              version: _sala.versionPropia,
              estado: aGuardar,
            );
            _aplicarSala(saved);
          } on MultijugadorException catch (error) {
            if (error.statusCode != 409) {
              _pendiente ??= aGuardar;
              rethrow;
            }
            final current = await widget.service.consultar(_sala.codigo);
            if (_pendiente == null &&
                current.versionPropia > _sala.versionPropia &&
                current.estadoPropio != null) {
              _reemplazarEstado(current.estadoPropio!);
            }
            _aplicarSala(current);
          }
        }
      } else {
        final current = await widget.service.consultar(_sala.codigo);
        if (_pendiente == null &&
            current.versionPropia > _sala.versionPropia &&
            current.estadoPropio != null) {
          _reemplazarEstado(current.estadoPropio!);
        }
        _aplicarSala(current);
      }
      if (mounted && _errorConexion != null) {
        setState(() => _errorConexion = null);
      }
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _errorConexion = error.message);
    } catch (error) {
      if (mounted) {
        setState(() => _errorConexion = 'No se pudo sincronizar: $error');
      }
    } finally {
      _sincronizando = false;
      if (mounted && _pendiente != null) {
        unawaited(_sincronizar());
      }
    }
  }

  Map<String, _VistaTableroRival> _construirVistasRivales(
    EstadoSalaMultijugador sala,
  ) {
    final rivales = sala.rivalesEfectivos;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final misTiempos = _juego.puntuacion.tiemposCompletado;
    final vistas = <String, _VistaTableroRival>{};

    for (final rival in rivales) {
      final observados = _tiemposObservadosRivales.putIfAbsent(
        rival.usuario,
        () => <String, int>{},
      );
      final explicitos = PuntuacionPartida.extraerMapaEnteros(
        rival.estado?['zone_times'],
      );
      observados.addAll(explicitos);

      final vista = _VistaTableroRival(
        rival: rival,
        config: _config,
        tiemposObservados: Map<String, int>.from(observados),
      );
      for (final entrada in vista.tiemposPorZona.entries) {
        if (!observados.containsKey(entrada.key)) {
          if (!_observacionInicialCompleta) {
            observados[entrada.key] = _marcaInicioVista;
          } else {
            final miTiempo = misTiempos[entrada.key];
            observados[entrada.key] = (miTiempo != null && ahora <= miTiempo)
                ? miTiempo + 1
                : ahora;
          }
        }
      }
      // Reconstruir con los tiempos observados ya consolidados
      vistas[rival.usuario] = _VistaTableroRival(
        rival: rival,
        config: _config,
        tiemposObservados: Map<String, int>.from(observados),
      );
    }

    final todosLosJugadores = <({String usuario, Map<String, int> tiemposZonas})>[
      (usuario: widget.usuario, tiemposZonas: _juego.tiemposPorZona),
      for (final entrada in vistas.entries)
        (usuario: entrada.key, tiemposZonas: entrada.value.tiemposPorZona),
    ];

    _juego.puntuacion.sincronizarConRivales(
      usuarioPropio: widget.usuario,
      rivales: todosLosJugadores,
    );
    for (final entrada in vistas.entries) {
      entrada.value.puntuacion.sincronizarConRivales(
        usuarioPropio: entrada.key,
        rivales: todosLosJugadores,
      );
    }
    return vistas;
  }

  Map<String, int> _calcularTiemposMinimosRivales(
    EstadoSalaMultijugador sala,
  ) {
    final vistas = _construirVistasRivales(sala);
    final maxPorZona = <String, int>{};
    for (final vista in vistas.values) {
      for (final entry in vista.tiemposPorZona.entries) {
        final actual = maxPorZona[entry.key];
        if (actual == null || entry.value > actual) {
          maxPorZona[entry.key] = entry.value;
        }
      }
    }
    return maxPorZona;
  }

  bool _sincronizarPosicionesDeZonas(EstadoSalaMultijugador sala) {
    final puntajeAntes = _juego.puntos;
    final posicionesAntes = Map<String, int>.from(_juego.posicionesPorZona);
    _construirVistasRivales(sala);
    if (_juego.puntos != puntajeAntes) return true;
    if (_juego.posicionesPorZona.length != posicionesAntes.length) return true;
    for (final entry in _juego.posicionesPorZona.entries) {
      if (posicionesAntes[entry.key] != entry.value) return true;
    }
    return false;
  }

  void _aplicarSala(EstadoSalaMultijugador sala) {
    final cambioPropio = _sincronizarPosicionesDeZonas(sala);
    if (mounted) {
      setState(() {
        _sala = sala;
        _verificarFinClasificatoria(sala);
        if (cambioPropio &&
            _pendiente == null &&
            sala.estado == 'activa' &&
            !sala.eliminadoPropio) {
          _pendiente = _serializarEstadoPropio(
            forzarFinalizado: _finalizadaPorPodio,
          );
        }
      });
      if (_pendiente != null && !_sincronizando && sala.estado == 'activa') {
        unawaited(_sincronizar());
      }
    }
  }

  void _seleccionarPivote(int index) {
    if (_sala.estado != 'activa' ||
        _finalizadaPorPodio ||
        _sala.eliminadoPropio ||
        _errorConexion != null ||
        _juego.finalizada) {
      return;
    }
    try {
      setState(() => _juego.elegirPivote(index));
    } on StateError catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _actuar(void Function() accion) {
    if (_sala.estado != 'activa' ||
        _finalizadaPorPodio ||
        _sala.eliminadoPropio ||
        _errorConexion != null ||
        _juego.finalizada) {
      return;
    }
    try {
      _juego.actualizarTiemposMinimosZonas(
        _calcularTiemposMinimosRivales(_sala),
      );
      accion();
      _sincronizarPosicionesDeZonas(_sala);
      setState(() {
        _verificarFinClasificatoria(_sala);
        _pendiente = _serializarEstadoPropio(
          forzarFinalizado: _finalizadaPorPodio,
        );
      });
      unawaited(_sincronizar());
    } on StateError catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _conceder() async {
    final rivalesActivos = _sala.rivalesEfectivos
        .where((rival) => !rival.eliminado)
        .length;
    final mensaje = rivalesActivos > 1
        ? 'Quedarás eliminado de la partida y los demás jugadores continuarán '
              'hasta terminar. Esta acción no se puede deshacer.'
        : 'Tu rival ganará inmediatamente. Esta acción no se puede deshacer.';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Conceder la partida?'),
        content: Text(mensaje),
        actions: [
          TextButton(
            key: const ValueKey('cancelar-concesion'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Seguir jugando'),
          ),
          FilledButton(
            key: const ValueKey('confirmar-concesion'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Conceder'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    setState(() => _concediendo = true);
    try {
      final sala = await widget.service.conceder(_sala.codigo);
      _aplicarSala(sala);
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _errorConexion = error.message);
    } finally {
      if (mounted) setState(() => _concediendo = false);
    }
  }

  Future<void> _reclamarVictoria() async {
    try {
      final sala = await widget.service.reclamarDesconexion(_sala.codigo);
      _aplicarSala(sala);
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _errorConexion = error.message);
    }
  }

  String _estadoFinal() {
    if (_esPartidaClasificatoria) {
      final podio = _calcularPodioActual(_sala);
      if (podio.propio.puesto == 1 && !podio.propio.eliminado) {
        return '¡1.º puesto en Clasificatoria!';
      }
      if (podio.propio.puesto <= 3 && !podio.propio.eliminado) {
        return '¡${podio.propio.puesto}.º puesto en el podio!';
      }
      return 'Finalizaste en ${podio.propio.puesto}.º puesto';
    }
    if (_sala.ganador == null) return 'Empate';
    if (_sala.ganador == widget.usuario) return '¡Ganaste la partida!';
    return 'Ganó ${_sala.ganador}';
  }

  String _motivoFinal() {
    if (_esPartidaClasificatoria && _finalizadaPorPodio) {
      return 'Se completaron los puestos del podio (1.º, 2.º y 3.º).';
    }
    return switch (_sala.motivoFinalizacion) {
      'concesion' => 'La partida terminó por concesión.',
      'desconexion' => 'La partida terminó por desconexión.',
      'puntuacion' => 'Todos los tableros activos terminaron.',
      _ => 'Partida finalizada.',
    };
  }

  String _tiempoParaReclamarDesde(DateTime? until) {
    if (until == null) return '';
    final seconds = until.difference(_horaServidor).inSeconds;
    if (seconds <= 0) return 'ya puedes reclamar la desconexión.';
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return 'espera ${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')} para reclamarla.';
  }

  DateTime? get _proximoReclamoDisponible {
    DateTime? earliest = _sala.reclamarDesde;
    for (final rival in _sala.rivalesEfectivos) {
      if (rival.eliminado || rival.conectado || rival.reclamarDesde == null) {
        continue;
      }
      if (earliest == null || rival.reclamarDesde!.isBefore(earliest)) {
        earliest = rival.reclamarDesde;
      }
    }
    return earliest;
  }

  bool get _hayRivalDesconectado {
    final rivales = _sala.rivalesEfectivos.where((r) => !r.eliminado).toList();
    if (rivales.isEmpty) return !_sala.oponenteConectado;
    return rivales.any((r) => !r.conectado);
  }

  DateTime get _horaServidor =>
      _sala.horaServidor?.add(
        DateTime.now().difference(_sala.horaLocalRecibida),
      ) ??
      DateTime.now();

  String _descripcionEstadoRival(
    JugadorMultijugador rival,
    _VistaTableroRival vista,
  ) {
    if (rival.eliminado) {
      final motivo = rival.motivoEliminacion == 'concesion'
          ? 'se rindió'
          : 'desconexión';
      return 'Eliminado ($motivo)';
    }
    if (vista.terminado) {
      return 'Tablero terminado';
    }
    if (rival.conectado) {
      return 'Conectado · En juego';
    }
    return 'Sin conexión';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _reloj?.cancel();
    _juego.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finalizada = _sala.estado == 'finalizada' || _finalizadaPorPodio;
    final reclamoDesde = _proximoReclamoDisponible;
    final puedeReclamar =
        !finalizada &&
        !_sala.eliminadoPropio &&
        _hayRivalDesconectado &&
        reclamoDesde != null &&
        !_horaServidor.isBefore(reclamoDesde);
    final puedeJugar =
        !finalizada &&
        !_sala.eliminadoPropio &&
        _sala.estado == 'activa' &&
        _errorConexion == null &&
        !_juego.finalizada;
    final rivales = _sala.rivalesEfectivos;
    final vistasRivales = _construirVistasRivales(_sala);
    JugadorMultijugador? rivalSeleccionado;
    if (_rivalSeleccionado != null) {
      for (final rival in rivales) {
        if (rival.usuario == _rivalSeleccionado) {
          rivalSeleccionado = rival;
          break;
        }
      }
    }

    return ZonaMusicaLobby(
      habilitarMusica: false,
      child: AnimatedBuilder(
        animation: ControladorTema.instance,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: Text(
              _esPartidaClasificatoria
                  ? 'Clasificatoria · ${_sala.codigo}'
                  : 'Partida · ${_sala.codigo}',
            ),
          actions: [
            const SelectorTemaButton(),
            IconButton(
              key: const ValueKey('copiar-codigo-partida'),
              tooltip: 'Copiar código de invitación',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _sala.codigo));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado.')),
                  );
                }
              },
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (finalizada)
                      Card(
                        color: _paleta.superficieAcentoSuave,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: _paleta.acento, width: 1.4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                _estadoFinal(),
                                key: const ValueKey('resultado-multijugador'),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _paleta.acento,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _motivoFinal(),
                                style: TextStyle(color: _paleta.textoPrincipal),
                              ),
                              if (_esPartidaClasificatoria) ...[
                                const SizedBox(height: 12),
                                _tarjetaPodioClasificatoria(),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      _tarjetaEstadoRivales(
                        rivales: rivales,
                        vistasRivales: vistasRivales,
                        puedeReclamar: puedeReclamar,
                        reclamoDesde: reclamoDesde,
                      ),
                    if (_sala.eliminadoPropio && !finalizada) ...[
                      const SizedBox(height: 8),
                      Card(
                        key: const ValueKey('jugador-eliminado-aviso'),
                        color: _paleta.errorSuperficie,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: _paleta.error),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text(
                                'Quedaste eliminado de la partida. Puedes seguir '
                                'viendo los tableros de los demás jugadores.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _paleta.errorTexto,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                key: const ValueKey('salir-partida-eliminado'),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Volver al menú'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_errorConexion != null) ...[
                      const SizedBox(height: 8),
                      MaterialBanner(
                        key: const ValueKey('banner-sin-conexion'),
                        content: Text(
                          'Sin conexión con la partida: $_errorConexion. '
                          'Se reintentará automáticamente; no se aceptan '
                          'jugadas nuevas hasta sincronizar.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: _sincronizar,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ],
                    if (rivales.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _selectorTableros(
                        rivales: rivales,
                        vistasRivales: vistasRivales,
                        rivalSeleccionado: rivalSeleccionado,
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (rivalSeleccionado != null)
                      _seccionTableroRival(
                        rival: rivalSeleccionado,
                        vista: vistasRivales[rivalSeleccionado.usuario]!,
                        mostrarBotonVolver: true,
                      )
                    else
                      _seccionTableroPropio(
                        puedeJugar: puedeJugar,
                        finalizada: finalizada,
                      ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      key: const ValueKey('conceder-partida'),
                      onPressed:
                          finalizada ||
                              _sala.eliminadoPropio ||
                              _concediendo ||
                              _sincronizando ||
                              _pendiente != null ||
                              _errorConexion != null
                          ? null
                          : _conceder,
                      style: FilledButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: Text(
                        _concediendo ? 'Concediendo...' : 'Conceder partida',
                      ),
                    ),
                    if (finalizada) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        key: const ValueKey('salir-partida-finalizada'),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Volver al menú'),
                      ),
                    ],
                  ],
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaPodioClasificatoria() {
    final podio = _calcularPodioActual(_sala);
    final propio = podio.propio;
    final delta = propio.deltaElo;
    final signo = delta >= 0 ? '+' : '';
    final detalleBono = delta >= 0
        ? '(+${propio.bonoPuesto} por ${propio.puesto}.º puesto + '
              '${propio.puntosPartida} pts de partida)'
        : '(${propio.puesto}.º puesto · ${propio.puntosPartida} pts de partida)';

    return Container(
      key: const ValueKey('resumen-elo-clasificatoria'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _paleta.superficieInterior,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _paleta.acento),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cambio de Elo: $signo$delta Elo $detalleBono',
            key: const ValueKey('cambio-elo-propio'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: delta >= 0
                  ? _paleta.acento
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          if (_nuevoEloGuardado != null) ...[
            const SizedBox(height: 4),
            Text(
              'Tu nuevo Elo: $_nuevoEloGuardado',
              key: const ValueKey('nuevo-elo-guardado'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _paleta.textoPrincipal,
              ),
            ),
          ] else if (_errorGuardandoElo) ...[
            const SizedBox(height: 4),
            Text(
              'No se pudo guardar el Elo en Supabase (revisa el permiso UPDATE y la política RLS para el rol anon en public.usuarios).',
              key: const ValueKey('error-guardando-elo'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const Divider(height: 16),
          Text(
            'Podio de la partida',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: _paleta.textoPrincipal,
            ),
          ),
          const SizedBox(height: 6),
          for (final entrada in podio.clasificacion)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${entrada.puesto}.º',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _paleta.acento,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${entrada.usuario}'
                      '${entrada.eliminado ? " (eliminado)" : ""}',
                      style: TextStyle(
                        color: _paleta.textoPrincipal,
                        fontWeight: entrada.usuario == widget.usuario
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${entrada.puntosPartida} pts',
                    style: TextStyle(color: _paleta.textoSecundario),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${entrada.deltaElo >= 0 ? "+" : ""}${entrada.deltaElo} Elo',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: entrada.deltaElo >= 0
                          ? _paleta.acento
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _insigniaDato({
    required IconData icono,
    required String texto,
    Key? textoKey,
    Color? fondo,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: fondo ?? _paleta.superficieInterior,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _paleta.bordeSecundario),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 15, color: _paleta.acento),
        const SizedBox(width: 6),
        Text(
          texto,
          key: textoKey,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _paleta.textoPrincipal,
          ),
        ),
      ],
    ),
  );

  Widget _tarjetaEstadoRivales({
    required List<JugadorMultijugador> rivales,
    required Map<String, _VistaTableroRival> vistasRivales,
    required bool puedeReclamar,
    required DateTime? reclamoDesde,
  }) {
    final totalCasillas = _config.matriz.length * _config.matriz.first.length;
    if (rivales.length <= 1) {
      final rival = rivales.isNotEmpty
          ? rivales.first
          : JugadorMultijugador(
              usuario: _sala.usuarioOponente ?? 'Rival',
              esAnfitrion: !_sala.esAnfitrion,
              conectado: _sala.oponenteConectado,
              listo: _sala.estadoOponente != null,
              estado: _sala.estadoOponente,
              reclamarDesde: _sala.reclamarDesde,
            );
      final vista = vistasRivales[rival.usuario];
      final puntos = vista?.puntos ?? (_sala.estadoOponente?['score'] ?? 0);
      final terminado =
          vista?.terminado ?? (_sala.estadoOponente?['finished'] == true);
      final casillasRival = vista?.tablero.datos.length ?? 6;

      return Card(
        key: const ValueKey('marcador-1v1'),
        elevation: 0,
        color: _paleta.panelSecundario,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: _paleta.bordeSecundario),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _paleta.superficieInterior,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _paleta.bordeSecundario,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: _paleta.acento,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.usuario} (Tú)',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: _paleta.textoPrincipal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_juego.puntos} pts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _paleta.acento,
                            ),
                          ),
                          Text(
                            'Casillas: ${_juego.tablero.datos.length}/$totalCasillas · '
                            'Turnos: ${_juego.turnosJugados}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _paleta.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _paleta.acento,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: _paleta.textoSobreAcento,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _paleta.superficieInterior,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _paleta.bordeSecundario,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: rival.eliminado
                                      ? Colors.red
                                      : rival.conectado
                                      ? const Color(0xFF2ECC71)
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  rival.usuario,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: _paleta.textoPrincipal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (_sala.estadoOponente != null || vista != null)
                            Text(
                              'Puntuación rival: $puntos'
                              '${terminado ? " · tablero terminado" : ""}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _paleta.acento,
                              ),
                            ),
                          Text(
                            'Casillas: $casillasRival/$totalCasillas · '
                            'Turnos: ${vista?.turnosJugados ?? 0}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _paleta.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                rival.eliminado
                    ? '${rival.usuario} quedó eliminado'
                    : rival.conectado
                    ? '${rival.usuario} está conectado'
                    : '${rival.usuario} perdió la conexión; '
                          '${_tiempoParaReclamarDesde(reclamoDesde)}',
                key: const ValueKey('estado-oponente'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: _paleta.textoSecundario),
              ),
              if (puedeReclamar) ...[
                const SizedBox(height: 8),
                FilledButton.tonal(
                  key: const ValueKey('reclamar-victoria'),
                  onPressed: _reclamarVictoria,
                  child: const Text('Reclamar victoria por desconexión'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final activos = rivales.where((r) => !r.eliminado).length;
    return Card(
      elevation: 0,
      color: _paleta.panelSecundario,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _paleta.bordeSecundario),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rivales en la partida ($activos activos de ${rivales.length})',
              key: const ValueKey('estado-oponente'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _paleta.textoPrincipal,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final rival in rivales)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _paleta.superficieInterior,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _paleta.bordeSecundario),
                    ),
                    child: Text(
                      '${rival.usuario} · ${vistasRivales[rival.usuario]?.puntos ?? 0} pts · '
                      '${_descripcionEstadoRival(rival, vistasRivales[rival.usuario]!)}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _paleta.textoPrincipal,
                      ),
                    ),
                  ),
              ],
            ),
            if (_hayRivalDesconectado && !puedeReclamar && reclamoDesde != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Rival sin conexión; ${_tiempoParaReclamarDesde(reclamoDesde)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _paleta.textoSecundario),
                ),
              ),
            if (puedeReclamar) ...[
              const SizedBox(height: 8),
              Center(
                child: FilledButton.tonal(
                  key: const ValueKey('reclamar-victoria'),
                  onPressed: _reclamarVictoria,
                  child: Text(
                    activos <= 1
                        ? 'Reclamar victoria por desconexión'
                        : 'Eliminar rival por desconexión',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _selectorTableros({
    required List<JugadorMultijugador> rivales,
    required Map<String, _VistaTableroRival> vistasRivales,
    required JugadorMultijugador? rivalSeleccionado,
  }) => Card(
    key: const ValueKey('selector-tableros'),
    elevation: 0,
    color: _paleta.panelSecundario,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: _paleta.bordeSecundario),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard_customize_outlined,
                size: 18,
                color: _paleta.acento,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ver tableros de la partida',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _paleta.textoPrincipal,
                  ),
                ),
              ),
              Text(
                '${rivales.length + 1} jugadores',
                style: TextStyle(fontSize: 12, color: _paleta.textoSecundario),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                key: const ValueKey('ver-tablero-propio'),
                avatar: const Icon(Icons.person, size: 18),
                label: Text('Tu tablero (${_juego.puntos} pts)'),
                selected: rivalSeleccionado == null,
                onSelected: (_) {
                  setState(() => _rivalSeleccionado = null);
                },
              ),
              for (final rival in rivales)
                ChoiceChip(
                  key: ValueKey('ver-tablero-${rival.usuario}'),
                  avatar: Icon(
                    rival.eliminado
                        ? Icons.block
                        : (vistasRivales[rival.usuario]?.terminado ?? false)
                        ? Icons.check_circle_outline
                        : rival.conectado
                        ? Icons.grid_on
                        : Icons.wifi_off,
                    size: 18,
                  ),
                  label: Text(
                    '${rival.usuario} '
                    '(${vistasRivales[rival.usuario]?.puntos ?? 0} pts)',
                  ),
                  selected: rivalSeleccionado?.usuario == rival.usuario,
                  onSelected: (_) {
                    setState(() => _rivalSeleccionado = rival.usuario);
                  },
                ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _seccionTableroPropio({
    required bool puedeJugar,
    required bool finalizada,
  }) {
    final totalCasillas = _config.matriz.length * _config.matriz.first.length;
    return Card(
      elevation: 0,
      color: _paleta.panelSecundario,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _paleta.bordeSecundario),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.grid_view_rounded, color: _paleta.acento),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_config.nombre} · Tu tablero',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _paleta.textoPrincipal,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _paleta.superficieAcentoSuave,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _paleta.acento),
                  ),
                  child: Text(
                    'Tú: ${_juego.puntos} pts',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _paleta.acento,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _insigniaDato(
                  icono: Icons.grid_on_rounded,
                  texto:
                      'Casillas: ${_juego.tablero.datos.length}/$totalCasillas',
                ),
                _insigniaDato(
                  icono: Icons.layers_outlined,
                  texto:
                      'Zonas: ${_juego.puntosPorZona.length}/${_config.regiones.length}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final board = ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: TableroVisual(
                    valores: const {},
                    habilitado: false,
                    onSeleccionar: (_) {},
                    tablero: _juego.tablero,
                    config: _config,
                    iluminadas: puedeJugar
                        ? _juego.casillasIluminadas
                        : const {},
                    onJugar: puedeJugar
                        ? (position) => _actuar(() {
                            if (!_juego.colocar(position)) {
                              throw StateError('Esa jugada ya no es válida.');
                            }
                          })
                        : null,
                  ),
                );
                final scores = TablaPuntos(
                  puntos: _juego.puntos,
                  obtenidos: _juego.puntosPorZona,
                  posiciones: _juego.posicionesPorZona,
                  config: _config,
                );
                if (constraints.maxWidth >= 760) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Center(child: board)),
                      const SizedBox(width: 16),
                      SizedBox(width: 220, child: scores),
                    ],
                  );
                }
                return Column(
                  children: [
                    Center(child: board),
                    const SizedBox(height: 12),
                    scores,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder<int>(
              stream: _juego.cambios,
              initialData: 0,
              builder: (context, _) => _controles(puedeJugar, finalizada),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionTableroRival({
    required JugadorMultijugador rival,
    required _VistaTableroRival vista,
    required bool mostrarBotonVolver,
  }) {
    final totalCasillas = _config.matriz.length * _config.matriz.first.length;
    return Card(
      key: ValueKey('panel-tablero-rival-${rival.usuario}'),
      elevation: 0,
      color: _paleta.panelSecundario,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _paleta.bordeSecundario),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.visibility_outlined, color: _paleta.acento),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_config.nombre} · Tablero de ${rival.usuario}',
                    key: const ValueKey('titulo-tablero-rival'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _paleta.textoPrincipal,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _paleta.superficieAcentoSuave,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _paleta.acento),
                  ),
                  child: Text(
                    '${rival.usuario}: ${vista.puntos} pts',
                    key: const ValueKey('puntaje-tablero-rival'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _paleta.acento,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Estado: ${_descripcionEstadoRival(rival, vista)}',
                    key: const ValueKey('estado-detalle-rival'),
                    style: TextStyle(color: _paleta.textoSecundario),
                  ),
                ),
                if (mostrarBotonVolver)
                  TextButton.icon(
                    key: const ValueKey('volver-tablero-propio'),
                    onPressed: () => setState(() => _rivalSeleccionado = null),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Volver a mi tablero'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _insigniaDato(
                  icono: Icons.grid_on_rounded,
                  texto:
                      'Casillas: ${vista.tablero.datos.length}/$totalCasillas',
                ),
                _insigniaDato(
                  icono: Icons.layers_outlined,
                  texto:
                      'Zonas: ${vista.puntosPorZona.length}/${_config.regiones.length}',
                ),
                _insigniaDato(
                  icono: Icons.history_rounded,
                  texto:
                      'Jugadas: ${vista.turnosJugados} · '
                      'Omitidas: ${vista.turnosOmitidos}',
                  textoKey: const ValueKey('contador-turnos-rival'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final board = ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: TableroVisual(
                    key: ValueKey('tablero-rival-${rival.usuario}'),
                    prefijoCelda: 'celda-rival',
                    valores: const {},
                    habilitado: false,
                    onSeleccionar: (_) {},
                    tablero: vista.tablero,
                    config: _config,
                  ),
                );
                final scores = TablaPuntos(
                  prefijoKey: 'rival-',
                  puntos: vista.puntos,
                  obtenidos: vista.puntosPorZona,
                  posiciones: vista.posicionesPorZona,
                  config: _config,
                );
                if (constraints.maxWidth >= 760) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Center(child: board)),
                      const SizedBox(width: 16),
                      SizedBox(width: 220, child: scores),
                    ],
                  );
                }
                return Column(
                  children: [
                    Center(child: board),
                    const SizedBox(height: 12),
                    scores,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _controles(bool puedeJugar, bool finalizada) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _paleta.superficieInterior,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _paleta.bordeSecundario),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_juego.finalizada && !finalizada) ...[
          Text(
            'Tu tablero terminó. Se guardará tu puntuación y se espera a los demás jugadores.',
            key: const ValueKey('tablero-propio-finalizado'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _paleta.acento,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Icon(Icons.casino_outlined, size: 20, color: _paleta.acento),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Turno de juego',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _paleta.textoPrincipal,
                ),
              ),
            ),
            if (_juego.pivote != null && !_juego.finalizada)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _paleta.superficieAcentoSuave,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _paleta.acento),
                ),
                child: Text(
                  'Colocar: ${_juego.valorAColocar} '
                  '(${_juego.casillasIluminadas.length} opciones)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _paleta.acento,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _juego.bloqueado && !_juego.finalizada
              ? 'No quedan jugadas válidas.'
              : _juego.pivote == null
              ? 'Elige un dado como pivote.'
              : _juego.casillasIluminadas.isEmpty
              ? 'No hay casillas válidas con este pivote. '
                    'Prueba el otro dado o pulsa Omitir.'
              : 'Toca una casilla iluminada para colocar '
                    '${_juego.valorAColocar}.',
          key: const ValueKey('instruccion-multijugador'),
          style: TextStyle(color: _paleta.textoSecundario),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var index = 0; index < 2; index++) ...[
              if (index > 0) const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _juego.pivote == null
                            ? 'Dado ${index + 1}'
                            : _juego.pivote == index
                            ? 'Dado ${index + 1} · Pivote'
                            : 'Dado ${index + 1} · Valor a colocar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _juego.pivote == index
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _juego.pivote == index
                              ? _paleta.acento
                              : _paleta.textoSecundario,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      key: ValueKey('dado-multijugador-$index'),
                      onPressed: puedeJugar && _juego.tiradaPendiente
                          ? () => _seleccionarPivote(index)
                          : null,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _juego.pivote == index
                            ? _paleta.superficieAcentoSuave
                            : _paleta.panelSecundario,
                        foregroundColor: _juego.pivote == index
                            ? _paleta.acento
                            : _paleta.textoPrincipal,
                        side: BorderSide(
                          color: _juego.pivote == index
                              ? _paleta.acento
                              : _paleta.bordeSecundario,
                          width: _juego.pivote == index ? 2 : 1.2,
                        ),
                      ),
                      child: Text(
                        '${index == 0 ? _juego.dadoA ?? "–" : _juego.dadoB ?? "–"}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _juego.pivote == index
                              ? _paleta.acento
                              : _paleta.textoPrincipal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const ValueKey('omitir-multijugador'),
          onPressed: puedeJugar && _juego.tiradaPendiente
              ? () => _actuar(_juego.omitir)
              : null,
          child: const Text('Omitir tirada'),
        ),
        const SizedBox(height: 4),
        Text(
          'Jugadas: ${_juego.turnosJugados} · Omitidas: ${_juego.turnosOmitidos}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _paleta.textoSecundario,
          ),
        ),
      ],
    ),
  );
}

final List<NivelConfig> _niveles = [
  Nivel1Config(),
  Nivel2Config(),
  Nivel3Config(),
  Nivel4Config(),
];

NivelConfig _configuracion(String id) {
  for (final config in _niveles) {
    if (config.id == id) return config;
  }
  throw FormatException('Nivel desconocido: $id');
}
