import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/BDD.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key, this.authService});

  final AuthService? authService;

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  bool _cargando = false;
  bool _mostrarContrasena = false;
  bool _registroCompletado = false;
  bool _requiereConfirmacion = false;
  String? _error;

  Future<void> _crearCuenta() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final respuesta = await (widget.authService ?? AuthService())
          .registrarUsuario(
            correo: _correoController.text,
            usuarioName: _usuarioController.text,
            contrasena: _contrasenaController.text,
          );

      if (!mounted) return;
      if (respuesta.user == null) {
        setState(() {
          _cargando = false;
          _error = 'No se pudo crear la cuenta. Inténtalo de nuevo.';
        });
        return;
      }

      setState(() {
        _cargando = false;
        _registroCompletado = true;
        _requiereConfirmacion = respuesta.session == null;
      });
    } on AuthException catch (error) {
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

  String _mensajeError(AuthException error) {
    if (error.code == 'user_already_exists') {
      return 'Ya existe una cuenta con ese correo electrónico.';
    }
    if (error.code == 'weak_password') {
      return 'La contraseña es demasiado débil. Elige otra.';
    }
    if (error.code == 'email_address_invalid') {
      return 'El formato del correo es válido, pero Supabase Auth rechazó '
          'la dirección. Revisa la configuración del proveedor Email y sus '
          'políticas de validación.';
    }
    if (error is AuthRetryableFetchException) {
      return 'No se pudo conectar. Revisa tu conexión e inténtalo de nuevo.';
    }
    final detalle = error.message.trim();
    final codigo = error.code;
    return [
      'No se pudo crear la cuenta.',
      if (detalle.isNotEmpty) detalle,
      if (codigo != null && codigo.isNotEmpty) 'Código: $codigo',
      if (error.statusCode != null) 'Estado: ${error.statusCode}',
    ].join('\n');
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _correoController.dispose();
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
      Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          key: const ValueKey('registro-volver'),
          tooltip: 'Volver a iniciar sesión',
          onPressed: _cargando ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
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
            if (usuario.length > 15) {
              return 'El nombre debe tener máximo 15 caracteres.';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: const ValueKey('registro-email'),
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
            if (correo.isEmpty) return 'Escribe tu correo electrónico.';
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correo)) {
              return 'Escribe un correo electrónico válido.';
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
            if (valor.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres.';
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
      const Icon(
        Icons.mark_email_read_outlined,
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
        _requiereConfirmacion
            ? 'Revisa tu correo y confirma la cuenta antes de iniciar sesión.'
            : 'Tu cuenta está lista. Ya puedes iniciar sesión.',
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
