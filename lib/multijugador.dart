import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/juego_bloc.dart';
import 'package:tipo/multijugador_service.dart';
import 'package:tipo/nivel_config.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tablero_config.dart';
import 'package:tipo/tabla_puntos.dart';
import 'package:tipo/tablero_visual.dart';

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
  final Map<String, int?> _valores = {};
  bool _ocupado = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = MultijugadorService(widget.supabaseClient, widget.token);
  }

  Future<void> _crearSala() async {
    final valores = [
      for (final region in _config.iniciales.keys) _valores[region],
    ];
    if (valores.any((value) => value == null) || valores.toSet().length != 6) {
      setState(() => _error = 'Asigna los números del 1 al 6 sin repetir.');
      return;
    }

    final tablero = Tablero.desdeConfig(_config);
    for (final entry in _config.iniciales.entries) {
      if (!tablero.agregar(entry.value, _valores[entry.key]!)) {
        setState(
          () => _error =
              'Esa distribución inicial no cumple las reglas del nivel.',
        );
        return;
      }
    }

    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final room = await _service.crear(
        configId: _config.id,
        valoresIniciales: valores.cast<int>(),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Multijugador'),
      leading: IconButton(
        key: const ValueKey('salir-multijugador'),
        onPressed: _ocupado ? null : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Crea una partida',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cada persona jugará en su propio tablero con la misma '
                'configuración inicial.',
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
                          _valores.clear();
                          _error = null;
                        });
                      },
              ),
              const SizedBox(height: 12),
              for (final region in _config.iniciales.keys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('valor-inicial-$region'),
                    initialValue: _valores[region],
                    decoration: InputDecoration(labelText: region),
                    items: [
                      for (var value = 1; value <= 6; value++)
                        DropdownMenuItem(value: value, child: Text('$value')),
                    ],
                    onChanged: _ocupado
                        ? null
                        : (value) => setState(() {
                            _valores[region] = value;
                            _error = null;
                          }),
                  ),
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
  );
}

class SalaMultijugadorPage extends StatefulWidget {
  const SalaMultijugadorPage({
    super.key,
    required this.service,
    required this.salaInicial,
    required this.usuario,
  });

  final MultijugadorService service;
  final EstadoSalaMultijugador salaInicial;
  final String usuario;

  @override
  State<SalaMultijugadorPage> createState() => _SalaMultijugadorPageState();
}

