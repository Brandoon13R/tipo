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

  // Paleta 60-30-10:
  // 60% Negro metálico (fondo principal y campos internos)
  static const Color _negroMetalico = Color(0xFF12161D);
  static const Color _negroMetalicoSuperior = Color(0xFF1A202B);
  static const Color _negroMetalicoCampo = Color(0xFF181D26);
  // 30% Gris niebla (panel secundario, bordes suaves y tipografía)
  static const Color _grisNieblaPanel = Color(0xFF252D3A);
  static const Color _grisNieblaBorde = Color(0xFF3E4A5E);
  static const Color _grisNieblaClaro = Color(0xFFE2E8F0);
  static const Color _grisNieblaMedio = Color(0xFF9FB0C4);
  // 10% Azul eléctrico (acentos principales, botón CTA e icono)
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
                  vertical: 30,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (Navigator.of(context).canPop())
                        Row(
                          children: [
                            IconButton(
                              key: const ValueKey('login-volver'),
                              tooltip: 'Volver al inicio',
                              onPressed: _cargando
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: _grisNieblaClaro,
                              ),
                            ),
                            const Spacer(),
                            PerfilUsuario(sesion: widget.sesionUsuario),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: _negroMetalicoCampo,
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
                      const SizedBox(height: 14),
                      const Text(
                        'Iniciar sesión',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _grisNieblaClaro,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Inicia sesión o crea una cuenta para jugar en solitario '
                        'y multijugador.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _grisNieblaMedio, height: 1.35),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const ValueKey('login-usuario'),
                        controller: _usuarioController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        style: const TextStyle(color: _grisNieblaClaro),
                        cursorColor: _azulElectrico,
                        decoration: _decoracionCampo(
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
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const ValueKey('login-password'),
                        controller: _contrasenaController,
                        obscureText: !_mostrarContrasena,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        style: const TextStyle(color: _grisNieblaClaro),
                        cursorColor: _azulElectrico,
                        onFieldSubmitted: (_) {
                          if (!_cargando) {
                            _iniciarSesion();
                          }
                        },
                        decoration: _decoracionCampo(
                          labelText: 'Contraseña',
                          prefixIcon: Icons.lock_outline,
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
                              color: _grisNieblaMedio,
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
                          style: const TextStyle(
                            color: Color(0xFFFF8787),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        key: const ValueKey('login-submit'),
                        onPressed: _cargando ? null : _iniciarSesion,
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
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
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
                        style: TextButton.styleFrom(
                          foregroundColor: _azulElectrico,
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
}
