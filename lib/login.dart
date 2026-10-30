import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/BDD.dart';
import 'package:tipo/registro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authService});

  final AuthService? authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _cargando = false;
  bool _mostrarContrasena = false;
  String? _error;

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final respuesta = await (widget.authService ?? AuthService())
          .iniciarSesion(
            correo: _correoController.text,
            contrasena: _contrasenaController.text,
          );

      if (!mounted) return;
      if (respuesta.session == null) {
        setState(() {
          _cargando = false;
          _error = 'No se pudo iniciar sesión. Verifica tu correo e inténtalo.';
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión iniciada correctamente.')),
      );
      Navigator.of(context).pop();
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = _mensajeError(error);
      });
    }
  }

  String _mensajeError(AuthException error) {
    if (error.code == 'email_not_confirmed') {
      return 'Confirma tu correo electrónico antes de iniciar sesión.';
    }
    if (error.code == 'invalid_credentials' || error.statusCode == '400') {
      return 'Correo o contraseña incorrectos.';
    }
    if (error is AuthRetryableFetchException) {
      return 'No se pudo conectar. Revisa tu conexión e inténtalo de nuevo.';
    }
    return 'No se pudo iniciar sesión. Inténtalo de nuevo más tarde.';
  }

  @override
  void dispose() {
    _correoController.dispose();
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      key: const ValueKey('login-volver'),
                      tooltip: 'Volver al inicio',
                      onPressed: _cargando
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
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
                    key: const ValueKey('login-email'),
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      final correo = valor?.trim() ?? '';
                      if (correo.isEmpty) {
                        return 'Escribe tu correo electrónico.';
                      }
                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(correo)) {
                        return 'Escribe un correo electrónico válido.';
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
                              builder: (_) => const RegistroPage(),
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
