import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/BDD.dart';
import 'package:tipo/perfil_usuario.dart';
import 'package:tipo/registro.dart';
import 'package:tipo/sesion_usuario.dart';
import 'package:tipo/tema_app.dart';

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
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
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
  Widget build(BuildContext context) => AnimatedBuilder(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 22,
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              if (Navigator.of(context).canPop())
                                IconButton(
                                  key: const ValueKey('login-volver'),
                                  tooltip: 'Volver al inicio',
                                  onPressed: _cargando
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: paleta.textoPrincipal,
                                  ),
                                ),
                              const Spacer(),
                              const SelectorTemaButton(),
                              if (widget.sesionUsuario?.activa == true) ...[
                                const SizedBox(width: 8),
                                PerfilUsuario(sesion: widget.sesionUsuario),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Container(
                              width: 58,
                              height: 58,
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
                                size: 30,
                                color: paleta.acento,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'BRILLIANT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: paleta.textoPrincipal,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Iniciar sesión',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: paleta.textoPrincipal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Inicia sesión o crea una cuenta para jugar en solitario '
                            'y multijugador.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: paleta.textoSecundario,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            key: const ValueKey('login-usuario'),
                            controller: _usuarioController,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            style: TextStyle(color: paleta.textoPrincipal),
                            cursorColor: paleta.acento,
                            decoration: _decoracionCampo(
                              paleta: paleta,
                              labelText: 'Nombre de usuario',
                              prefixIcon: Icons.person_outline,
                            ),
                            validator: (valor) {
                              final usuario = valor?.trim() ?? '';
                              if (usuario.isEmpty) {
                                return 'Escribe tu nombre de usuario.';
                              }
                              if (!RegExp(
                                r'^[a-zA-Z0-9_]{3,15}$',
                              ).hasMatch(usuario)) {
                                return 'Usa de 3 a 15 letras, números o guiones bajos.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const ValueKey('login-password'),
                            controller: _contrasenaController,
                            obscureText: !_mostrarContrasena,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            style: TextStyle(color: paleta.textoPrincipal),
                            cursorColor: paleta.acento,
                            onFieldSubmitted: (_) {
                              if (!_cargando) {
                                _iniciarSesion();
                              }
                            },
                            decoration: _decoracionCampo(
                              paleta: paleta,
                              labelText: 'Contraseña',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                tooltip: _mostrarContrasena
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                onPressed: () => setState(
                                  () =>
                                      _mostrarContrasena = !_mostrarContrasena,
                                ),
                                icon: Icon(
                                  _mostrarContrasena
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: paleta.textoSecundario,
                                ),
                              ),
                            ),
                            validator: (valor) =>
                                (valor == null || valor.isEmpty)
                                ? 'Escribe tu contraseña.'
                                : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              key: const ValueKey('login-error'),
                              style: TextStyle(
                                color: paleta.errorTexto,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 18),
                          FilledButton(
                            key: const ValueKey('login-submit'),
                            onPressed: _cargando ? null : _iniciarSesion,
                            style: FilledButton.styleFrom(
                              backgroundColor: paleta.acento,
                              foregroundColor: paleta.textoSobreAcento,
                              disabledBackgroundColor:
                                  paleta.botonDeshabilitadoFondo,
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
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
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
                            style: TextButton.styleFrom(
                              foregroundColor: paleta.acento,
                            ),
                            child: const Text(
                              '¿No tienes cuenta? Crea tu cuenta',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
