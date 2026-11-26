import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/BDD.dart';
import 'package:tipo/musica_lobby.dart';
import 'package:tipo/perfil_usuario.dart';
import 'package:tipo/sesion_usuario.dart';
import 'package:tipo/tema_app.dart';

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

  InputDecoration _decoracionCampo({
    required PaletaTema paleta,
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(color: paleta.textoSecundario),
    floatingLabelStyle: TextStyle(
      color: paleta.acento,
      fontWeight: FontWeight.w600,
    ),
    counterStyle: TextStyle(color: paleta.textoSecundario),
    prefixIcon: Icon(prefixIcon, color: paleta.textoSecundario),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: paleta.superficieInterior,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: paleta.bordeSecundario, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: paleta.acento, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: paleta.error, width: 1.4),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: paleta.error, width: 1.8),
    ),
    errorStyle: TextStyle(color: paleta.errorTexto),
  );

  @override
  Widget build(BuildContext context) => ZonaMusicaLobby(
    habilitarMusica: false,
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
                      child: _registroCompletado
                          ? _mensajeRegistroCompletado(paleta)
                          : _formularioRegistro(paleta),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _encabezado(PaletaTema paleta) => Column(
    children: [
      Row(
        children: [
          IconButton(
            key: const ValueKey('registro-volver'),
            tooltip: 'Volver a iniciar sesión',
            onPressed: _cargando ? null : () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: paleta.textoPrincipal),
          ),
          const Spacer(),
          const SelectorTemaButton(),
          if (widget.sesionUsuario?.activa == true) ...[
            const SizedBox(width: 8),
            PerfilUsuario(sesion: widget.sesionUsuario),
          ],
        ],
      ),
      const SizedBox(height: 8),
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: paleta.superficieInterior,
          shape: BoxShape.circle,
          border: Border.all(color: paleta.acento, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: paleta.sombraAcento,
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(Icons.person_add_alt_1, size: 32, color: paleta.acento),
      ),
      const SizedBox(height: 14),
      Text(
        'Crear cuenta',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: paleta.textoPrincipal,
        ),
      ),
      const SizedBox(height: 20),
    ],
  );

  Widget _formularioRegistro(PaletaTema paleta) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _encabezado(paleta),
        TextFormField(
          key: const ValueKey('registro-usuario'),
          controller: _usuarioController,
          maxLength: 15,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newUsername],
          style: TextStyle(color: paleta.textoPrincipal),
          cursorColor: paleta.acento,
          decoration: _decoracionCampo(
            paleta: paleta,
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
          style: TextStyle(color: paleta.textoPrincipal),
          cursorColor: paleta.acento,
          decoration: _decoracionCampo(
            paleta: paleta,
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
                color: paleta.textoSecundario,
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
          style: TextStyle(color: paleta.textoPrincipal),
          cursorColor: paleta.acento,
          onFieldSubmitted: (_) {
            if (!_cargando) {
              _crearCuenta();
            }
          },
          decoration: _decoracionCampo(
            paleta: paleta,
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
            style: TextStyle(
              color: paleta.errorTexto,
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
            backgroundColor: paleta.acento,
            foregroundColor: paleta.textoSobreAcento,
            disabledBackgroundColor: paleta.botonDeshabilitadoFondo,
            disabledForegroundColor: paleta.textoSecundario,
            elevation: 3,
            shadowColor: paleta.sombraAcento,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: _cargando
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: paleta.textoSobreAcento,
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

  Widget _mensajeRegistroCompletado(PaletaTema paleta) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: PerfilUsuario(sesion: widget.sesionUsuario),
      ),
      const SizedBox(height: 12),
      Icon(Icons.verified_user_outlined, size: 64, color: paleta.acento),
      const SizedBox(height: 20),
      Text(
        'Cuenta creada',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: paleta.textoPrincipal,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Tu cuenta está lista y ya iniciaste sesión como '
        '${widget.sesionUsuario?.usuarioName ?? ''}.',
        textAlign: TextAlign.center,
        style: TextStyle(color: paleta.textoSecundario),
      ),
      const SizedBox(height: 24),
      FilledButton(
        key: const ValueKey('registro-ir-login'),
        onPressed: () => Navigator.of(context).pop(),
        style: FilledButton.styleFrom(
          backgroundColor: paleta.acento,
          foregroundColor: paleta.textoSobreAcento,
        ),
        child: const Text(
          'Volver a iniciar sesión',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}
