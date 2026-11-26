import 'dart:io' show exit;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/juego_bloc.dart';
import 'package:tipo/tablero_config.dart';
import 'package:tipo/nivel_config.dart';
import 'package:tipo/tabla_puntos.dart';
import 'package:tipo/valores_iniciales_bloc.dart';
import 'package:tipo/login.dart';
import 'package:tipo/perfil_usuario.dart';
import 'package:tipo/BDD.dart';
import 'package:tipo/sesion_usuario.dart';
import 'package:tipo/multijugador.dart';
import 'package:tipo/musica_lobby.dart';
import 'package:tipo/tablero_visual.dart';
import 'package:tipo/tema_app.dart';

export 'package:tipo/tablero_visual.dart' show TableroVisual;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ugsokviyojezfpbsdxyu.supabase.co',
    publishableKey: 'sb_publishable_58OIQdapcUTY03u9FXbO_A_plTZGVuo',
  );
  final supabaseClient = Supabase.instance.client;
  final sesionUsuario = SesionUsuario.instance;
  await sesionUsuario.restaurar(AuthService(supabaseClient));
  runApp(MainApp(supabaseClient: supabaseClient, sesionUsuario: sesionUsuario));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, this.supabaseClient, this.sesionUsuario});

  final SupabaseClient? supabaseClient;
  final SesionUsuario? sesionUsuario;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ControladorTema.instance,
    builder: (context, _) {
      final paleta = ControladorTema.instance.actual;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: paleta.toThemeData(),
        home: MenuPage(
          supabaseClient: supabaseClient,
          sesionUsuario: sesionUsuario,
        ),
      );
    },
  );
}

