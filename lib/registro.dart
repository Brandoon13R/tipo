import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/BDD.dart';
import 'package:tipo/perfil_usuario.dart';
import 'package:tipo/sesion_usuario.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({
    super.key,
    this.authService,
    this.supabaseClient,
    this.sesionUsuario,
  });

  final AuthService? authService;
  final SupabaseClient? supabaseClient;
  final SesionUsuario? sesionUsuario;

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  bool _cargando = false;
  bool _mostrarContrasena = false;
  bool _registroCompletado = false;
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

  Future<void> _crearCuenta() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final respuesta = await _authService.registrarUsuario(
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

      setState(() {
        _cargando = false;
        _registroCompletado = true;
      });
    } on AuthServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = _mensajeError(error);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'Error inesperado al crear la cuenta: $error';
      });
    }
  }

  String _mensajeError(AuthServiceException error) {
    if (error.statusCode == 409) {
      return 'Ese nombre de usuario ya está registrado.';
    }
    return error.message;
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
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
            child: _registroCompletado
                ? _mensajeRegistroCompletado()
                : _formularioRegistro(),
          ),
        ),
      ),
    ),
  );

  Widget _encabezado() => Column(
    children: [
      Row(
        children: [
          IconButton(
            key: const ValueKey('registro-volver'),
            tooltip: 'Volver a iniciar sesión',
            onPressed: _cargando ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          PerfilUsuario(sesion: widget.sesionUsuario),
        ],
      ),
      const SizedBox(height: 12),
      const Icon(Icons.person_add_alt_1, size: 60, color: Color(0xFF193E37)),
      const SizedBox(height: 16),
      const Text(
        'Crear cuenta',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 24),
    ],
  );

  Widget _formularioRegistro() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _encabezado(),
        TextFormField(
          key: const ValueKey('registro-usuario'),
          controller: _usuarioController,
          maxLength: 15,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newUsername],
          decoration: const InputDecoration(
            labelText: 'Nombre de usuario',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          validator: (valor) {
            final usuario = valor?.trim() ?? '';
            if (usuario.isEmpty) return 'Escribe un nombre de usuario.';
            if (!RegExp(r'^[a-zA-Z0-9_]{3,15}$').hasMatch(usuario)) {
              return 'Usa de 3 a 15 letras, números o guiones bajos.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const ValueKey('registro-password'),
          controller: _contrasenaController,
          obscureText: !_mostrarContrasena,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: _mostrarContrasena
                  ? 'Ocultar contraseña'
                  : 'Mostrar contraseña',
              onPressed: () =>
                  setState(() => _mostrarContrasena = !_mostrarContrasena),
              icon: Icon(
                _mostrarContrasena ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
          validator: (valor) {
            if (valor == null || valor.isEmpty) {
              return 'Escribe una contraseña.';
            }
            final bytes = utf8.encode(valor);
            if (bytes.length < 8 || bytes.length > 72) {
              return 'La contraseña debe tener entre 8 y 72 bytes UTF-8.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const ValueKey('registro-confirmar-password'),
          controller: _confirmarContrasenaController,
          obscureText: !_mostrarContrasena,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            if (!_cargando) {
              _crearCuenta();
            }
          },
          decoration: const InputDecoration(
            labelText: 'Confirmar contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          validator: (valor) {
            if (valor == null || valor.isEmpty) {
              return 'Confirma tu contraseña.';
            }
            if (valor != _contrasenaController.text) {
              return 'Las contraseñas no coinciden.';
            }
            return null;
          },
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            key: const ValueKey('registro-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const ValueKey('registro-submit'),
          onPressed: _cargando ? null : _crearCuenta,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: _cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Crear cuenta'),
          ),
        ),
      ],
    ),
  );

  Widget _mensajeRegistroCompletado() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: PerfilUsuario(sesion: widget.sesionUsuario),
      ),
      const SizedBox(height: 12),
      const Icon(
        Icons.verified_user_outlined,
        size: 64,
        color: Color(0xFF193E37),
      ),
      const SizedBox(height: 20),
      const Text(
        'Cuenta creada',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 16),
      Text(
        'Tu cuenta está lista y ya iniciaste sesión como '
        '${widget.sesionUsuario?.usuarioName ?? ''}.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      FilledButton(
        key: const ValueKey('registro-ir-login'),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Volver a iniciar sesión'),
      ),
    ],
  );
}