class _SalaMultijugadorPageState extends State<SalaMultijugadorPage> {
  late EstadoSalaMultijugador _sala;
  Timer? _timer;
  bool _consultando = false;
  bool _navegando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sala = widget.salaInicial;
    _programarConsulta();
    if (_sala.estado == 'activa') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _abrirPartida(_sala);
      });
    }
  }

  void _programarConsulta() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _consultar());
  }

  Future<void> _consultar() async {
    if (_consultando || _navegando || !mounted) return;
    _consultando = true;
    try {
      final sala = await widget.service.consultar(_sala.codigo);
      if (!mounted) return;
      setState(() {
        _sala = sala;
        _error = null;
      });
      if (sala.estado == 'activa') _abrirPartida(sala);
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      _consultando = false;
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
    final esperando = _sala.estado == 'esperando';
    return Scaffold(
      appBar: AppBar(title: const Text('Lobby')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    esperando ? Icons.hourglass_top : Icons.sports_esports,
                    size: 52,
                    color: const Color(0xFF193E37),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    esperando ? 'Esperando a tu rival' : 'Partida lista',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Comparte este código con tu rival:',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    _sala.codigo,
                    key: const ValueKey('codigo-sala'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w800,
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
                  if (esperando)
                    const Text(
                      'La sala se mantiene activa mientras esperas. '
                      'Si cierras la app, podrás volver a entrar usando el '
                      'mismo código.',
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      'Rival: ${_sala.usuarioOponente ?? "conectado"}',
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
                  if (esperando) ...[
                    const SizedBox(height: 24),
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
    );
  }
}

class PartidaMultijugadorPage extends StatefulWidget {
  const PartidaMultijugadorPage({
    super.key,
    required this.service,
    required this.salaInicial,
    required this.usuario,
  });

  final MultijugadorService service;
  final EstadoSalaMultijugador salaInicial;
  final String usuario;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sala = widget.salaInicial;
    _config = _configuracion(_sala.configId);
    _juego = _crearJuego(_sala);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _sincronizar());
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    if (_sala.estadoPropio == null && _sala.estado == 'activa') {
      _pendiente = _juego.toJson();
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
      return JuegoBloc.restaurar(tablero, sala.estadoPropio!);
    }
    for (var index = 0; index < _config.iniciales.length; index++) {
      final position = _config.iniciales.values.elementAt(index);
      if (!tablero.agregar(position, sala.valoresIniciales[index])) {
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
        try {
          final saved = await widget.service.guardarEstado(
            codigo: _sala.codigo,
            version: _sala.versionPropia,
            estado: _pendiente!,
          );
          _pendiente = null;
          _aplicarSala(saved);
        } on MultijugadorException catch (error) {
          if (error.statusCode != 409) rethrow;
          final current = await widget.service.consultar(_sala.codigo);
          if (current.versionPropia > _sala.versionPropia &&
              current.estadoPropio != null) {
            _pendiente = null;
            _reemplazarEstado(current.estadoPropio!);
          }
          _aplicarSala(current);
        }
      } else {
        final current = await widget.service.consultar(_sala.codigo);
        if (current.versionPropia > _sala.versionPropia &&
            current.estadoPropio != null) {
          _reemplazarEstado(current.estadoPropio!);
        }
        _aplicarSala(current);
      }
      if (mounted) setState(() => _errorConexion = null);
    } on MultijugadorException catch (error) {
      if (mounted) setState(() => _errorConexion = error.message);
    } catch (error) {
      if (mounted) {
        setState(() => _errorConexion = 'No se pudo sincronizar: $error');
      }
    } finally {
      _sincronizando = false;
      if (mounted) setState(() {});
    }
  }

  void _aplicarSala(EstadoSalaMultijugador sala) {
    if (mounted) setState(() => _sala = sala);
  }

  void _actuar(void Function() accion) {
    if (_sala.estado != 'activa' ||
        _errorConexion != null ||
        _pendiente != null ||
        _sincronizando ||
        _juego.finalizada) {
      return;
    }
    try {
      accion();
      setState(() => _pendiente = _juego.toJson());
      unawaited(_sincronizar());
    } on StateError catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _conceder() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Conceder la partida?'),
        content: const Text(
          'Tu rival ganará inmediatamente. Esta acción no se puede deshacer.',
        ),
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
    if (_sala.ganador == null) return 'Empate';
    if (_sala.ganador == widget.usuario) return '¡Ganaste la partida!';
    return 'Ganó ${_sala.ganador}';
  }

  String _motivoFinal() => switch (_sala.motivoFinalizacion) {
    'concesion' => 'La partida terminó por concesión.',
    'desconexion' => 'La partida terminó por desconexión.',
    'puntuacion' => 'Ambos tableros terminaron.',
    _ => 'Partida finalizada.',
  };

  String _tiempoParaReclamar() {
    final until = _sala.reclamarDesde;
    if (until == null) return '';
    final seconds = until.difference(_horaServidor).inSeconds;
    if (seconds <= 0) return 'ya puedes reclamar la victoria.';
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return 'espera ${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')} para reclamarla.';
  }

  DateTime get _horaServidor =>
      _sala.horaServidor?.add(
        DateTime.now().difference(_sala.horaLocalRecibida),
      ) ??
      DateTime.now();

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
    final finalizada = _sala.estado == 'finalizada';
    final puedeReclamar =
        !finalizada &&
        !_sala.oponenteConectado &&
        _sala.reclamarDesde != null &&
        !_horaServidor.isBefore(_sala.reclamarDesde!);
    final puedeJugar =
        !finalizada &&
        _sala.estado == 'activa' &&
        _errorConexion == null &&
        _pendiente == null &&
        !_sincronizando &&
        !_juego.finalizada;
    final rival = _sala.usuarioOponente ?? 'Rival';

    return Scaffold(
      appBar: AppBar(
        title: Text('Partida · ${_sala.codigo}'),
        actions: [
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
                      color: const Color(0xFFD4F4D8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              _estadoFinal(),
                              key: const ValueKey('resultado-multijugador'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(_motivoFinal()),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              _sala.oponenteConectado
                                  ? '$rival está conectado'
                                  : '$rival perdió la conexión; '
                                        '${_tiempoParaReclamar()}',
                              key: const ValueKey('estado-oponente'),
                              textAlign: TextAlign.center,
                            ),
                            if (_sala.estadoOponente != null)
                              Text(
                                'Puntuación rival: '
                                '${_sala.estadoOponente!['score'] ?? 0}'
                                '${_sala.estadoOponente!['finished'] == true ? " · tablero terminado" : ""}',
                              ),
                            if (puedeReclamar) ...[
                              const SizedBox(height: 8),
                              FilledButton.tonal(
                                key: const ValueKey('reclamar-victoria'),
                                onPressed: _reclamarVictoria,
                                child: const Text(
                                  'Reclamar victoria por desconexión',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.grid_view_rounded),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_config.nombre} · Tu tablero',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text('Tú: ${_juego.puntos} pts'),
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
                                    throw StateError(
                                      'Esa jugada ya no es válida.',
                                    );
                                  }
                                })
                              : null,
                        ),
                      );
                      final scores = TablaPuntos(
                        puntos: _juego.puntos,
                        obtenidos: _juego.puntosPorZona,
                        config: _config,
                      );
                      if (constraints.maxWidth >= 760) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Center(child: board)),
                            const SizedBox(width: 16),
                            SizedBox(width: 210, child: scores),
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
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    key: const ValueKey('conceder-partida'),
                    onPressed:
                        finalizada ||
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
    );
  }

  Widget _controles(bool puedeJugar, bool finalizada) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_juego.finalizada && !finalizada)
        const Text(
          'Tu tablero terminó. Se guardará tu puntuación y se espera al rival.',
          key: ValueKey('tablero-propio-finalizado'),
          textAlign: TextAlign.center,
        ),
      const Text(
        'Turno de juego',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          for (var index = 0; index < 2; index++) ...[
            if (index > 0) const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                key: ValueKey('dado-multijugador-$index'),
                onPressed: puedeJugar && _juego.tiradaPendiente
                    ? () => _actuar(() => _juego.elegirPivote(index))
                    : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: _juego.pivote == index
                      ? const Color(0xFFD4F4D8)
                      : Colors.white,
                ),
                child: Text(
                  '${index == 0 ? _juego.dadoA ?? "–" : _juego.dadoB ?? "–"}',
                  style: const TextStyle(fontSize: 24),
                ),
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
      Text(
        'Jugadas: ${_juego.turnosJugados} · Omitidas: ${_juego.turnosOmitidos}',
        textAlign: TextAlign.center,
      ),
    ],
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