class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
    this.authService,
    this.supabaseClient,
    this.sesionUsuario,
  });

  final AuthService? authService;
  final SupabaseClient? supabaseClient;
  final SesionUsuario? sesionUsuario;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _cerrandoSesion = false;
  bool _eliminandoCuenta = false;

  SesionUsuario get _sesionEfectiva =>
      widget.sesionUsuario ?? SesionUsuario.instance;

  void _jugar(BuildContext context) {
    final session = _sesionEfectiva;
    if (!session.activa) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicia sesión o crea una cuenta para jugar.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SeleccionNivelPage(
          supabaseClient: widget.supabaseClient,
          sesionUsuario: session,
        ),
      ),
    );
  }

  void _abrirMultijugador(BuildContext context) {
    final session = _sesionEfectiva;
    final token = session.token;
    final username = session.usuarioName;
    final client = widget.supabaseClient;
    if (token == null || username == null || client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicia sesión para crear o unirte a una partida.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SeleccionModoMultijugadorPage(
          supabaseClient: client,
          token: token,
          usuario: username,
        ),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    final authService =
        widget.authService ??
        (widget.supabaseClient == null
            ? null
            : AuthService(widget.supabaseClient!));
    final session = _sesionEfectiva;
    final token = session.token;
    if (authService == null ||
        token == null ||
        _cerrandoSesion ||
        _eliminandoCuenta) {
      return;
    }

    setState(() => _cerrandoSesion = true);
    try {
      await authService.cerrarSesion(token);
      await session.limpiar();
    } on AuthServiceException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        await session.limpiar();
        return;
      }
      await session.limpiar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se cerró la sesión en este dispositivo, pero el servidor no '
            'pudo revocar el token: ${error.message}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _cerrandoSesion = false);
    }
  }

  Future<void> _confirmarEliminarCuenta() async {
    final paleta = ControladorTema.instance.actual;
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: paleta.panelSecundario,
        title: Text(
          '¿Eliminar cuenta?',
          style: TextStyle(color: paleta.textoPrincipal),
        ),
        content: Text(
          'Esta acción eliminará tu cuenta y cerrará todas tus sesiones. '
          'No se puede deshacer.',
          style: TextStyle(color: paleta.textoPrincipal),
        ),
        actions: [
          TextButton(
            key: const ValueKey('cancelar-eliminar-cuenta'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const ValueKey('confirmar-eliminar-cuenta'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
    if (confirmacion != true || !mounted) return;
    if (_cerrandoSesion || _eliminandoCuenta) return;

    final session = _sesionEfectiva;
    final token = session.token;
    if (token == null) return;

    final authService =
        widget.authService ??
        (widget.supabaseClient == null
            ? null
            : AuthService(widget.supabaseClient!));
    if (authService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No está disponible el servicio de autenticación.'),
        ),
      );
      return;
    }

    setState(() => _eliminandoCuenta = true);
    try {
      await authService.eliminarCuenta(token);
      await session.limpiar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cuenta se eliminó correctamente.')),
      );
    } on AuthServiceException catch (error) {
      if (error.statusCode == 401) {
        await session.limpiar();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar la cuenta: ${error.message}'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la cuenta: $error')),
      );
    } finally {
      if (mounted) setState(() => _eliminandoCuenta = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _sesionEfectiva;
    return AnimatedBuilder(
      animation: Listenable.merge([session, ControladorTema.instance]),
      builder: (context, _) {
        if (!session.activa) {
          return LoginPage(
            authService: widget.authService,
            supabaseClient: widget.supabaseClient,
            sesionUsuario: session,
          );
        }
        return _buildMenu(context, true, ControladorTema.instance.actual);
      },
    );
  }

  Widget _botonAccesoEsquina(
    BuildContext context,
    bool sesionActiva,
    PaletaTema paleta,
  ) {
    final client = widget.supabaseClient;
    final ocupada = _cerrandoSesion || _eliminandoCuenta;
    final session = _sesionEfectiva;
    final username = session.usuarioName;

    if (!sesionActiva || username == null) {
      return Tooltip(
        message: 'Iniciar sesión',
        child: Material(
          color: paleta.panelSecundario,
          shape: CircleBorder(
            side: BorderSide(color: paleta.acento, width: 1.5),
          ),
          elevation: 2,
          child: InkWell(
            key: const ValueKey('iniciar-sesion'),
            customBorder: const CircleBorder(),
            onTap: ocupada
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LoginPage(
                        supabaseClient: client,
                        sesionUsuario: session,
                      ),
                    ),
                  ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.person_outline_rounded,
                color: paleta.acento,
                size: 24,
              ),
            ),
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      key: const ValueKey('perfil-usuario'),
      tooltip: 'Menú de perfil',
      enabled: !ocupada,
      position: PopupMenuPosition.under,
      color: paleta.panelSecundario,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: paleta.bordeSecundario, width: 1.2),
      ),
      onSelected: (opcion) {
        if (opcion == 'cerrar_sesion') {
          _cerrarSesion();
        } else if (opcion == 'eliminar_cuenta') {
          _confirmarEliminarCuenta();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          key: const ValueKey('cerrar-sesion'),
          value: 'cerrar_sesion',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: paleta.acento),
              const SizedBox(width: 10),
              Text(
                _cerrandoSesion ? 'Cerrando sesión...' : 'Cerrar sesión',
                style: TextStyle(color: paleta.textoPrincipal),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          key: const ValueKey('eliminar-cuenta'),
          value: 'eliminar_cuenta',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: paleta.error,
              ),
              const SizedBox(width: 10),
              Text(
                _eliminandoCuenta ? 'Eliminando cuenta...' : 'Eliminar cuenta',
                style: TextStyle(
                  color: paleta.errorTexto,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Material(
        color: paleta.panelSecundario,
        shape: StadiumBorder(
          side: BorderSide(color: paleta.bordeSecundario, width: 1.4),
        ),
        elevation: 3,
        shadowColor: paleta.sombraPanel,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: paleta.acento,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: paleta.textoSobreAcento,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: paleta.textoPrincipal,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down_rounded, color: paleta.acento),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(
    BuildContext context,
    bool sesionActiva,
    PaletaTema paleta,
  ) => ZonaMusicaLobby(
    habilitarMusica: true,
    child: Scaffold(
      backgroundColor: paleta.fondoPrincipal,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              paleta.fondoGradienteInicio,
              paleta.fondoPrincipal,
              paleta.fondoGradienteFin,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    const BotonMusicaLobby(),
                    const SelectorTemaButton(),
                    _botonAccesoEsquina(context, sesionActiva, paleta),
                  ],
                ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 34,
                      ),
                      decoration: BoxDecoration(
                        color: paleta.panelSecundario,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: paleta.bordeSecundario,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: paleta.sombraPanel,
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: paleta.sombraAcento,
                            blurRadius: 24,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.sesionUsuario?.error case final error?) ...[
                            Text(
                              error,
                              key: const ValueKey('error-restaurar-sesion'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: paleta.errorTexto,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: paleta.superficieInterior,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: paleta.acento,
                                  width: 1.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: paleta.sombraAcento,
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.grid_view_rounded,
                                size: 38,
                                color: paleta.acento,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'BRILLIANT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                              color: paleta.textoPrincipal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Estrategia numérica en solitario y multijugador',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: paleta.textoSecundario,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          FilledButton(
                            key: const ValueKey('jugar'),
                            onPressed: () => _jugar(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: paleta.acento,
                              foregroundColor: paleta.textoSobreAcento,
                              elevation: 3,
                              shadowColor: paleta.sombraAcento,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(14),
                              child: Text(
                                'Jugar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            key: const ValueKey('multijugador'),
                            onPressed: () => _abrirMultijugador(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: paleta.superficieInterior,
                              foregroundColor: paleta.textoPrincipal,
                              side: BorderSide(
                                color: paleta.acento,
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(
                              Icons.people_alt_outlined,
                              color: paleta.acento,
                            ),
                            label: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                'Multijugador',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: paleta.textoPrincipal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            key: const ValueKey('cerrar-aplicacion'),
                            onPressed: () => exit(0),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: paleta.superficieInterior,
                              foregroundColor: paleta.textoPrincipal,
                              side: BorderSide(
                                color: paleta.bordeSecundario,
                                width: 1.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(
                              Icons.exit_to_app_rounded,
                              color: paleta.acento,
                            ),
                            label: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                'Salir del juego',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: paleta.textoPrincipal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}

class SeleccionNivelPage extends StatelessWidget {
  const SeleccionNivelPage({
    super.key,
    this.supabaseClient,
    this.sesionUsuario,
  });

  final SupabaseClient? supabaseClient;
  final SesionUsuario? sesionUsuario;

  void _seleccionar(BuildContext context, NivelConfig config) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ValoresInicialesPage(
          config: config,
          supabaseClient: supabaseClient,
          sesionUsuario: sesionUsuario,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ZonaMusicaLobby(
    habilitarMusica: true,
    child: AnimatedBuilder(
      animation: ControladorTema.instance,
      builder: (context, _) {
        final paleta = ControladorTema.instance.actual;
        return Scaffold(
        backgroundColor: paleta.fondoPrincipal,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                paleta.fondoGradienteInicio,
                paleta.fondoPrincipal,
                paleta.fondoGradienteFin,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        key: const ValueKey('volver-inicio'),
                        tooltip: 'Volver al inicio',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: paleta.textoPrincipal,
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            const BotonMusicaLobby(),
                            const SelectorTemaButton(),
                            PerfilUsuario(
                              sesion: sesionUsuario,
                              supabaseClient: supabaseClient,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: paleta.panelSecundario,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: paleta.bordeSecundario,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: paleta.sombraPanel,
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                                BoxShadow(
                                  color: paleta.sombraAcento,
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: paleta.superficieInterior,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: paleta.acento,
                                        width: 1.8,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: paleta.sombraAcento,
                                          blurRadius: 16,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.grid_view_rounded,
                                      size: 34,
                                      color: paleta.acento,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'BRILLIANT',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                    color: paleta.textoPrincipal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Selecciona un nivel para comenzar tu partida',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: paleta.textoSecundario,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                for (final config in [
                                  Nivel1Config(),
                                  Nivel2Config(),
                                  Nivel3Config(),
                                  Nivel4Config(),
                                ]) ...[
                                  FilledButton(
                                    key: ValueKey('seleccionar-${config.id}'),
                                    onPressed: () =>
                                        _seleccionar(context, config),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: paleta.acento,
                                      foregroundColor: paleta.textoSobreAcento,
                                      elevation: 2,
                                      shadowColor: paleta.sombraAcento,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Text(
                                        config.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        );
      },
    ),
  );
}

class ValoresInicialesPage extends StatefulWidget {
  const ValoresInicialesPage({
    super.key,
    this.config,
    this.supabaseClient,
    this.sesionUsuario,
  });

  final NivelConfig? config;
  final SupabaseClient? supabaseClient;
  final SesionUsuario? sesionUsuario;

  @override
  State<ValoresInicialesPage> createState() => _ValoresInicialesPageState();
}

class _ValoresInicialesPageState extends State<ValoresInicialesPage> {
  late final NivelConfig _config;
  late final ValoresInicialesBloc _bloc;
  Tablero? _tableroIniciado;
  JuegoBloc? _juego;

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? Nivel1Config();
    _bloc = ValoresInicialesBloc(regiones: _config.iniciales.keys.toList());
  }

  Future<void> _elegir(String region) async {
    if (_tableroIniciado != null) return;
    final paleta = ControladorTema.instance.actual;

    final valor = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Número inicial · $region'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Actual: ${_bloc.valores[region] ?? "sin asignar"}',
              style: TextStyle(color: paleta.textoSecundario),
            ),
          ),
          for (var numero = 1; numero <= 6; numero++)
            SimpleDialogOption(
              key: ValueKey('opcion-$numero'),
              onPressed: () => Navigator.pop(context, numero),
              child: Text('$numero'),
            ),
          SimpleDialogOption(
            key: const ValueKey('borrar'),
            onPressed: () => Navigator.pop(context, 0),
            child: const Text('Borrar número'),
          ),
        ],
      ),
    );

    if (!mounted || valor == null) return;
    _bloc.actualizar(region, valor == 0 ? '' : '$valor');
  }

  void _iniciar() {
    if (_tableroIniciado != null || !_bloc.puedeContinuar) return;

    final datos = _bloc.confirmar();
    final tablero = Tablero.desdeConfig(_config);

    for (final entrada in datos.entries) {
      if (!tablero.agregar(_config.iniciales[entrada.key]!, entrada.value)) {
        throw StateError(
          'Configuración inicial incompatible con las regiones.',
        );
      }
    }

    setState(() {
      _tableroIniciado = tablero;
      _juego = JuegoBloc(tablero);
    });
  }

  Widget _fichaEstadistica({
    required PaletaTema paleta,
    required IconData icono,
    required String etiqueta,
    required String valor,
    Key? valorKey,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: paleta.panelSecundario,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: paleta.bordeSecundario),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 18, color: paleta.acento),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 11,
                color: paleta.textoSecundario,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valor,
              key: valorKey,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: paleta.textoPrincipal,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _resumenPartidaIndividual(JuegoBloc juego, PaletaTema paleta) {
    final totalCasillas = _config.matriz.length * _config.matriz.first.length;
    final ocupadas = juego.tablero.datos.length;
    final zonasCompletas = juego.puntosPorZona.length;
    final totalZonas = _config.regiones.length;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _fichaEstadistica(
          paleta: paleta,
          icono: Icons.stars_rounded,
          etiqueta: 'Puntuación',
          valor: '${juego.puntos} pts',
        ),
        _fichaEstadistica(
          paleta: paleta,
          icono: Icons.grid_on_rounded,
          etiqueta: 'Casillas',
          valor: '$ocupadas / $totalCasillas',
        ),
        _fichaEstadistica(
          paleta: paleta,
          icono: Icons.layers_outlined,
          etiqueta: 'Zonas completas',
          valor: '$zonasCompletas / $totalZonas',
        ),
      ],
    );
  }

  Widget _controlesJuego(JuegoBloc juego, PaletaTema paleta) {
    final pendientes = juego.tiradaPendiente;
    final pivote = juego.pivote;
    final posibles = juego.casillasIluminadas.length;
    final bloqueado = juego.bloqueado;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: paleta.panelSecundario,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: paleta.bordeSecundario),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (bloqueado) ...[
            Container(
              key: const ValueKey('aviso-bloqueo'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: paleta.errorSuperficie,
                border: Border.all(color: paleta.error),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Partida bloqueada: no quedan jugadas válidas. '
                'Reinicia para comenzar una partida nueva.',
                style: TextStyle(
                  color: paleta.errorTexto,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Icon(Icons.casino_outlined, color: paleta.acento, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Turno de juego',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: paleta.textoPrincipal,
                  ),
                ),
              ),
              Text(
                'Jugadas: ${juego.turnosJugados} · '
                'Omitidas: ${juego.turnosOmitidos}',
                key: const ValueKey('contador-turnos'),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: paleta.acento,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            bloqueado
                ? 'No hay casillas vacías que puedan completarse con las reglas.'
                : pendientes
                ? pivote == null
                      ? 'Elige un dado como pivote. Colocarás el valor del otro.'
                      : posibles == 0
                      ? 'No hay casillas válidas con ese pivote. '
                            'Prueba el otro dado o pulsa Omitir.'
                      : 'Toca una casilla iluminada para colocar '
                            '${juego.valorAColocar}.'
                : 'Elige un dado como pivote.',
            key: const ValueKey('instruccion-turno'),
            style: TextStyle(color: paleta.textoSecundario),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    key: ValueKey('dado-$i'),
                    onPressed: pendientes && !bloqueado
                        ? () => juego.elegirPivote(i)
                        : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: pivote == i
                          ? paleta.superficieAcentoSuave
                          : paleta.superficieInterior,
                      foregroundColor: pivote == i
                          ? paleta.acento
                          : paleta.textoPrincipal,
                      side: BorderSide(
                        color: pivote == i
                            ? paleta.acento
                            : paleta.bordeSecundario,
                        width: pivote == i ? 2 : 1.2,
                      ),
                    ),
                    child: Text(
                      '${i == 0 ? juego.dadoA ?? "–" : juego.dadoB ?? "–"}',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: pivote == i
                            ? paleta.acento
                            : paleta.textoPrincipal,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('omitir'),
                  onPressed: pendientes && !bloqueado ? juego.omitir : null,
                  child: const Text('Omitir'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('reiniciar'),
                  onPressed: () {
                    setState(() {
                      _tableroIniciado = null;
                      _juego?.dispose();
                      _juego = null;
                    });
                  },
                  child: const Text('Reiniciar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// En ventanas amplias, coloca los premios a la derecha del tablero.
  /// En ventanas estrechas, los coloca debajo para evitar desbordamientos.
  Widget _tableroConPuntos({
    required Map<String, int?> valores,
    required bool iniciado,
    required JuegoBloc? juego,
  }) {
    final tableroVisual = TableroVisual(
      valores: valores,
      habilitado: !iniciado,
      onSeleccionar: _elegir,
      tablero: juego?.tablero,
      config: _config,
      iluminadas: juego?.casillasIluminadas ?? const {},
      onJugar: juego?.colocar,
    );

    if (!iniciado) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: tableroVisual,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: tableroVisual,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 215,
                child: TablaPuntos(
                  puntos: juego!.puntos,
                  obtenidos: juego.puntosPorZona,
                  config: _config,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            tableroVisual,
            const SizedBox(height: 12),
            TablaPuntos(
              puntos: juego!.puntos,
              obtenidos: juego.puntosPorZona,
              config: _config,
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    _juego?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ZonaMusicaLobby(
    habilitarMusica: true,
    child: AnimatedBuilder(
      animation: ControladorTema.instance,
      builder: (context, _) {
        final paleta = ControladorTema.instance.actual;
        return Scaffold(
        backgroundColor: paleta.fondoPrincipal,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: StreamBuilder<bool>(
                  stream: _bloc.cambios,
                  initialData: _bloc.puedeContinuar,
                  builder: (context, snapshot) {
                    final valores = _bloc.valores;
                    final cantidad = valores.values.whereType<int>().length;
                    final iniciado = _tableroIniciado != null;
                    final completos = snapshot.data ?? false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              key: const ValueKey('volver-menu'),
                              tooltip: 'Volver al menú',
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back,
                                color: paleta.textoPrincipal,
                              ),
                            ),
                            Icon(
                              Icons.grid_view_rounded,
                              color: paleta.acento,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'BRILLIANT',
                              style: TextStyle(
                                letterSpacing: 2,
                                fontWeight: FontWeight.w800,
                                color: paleta.textoPrincipal,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: paleta.panelSecundario,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: paleta.bordeSecundario,
                                ),
                              ),
                              child: Text(
                                '${_config.matriz.first.length} × ${_config.matriz.length}',
                                style: TextStyle(
                                  color: paleta.acento,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            const BotonMusicaLobby(),
                            const SelectorTemaButton(),
                            PerfilUsuario(
                              sesion: widget.sesionUsuario,
                              supabaseClient: widget.supabaseClient,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Mapa de colores',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: paleta.textoPrincipal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toca las seis casillas con + y distribuye '
                          'los números del 1 al 6 sin repetir.',
                          style: TextStyle(color: paleta.textoSecundario),
                        ),
                        const SizedBox(height: 14),
                        StreamBuilder<int>(
                          stream: _juego?.cambios,
                          initialData: 0,
                          builder: (context, _) {
                            final juego = _juego;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _tableroConPuntos(
                                  valores: valores,
                                  iniciado: iniciado,
                                  juego: juego,
                                ),
                                if (juego != null) ...[
                                  const SizedBox(height: 12),
                                  _controlesJuego(juego, paleta),
                                  const SizedBox(height: 12),
                                  _resumenPartidaIndividual(juego, paleta),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: paleta.panelSecundario,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: paleta.bordeSecundario),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '$cantidad DE 6 NÚMEROS COLOCADOS',
                                key: const ValueKey('progreso'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: paleta.acento,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                iniciado
                                    ? 'Datos iniciales guardados en el tablero.'
                                    : completos
                                    ? 'Todo listo. Puedes pulsar Inicio.'
                                    : cantidad == 6
                                    ? 'Hay números repetidos. '
                                          'Usa cada número una sola vez.'
                                    : 'Completa las seis casillas '
                                          'para habilitar Inicio.',
                                key: const ValueKey('estado'),
                                style: TextStyle(color: paleta.textoPrincipal),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  for (final color in ColorCasilla.values)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 9,
                                          height: 9,
                                          decoration: BoxDecoration(
                                            color: color.color,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          color.nombre,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: paleta.textoSecundario,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              FilledButton(
                                key: const ValueKey('inicio'),
                                onPressed: completos && !iniciado
                                    ? _iniciar
                                    : null,
                                child: const Text('Inicio'),
                              ),
                              if (iniciado) ...[
                                const Divider(height: 20),
                                Text(
                                  'Selección inicial confirmada',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: paleta.textoPrincipal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                for (final entrada in _config.iniciales.entries)
                                  Text(
                                    '${entrada.key} · '
                                    'fila ${entrada.value.y + 1}, '
                                    'columna ${entrada.value.x + 1}: '
                                    '${_tableroIniciado!.valorEn(entrada.value)}',
                                    style: TextStyle(
                                      color: paleta.textoSecundario,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            ),
          ),
        );
      },
    ),
  );
}
