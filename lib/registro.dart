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

  // Paleta 60-30-10:
  // 60% Negro metálico
  static const Color _negroMetalico = Color(0xFF12161D);
  static const Color _negroMetalicoSuperior = Color(0xFF1A202B);
  static const Color _negroMetalicoCampo = Color(0xFF181D26);
  // 30% Gris niebla
  static const Color _grisNieblaPanel = Color(0xFF252D3A);
  static const Color _grisNieblaBorde = Color(0xFF3E4A5E);
  static const Color _grisNieblaClaro = Color(0xFFE2E8F0);
  static const Color _grisNieblaMedio = Color(0xFF9FB0C4);
  // 10% Azul eléctrico
  static const Color _azulElectrico = Color(0xFF00C8FF);
  static const Color _azulElectricoTextoBoton = Color(0xFF09131C);

  InputDecoration _decoracionCampo({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: _grisNieblaMedio),
    floatingLabelStyle: const TextStyle(
      color: _azulElectrico,
      fontWeight: FontWeight.w600,
    ),
    counterStyle: const TextStyle(color: _grisNieblaMedio),
    prefixIcon: Icon(prefixIcon, color: _grisNieblaMedio),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: _negroMetalicoCampo,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _grisNieblaBorde, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _azulElectrico, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.4),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.8),
    ),
    errorStyle: const TextStyle(color: Color(0xFFFF8787)),
  );

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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: _grisNieblaPanel,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _grisNieblaBorde, width: 1.2),
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
                child: _registroCompletado
                    ? _mensajeRegistroCompletado()
                    : _formularioRegistro(),
              ),
            ),
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
            icon: const Icon(Icons.arrow_back, color: _grisNieblaClaro),
          ),
          const Spacer(),
          PerfilUsuario(sesion: widget.sesionUsuario),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _negroMetalicoCampo,
          shape: BoxShape.circle,
          border: Border.all(color: _azulElectrico, width: 1.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3800C8FF),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.person_add_alt_1,
          size: 32,
          color: _azulElectrico,
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'Crear cuenta',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _grisNieblaClaro,
        ),
      ),
      const SizedBox(height: 20),
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
          style: const TextStyle(color: _grisNieblaClaro),
          cursorColor: _azulElectrico,
          decoration: _decoracionCampo(
            labelText: 'Nombre de usuario',
            prefixIcon: Icons.person_outline,
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
          style: const TextStyle(color: _grisNieblaClaro),
          cursorColor: _azulElectrico,
          decoration: _decoracionCampo(
            labelText: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              tooltip: _mostrarContrasena
                  ? 'Ocultar contraseña'
                  : 'Mostrar contraseña',
              onPressed: () =>
                  setState(() => _mostrarContrasena = !_mostrarContrasena),
              icon: Icon(
                _mostrarContrasena ? Icons.visibility_off : Icons.visibility,
                color: _grisNieblaMedio,
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
          style: const TextStyle(color: _grisNieblaClaro),
          cursorColor: _azulElectrico,
          onFieldSubmitted: (_) {
            if (!_cargando) {
              _crearCuenta();
            }
          },
          decoration: _decoracionCampo(
            labelText: 'Confirmar contraseña',
            prefixIcon: Icons.lock_outline,
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
            style: const TextStyle(
              color: Color(0xFFFF8787),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const ValueKey('registro-submit'),
          onPressed: _cargando ? null : _crearCuenta,
          style: FilledButton.styleFrom(
            backgroundColor: _azulElectrico,
            foregroundColor: _azulElectricoTextoBoton,
            disabledBackgroundColor: const Color(0xFF2B4B59),
            disabledForegroundColor: _grisNieblaMedio,
            elevation: 3,
            shadowColor: const Color(0x6600C8FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: _cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _azulElectricoTextoBoton,
                    ),
                  )
                : const Text(
                    'Crear cuenta',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
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
        color: _azulElectrico,
      ),
      const SizedBox(height: 20),
      const Text(
        'Cuenta creada',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: _grisNieblaClaro,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Tu cuenta está lista y ya iniciaste sesión como '
        '${widget.sesionUsuario?.usuarioName ?? ''}.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: _grisNieblaMedio),
      ),
      const SizedBox(height: 24),
      FilledButton(
        key: const ValueKey('registro-ir-login'),
        onPressed: () => Navigator.of(context).pop(),
        style: FilledButton.styleFrom(
          backgroundColor: _azulElectrico,
          foregroundColor: _azulElectricoTextoBoton,
        ),
        child: const Text(
          'Volver a iniciar sesión',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}
