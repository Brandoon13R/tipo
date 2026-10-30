import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/BDD.dart';
import 'package:tipo/perfil_usuario.dart';
import 'package:tipo/registro.dart';
import 'package:tipo/sesion_usuario.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.authService,
    this.supabaseClient,
    this.sesionUsuario,
  });

  final AuthService? authService;
  final SupabaseClient? supabaseClient;
  final SesionUsuario? sesionUsuario;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _cargando = false;
  bool _mostrarContrasena = false;
  String? _error;

  AuthService get _authService {
    final service = widget.authService;
    if (service != null) return service;
    final client = widget.supabaseClient;
    if (client == null) {
      throw const AuthServiceException(
        'No está disponible el servicio de autenticación.',
      );
    }
    return AuthService(client);
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final respuesta = await _authService.iniciarSesion(
        usuarioName: _usuarioController.text,
        contrasena: _contrasenaController.text,
      );

      if (!mounted) return;
      final sesionUsuario = widget.sesionUsuario;
      if (sesionUsuario == null) {
        throw const AuthServiceException(
          'No está disponible el almacenamiento seguro de sesión.',
        );
      }
      await sesionUsuario.iniciar(respuesta);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión iniciada correctamente.')),
      );
      Navigator.of(context).pop();
    } on AuthServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = _mensajeError(error);
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudo guardar la sesión de forma segura: $error';
      });
    }
  }

  String _mensajeError(AuthServiceException error) {
    if (error.statusCode == 401) {
      return 'Usuario o contraseña incorrectos.';
    }
    return error.message;
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        key: const ValueKey('login-volver'),
                        tooltip: 'Volver al inicio',
                        onPressed: _cargando
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Spacer(),
                      PerfilUsuario(sesion: widget.sesionUsuario),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.account_circle_outlined,
                    size: 64,
                    color: Color(0xFF193E37),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Iniciar sesión',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    key: const ValueKey('login-usuario'),
                    controller: _usuarioController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      final usuario = valor?.trim() ?? '';
                      if (usuario.isEmpty) {
                        return 'Escribe tu nombre de usuario.';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]{3,15}$').hasMatch(usuario)) {
                        return 'Usa de 3 a 15 letras, números o guiones bajos.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey('login-password'),
                    controller: _contrasenaController,
                    obscureText: !_mostrarContrasena,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) {
                      if (!_cargando) {
                        _iniciarSesion();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _mostrarContrasena
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        onPressed: () => setState(
                          () => _mostrarContrasena = !_mostrarContrasena,
                        ),
                        icon: Icon(
                          _mostrarContrasena
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (valor) => (valor == null || valor.isEmpty)
                        ? 'Escribe tu contraseña.'
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      key: const ValueKey('login-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const ValueKey('login-submit'),
                    onPressed: _cargando ? null : _iniciarSesion,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: _cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    key: const ValueKey('login-crear-cuenta'),
                    onPressed: _cargando
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => RegistroPage(
                                authService: widget.authService,
                                supabaseClient: widget.supabaseClient,
                                sesionUsuario: widget.sesionUsuario,
                              ),
                            ),
                          ),
                    child: const Text('¿No tienes cuenta? Crea tu cuenta'),
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
