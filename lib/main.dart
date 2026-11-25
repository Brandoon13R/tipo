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
import 'package:tipo/tablero_visual.dart';

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
  Widget build(BuildContext context) {
    const negroMetalico = Color(0xFF12161D);
    const negroMetalicoCampo = Color(0xFF181D26);
    const grisNieblaPanel = Color(0xFF252D3A);
    const grisNieblaBorde = Color(0xFF3E4A5E);
    const grisNieblaClaro = Color(0xFFE2E8F0);
    const grisNieblaMedio = Color(0xFF9FB0C4);
    const azulElectrico = Color(0xFF00C8FF);
    const azulElectricoTexto = Color(0xFF09131C);

    final colorScheme = const ColorScheme.dark(
      primary: azulElectrico,
      onPrimary: azulElectricoTexto,
      secondary: grisNieblaClaro,
      onSecondary: negroMetalico,
      surface: grisNieblaPanel,
      onSurface: grisNieblaClaro,
      error: Color(0xFFFF6B6B),
      onError: negroMetalico,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: negroMetalico,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B24),
          foregroundColor: grisNieblaClaro,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: azulElectrico),
          titleTextStyle: TextStyle(
            color: grisNieblaClaro,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: grisNieblaPanel,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: grisNieblaBorde, width: 1.2),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: grisNieblaPanel,
          titleTextStyle: const TextStyle(
            color: grisNieblaClaro,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: const TextStyle(
            color: grisNieblaClaro,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: grisNieblaBorde, width: 1.2),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: grisNieblaBorde,
          thickness: 1,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: azulElectrico,
            foregroundColor: azulElectricoTexto,
            disabledBackgroundColor: const Color(0xFF283546),
            disabledForegroundColor: grisNieblaMedio,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: negroMetalicoCampo,
            foregroundColor: grisNieblaClaro,
            side: const BorderSide(color: azulElectrico, width: 1.3),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: azulElectrico),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: negroMetalicoCampo,
          labelStyle: const TextStyle(color: grisNieblaMedio),
          hintStyle: const TextStyle(color: grisNieblaMedio),
          floatingLabelStyle: const TextStyle(
            color: azulElectrico,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: grisNieblaBorde, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: azulElectrico, width: 1.8),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: grisNieblaBorde, width: 1.2),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: negroMetalicoCampo,
          selectedColor: const Color(0xFF13384C),
          side: const BorderSide(color: grisNieblaBorde),
          labelStyle: const TextStyle(color: grisNieblaClaro),
          secondaryLabelStyle: const TextStyle(
            color: azulElectrico,
            fontWeight: FontWeight.w700,
          ),
          checkmarkColor: azulElectrico,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: grisNieblaPanel,
          contentTextStyle: TextStyle(color: grisNieblaClaro),
        ),
      ),
      home: MenuPage(
        supabaseClient: supabaseClient,
        sesionUsuario: sesionUsuario,
      ),
    );
  }
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

  // Paleta 60-30-10 para el menú principal:
  // 60% Negro metálico
  static const Color _negroMetalico = Color(0xFF12161D);
  static const Color _negroMetalicoSuperior = Color(0xFF1A202B);
  static const Color _negroMetalicoInterior = Color(0xFF181D26);
  // 30% Gris niebla
  static const Color _grisNieblaPanel = Color(0xFF252D3A);
  static const Color _grisNieblaBorde = Color(0xFF3E4A5E);
  static const Color _grisNieblaClaro = Color(0xFFE2E8F0);
  static const Color _grisNieblaMedio = Color(0xFF9FB0C4);
  // 10% Azul eléctrico
  static const Color _azulElectrico = Color(0xFF00C8FF);
  static const Color _azulElectricoTextoBoton = Color(0xFF09131C);

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
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text(
          'Esta acción eliminará tu cuenta y cerrará todas tus sesiones. '
          'No se puede deshacer.',
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
      animation: session,
      builder: (context, _) {
        if (!session.activa) {
          return LoginPage(
            authService: widget.authService,
            supabaseClient: widget.supabaseClient,
            sesionUsuario: session,
          );
        }
        return _buildMenu(context, true);
      },
    );
  }

  Widget _botonAccesoEsquina(BuildContext context, bool sesionActiva) {
    final client = widget.supabaseClient;
    final ocupada = _cerrandoSesion || _eliminandoCuenta;
    final session = _sesionEfectiva;
    final username = session.usuarioName;

    if (!sesionActiva || username == null) {
      return Tooltip(
        message: 'Iniciar sesión',
        child: Material(
          color: _grisNieblaPanel,
          shape: const CircleBorder(
            side: BorderSide(color: _azulElectrico, width: 1.5),
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
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.person_outline_rounded,
                color: _azulElectrico,
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
      color: _grisNieblaPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _grisNieblaBorde, width: 1.2),
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
              const Icon(
                Icons.logout_rounded,
                size: 20,
                color: _azulElectrico,
              ),
              const SizedBox(width: 10),
              Text(
                _cerrandoSesion ? 'Cerrando sesión...' : 'Cerrar sesión',
                style: const TextStyle(color: _grisNieblaClaro),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          key: const ValueKey('eliminar-cuenta'),
          value: 'eliminar_cuenta',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Color(0xFFFF6B6B),
              ),
              const SizedBox(width: 10),
              Text(
                _eliminandoCuenta ? 'Eliminando cuenta...' : 'Eliminar cuenta',
                style: const TextStyle(
                  color: Color(0xFFFF8787),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Material(
        color: _grisNieblaPanel,
        shape: const StadiumBorder(
          side: BorderSide(color: _grisNieblaBorde, width: 1.4),
        ),
        elevation: 3,
        shadowColor: Colors.black54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: _azulElectrico,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: _azulElectricoTextoBoton,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _grisNieblaClaro,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down_rounded,
                color: _azulElectrico,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, bool sesionActiva) => Scaffold(
    backgroundColor: _negroMetalico,
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_negroMetalicoSuperior, _negroMetalico, Color(0xFF0D1015)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: _botonAccesoEsquina(context, sesionActiva),
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
                        color: _grisNieblaPanel,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _grisNieblaBorde,
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 28,
                            offset: Offset(0, 14),
                          ),
                          BoxShadow(
                            color: Color(0x1800C8FF),
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
                              style: const TextStyle(
                                color: Color(0xFFFF8787),
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
                                color: _negroMetalicoInterior,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _azulElectrico,
                                  width: 1.8,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x3800C8FF),
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                size: 38,
                                color: _azulElectrico,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'BRILLIANT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                              color: _grisNieblaClaro,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Estrategia numérica en solitario y multijugador',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _grisNieblaMedio,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          FilledButton(
                            key: const ValueKey('jugar'),
                            onPressed: () => _jugar(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: _azulElectrico,
                              foregroundColor: _azulElectricoTextoBoton,
                              elevation: 3,
                              shadowColor: const Color(0x6600C8FF),
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
                              backgroundColor: _negroMetalicoInterior,
                              foregroundColor: _grisNieblaClaro,
                              side: const BorderSide(
                                color: _azulElectrico,
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(
                              Icons.people_alt_outlined,
                              color: _azulElectrico,
                            ),
                            label: const Padding(
                              padding: EdgeInsets.all(14),
                              child: Text(
                                'Multijugador',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: _grisNieblaClaro,
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

  static const Color _negroMetalico = Color(0xFF12161D);
  static const Color _negroMetalicoSuperior = Color(0xFF1A202B);
  static const Color _negroMetalicoInterior = Color(0xFF181D26);
  static const Color _grisNieblaPanel = Color(0xFF252D3A);
  static const Color _grisNieblaBorde = Color(0xFF3E4A5E);
  static const Color _grisNieblaClaro = Color(0xFFE2E8F0);
  static const Color _grisNieblaMedio = Color(0xFF9FB0C4);
  static const Color _azulElectrico = Color(0xFF00C8FF);
  static const Color _azulElectricoTexto = Color(0xFF09131C);

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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _negroMetalico,
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_negroMetalicoSuperior, _negroMetalico, Color(0xFF0D1015)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    key: const ValueKey('volver-inicio'),
                    tooltip: 'Volver al inicio',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: _grisNieblaClaro,
                    ),
                  ),
                  const Spacer(),
                  PerfilUsuario(
                    sesion: sesionUsuario,
                    supabaseClient: supabaseClient,
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
                          color: _grisNieblaPanel,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _grisNieblaBorde,
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 28,
                              offset: Offset(0, 14),
                            ),
                            BoxShadow(
                              color: Color(0x1800C8FF),
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
                                  color: _negroMetalicoInterior,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _azulElectrico,
                                    width: 1.8,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x3800C8FF),
                                      blurRadius: 16,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.grid_view_rounded,
                                  size: 34,
                                  color: _azulElectrico,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'BRILLIANT',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                letterSpacing: 4,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                                color: _grisNieblaClaro,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Selecciona un nivel para comenzar tu partida',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _grisNieblaMedio,
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
                                onPressed: () => _seleccionar(context, config),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _azulElectrico,
                                  foregroundColor: _azulElectricoTexto,
                                  elevation: 2,
                                  shadowColor: const Color(0x5500C8FF),
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
                            const SizedBox(height: 4),
                            OutlinedButton.icon(
                              key: const ValueKey('cerrar-aplicacion'),
                              onPressed: () => exit(0),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _negroMetalicoInterior,
                                foregroundColor: _grisNieblaClaro,
                                side: const BorderSide(
                                  color: _grisNieblaBorde,
                                  width: 1.3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(
                                Icons.exit_to_app,
                                color: _azulElectrico,
                              ),
                              label: const Padding(
                                padding: EdgeInsets.all(14),
                                child: Text(
                                  'Cerrar aplicación',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _grisNieblaClaro,
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
              ),
            ],
          ),
        ),
      ),
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

  static const Color _negroMetalico = Color(0xFF12161D);
  static const Color _negroMetalicoInterior = Color(0xFF181D26);
  static const Color _grisNieblaPanel = Color(0xFF252D3A);
  static const Color _grisNieblaBorde = Color(0xFF3E4A5E);
  static const Color _grisNieblaClaro = Color(0xFFE2E8F0);
  static const Color _grisNieblaMedio = Color(0xFF9FB0C4);
  static const Color _azulElectrico = Color(0xFF00C8FF);

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? Nivel1Config();
    _bloc = ValoresInicialesBloc(regiones: _config.iniciales.keys.toList());
  }

  Future<void> _elegir(String region) async {
    if (_tableroIniciado != null) return;

    final valor = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Número inicial · $region'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Actual: ${_bloc.valores[region] ?? "sin asignar"}',
              style: const TextStyle(color: _grisNieblaMedio),
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
    required IconData icono,
    required String etiqueta,
    required String valor,
    Key? valorKey,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: _grisNieblaPanel,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _grisNieblaBorde),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 18, color: _azulElectrico),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 11,
                color: _grisNieblaMedio,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valor,
              key: valorKey,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _grisNieblaClaro,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _resumenPartidaIndividual(JuegoBloc juego) {
    final totalCasillas = _config.matriz.length * _config.matriz.first.length;
    final ocupadas = juego.tablero.datos.length;
    final zonasCompletas = juego.puntosPorZona.length;
    final totalZonas = _config.regiones.length;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _fichaEstadistica(
          icono: Icons.stars_rounded,
          etiqueta: 'Puntuación',
          valor: '${juego.puntos} pts',
        ),
        _fichaEstadistica(
          icono: Icons.grid_on_rounded,
          etiqueta: 'Casillas',
          valor: '$ocupadas / $totalCasillas',
        ),
        _fichaEstadistica(
          icono: Icons.layers_outlined,
          etiqueta: 'Zonas completas',
          valor: '$zonasCompletas / $totalZonas',
        ),
      ],
    );
  }

  Widget _controlesJuego(JuegoBloc juego) {
    final pendientes = juego.tiradaPendiente;
    final pivote = juego.pivote;
    final posibles = juego.casillasIluminadas.length;
    final bloqueado = juego.bloqueado;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _grisNieblaPanel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _grisNieblaBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (bloqueado) ...[
            Container(
              key: const ValueKey('aviso-bloqueo'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B1A1F),
                border: Border.all(color: const Color(0xFFFF6B6B)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Partida bloqueada: no quedan jugadas válidas. '
                'Reinicia para comenzar una partida nueva.',
                style: TextStyle(
                  color: Color(0xFFFFA8A8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              const Icon(
                Icons.casino_outlined,
                color: _azulElectrico,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Turno de juego',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: _grisNieblaClaro,
                  ),
                ),
              ),
              Text(
                'Jugadas: ${juego.turnosJugados} · '
                'Omitidas: ${juego.turnosOmitidos}',
                key: const ValueKey('contador-turnos'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _azulElectrico,
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
            style: const TextStyle(color: _grisNieblaMedio),
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
                          ? const Color(0xFF113548)
                          : _negroMetalicoInterior,
                      foregroundColor: pivote == i
                          ? _azulElectrico
                          : _grisNieblaClaro,
                      side: BorderSide(
                        color: pivote == i ? _azulElectrico : _grisNieblaBorde,
                        width: pivote == i ? 2 : 1.2,
                      ),
                    ),
                    child: Text(
                      '${i == 0 ? juego.dadoA ?? "–" : juego.dadoB ?? "–"}',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: pivote == i ? _azulElectrico : _grisNieblaClaro,
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

    // Antes de Inicio: solo se muestra el tablero para elegir los seis números.
    if (!iniciado) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: tableroVisual,
        ),
      );
    }

    // Después de Inicio: tablero y tabla compacta a la derecha.
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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _negroMetalico,
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: _grisNieblaClaro,
                          ),
                        ),
                        const Icon(
                          Icons.grid_view_rounded,
                          color: _azulElectrico,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'BRILLIANT',
                          style: TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                            color: _grisNieblaClaro,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _grisNieblaPanel,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _grisNieblaBorde),
                          ),
                          child: Text(
                            '${_config.matriz.first.length} × ${_config.matriz.length}',
                            style: const TextStyle(
                              color: _azulElectrico,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PerfilUsuario(
                        sesion: widget.sesionUsuario,
                        supabaseClient: widget.supabaseClient,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mapa de colores',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _grisNieblaClaro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Toca las seis casillas con + y distribuye '
                      'los números del 1 al 6 sin repetir.',
                      style: TextStyle(color: _grisNieblaMedio),
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
                              _controlesJuego(juego),
                              const SizedBox(height: 12),
                              _resumenPartidaIndividual(juego),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _grisNieblaPanel,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _grisNieblaBorde),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '$cantidad DE 6 NÚMEROS COLOCADOS',
                            key: const ValueKey('progreso'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _azulElectrico,
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
                            style: const TextStyle(color: _grisNieblaClaro),
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
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      color.nombre,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _grisNieblaMedio,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            key: const ValueKey('inicio'),
                            onPressed: completos && !iniciado ? _iniciar : null,
                            child: const Text('Inicio'),
                          ),
                          if (iniciado) ...[
                            const Divider(height: 20),
                            const Text(
                              'Selección inicial confirmada',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _grisNieblaClaro,
                              ),
                            ),
                            const SizedBox(height: 4),
                            for (final entrada in _config.iniciales.entries)
                              Text(
                                '${entrada.key} · '
                                'fila ${entrada.value.y + 1}, '
                                'columna ${entrada.value.x + 1}: '
                                '${_tableroIniciado!.valorEn(entrada.value)}',
                                style: const TextStyle(color: _grisNieblaMedio),
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
}

/// Componente reutilizable: 49 cuadrados y un espacio uniforme de 6 px.
