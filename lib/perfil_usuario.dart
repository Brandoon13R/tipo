import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/BDD.dart';
import 'package:tipo/sesion_usuario.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({
    super.key,
    required this.sesion,
    this.authService,
    this.supabaseClient,
  });

  final SesionUsuario? sesion;
  final AuthService? authService;
  final SupabaseClient? supabaseClient;

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  bool _cerrandoSesion = false;
  bool _eliminandoCuenta = false;

  static const Color _grisNieblaPanel = Color(0xFF252D3A);
  static const Color _grisNieblaBorde = Color(0xFF3E4A5E);
  static const Color _grisNieblaClaro = Color(0xFFE2E8F0);
  static const Color _azulElectrico = Color(0xFF00C8FF);
  static const Color _azulElectricoTexto = Color(0xFF09131C);

  AuthService? _resolverAuthService() {
    if (widget.authService != null) return widget.authService;
    if (widget.supabaseClient != null) {
      return AuthService(widget.supabaseClient!);
    }
    try {
      return AuthService(Supabase.instance.client);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cerrarSesion() async {
    final session = widget.sesion;
    final token = session?.token;
    if (session == null ||
        token == null ||
        _cerrandoSesion ||
        _eliminandoCuenta) {
      return;
    }
    final authService = _resolverAuthService();
    setState(() => _cerrandoSesion = true);
    try {
      if (authService != null) {
        await authService.cerrarSesion(token);
      }
      await session.limpiar();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthServiceException catch (error) {
      await session.limpiar();
      if (!mounted) return;
      if (error.statusCode != 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Se cerró la sesión en este dispositivo, pero el servidor no '
              'pudo revocar el token: ${error.message}',
            ),
          ),
        );
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } finally {
      if (mounted) setState(() => _cerrandoSesion = false);
    }
  }

  Future<void> _confirmarEliminarCuenta() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _grisNieblaPanel,
        title: const Text(
          '¿Eliminar cuenta?',
          style: TextStyle(color: _grisNieblaClaro),
        ),
        content: const Text(
          'Esta acción eliminará tu cuenta y cerrará todas tus sesiones. '
          'No se puede deshacer.',
          style: TextStyle(color: _grisNieblaClaro),
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

    final session = widget.sesion;
    final token = session?.token;
    if (session == null || token == null) return;

    final authService = _resolverAuthService();
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
      Navigator.of(context).popUntil((route) => route.isFirst);
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
    final userSession = widget.sesion;
    if (userSession == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: userSession,
      builder: (context, _) {
        final username = userSession.usuarioName;
        if (username == null) return const SizedBox.shrink();
        final ocupada = _cerrandoSesion || _eliminandoCuenta;

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
                    _eliminandoCuenta
                        ? 'Eliminando cuenta...'
                        : 'Eliminar cuenta',
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
                        color: _azulElectricoTexto,
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
      },
    );
  }
}
