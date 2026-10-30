import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tipo/BDD.dart';

class SesionUsuario extends ChangeNotifier {
  SesionUsuario({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static final SesionUsuario instance = SesionUsuario();

  static const _tokenKey = 'session_token';
  static const _usernameKey = 'usuario_name';

  final FlutterSecureStorage _storage;
  String? _usuarioName;
  String? _token;
  String? _error;

  String? get usuarioName => _usuarioName;
  String? get token => _token;
  String? get error => _error;
  bool get activa => _token != null && _usuarioName != null;

  Future<void> restaurar(AuthService authService) async {
    final token = await _storage.read(key: _tokenKey);
    final username = await _storage.read(key: _usernameKey);
    if (token == null || username == null) return;

    try {
      final usernameValidado = await authService.validarSesion(token);
      _token = token;
      _usuarioName = usernameValidado;
      _error = null;
      await _storage.write(key: _usernameKey, value: usernameValidado);
    } on AuthServiceException catch (error) {
      if (error.statusCode == 401) {
        await limpiar();
        return;
      }
      _token = token;
      _usuarioName = username;
      _error = 'No se pudo validar la sesión: ${error.message}';
    }
    notifyListeners();
  }

  Future<void> iniciar(AuthSessionResult session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(key: _usernameKey, value: session.usuarioName);
    _token = session.token;
    _usuarioName = session.usuarioName;
    _error = null;
    notifyListeners();
  }

  Future<void> limpiar() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    _token = null;
    _usuarioName = null;
    _error = null;
    notifyListeners();
  }
}
