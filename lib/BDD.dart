import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServiceException implements Exception {
  const AuthServiceException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthSessionResult {
  const AuthSessionResult({required this.usuarioName, required this.token});

  final String usuarioName;
  final String token;

  factory AuthSessionResult.fromJson(Map<String, dynamic> json) {
    final username = json['usuario_name'];
    final token = json['session_token'];
    if (username is! String || token is! String) {
      throw const AuthServiceException(
        'El servidor devolvió una respuesta de sesión inválida.',
      );
    }
    return AuthSessionResult(usuarioName: username, token: token);
  }
}

class AuthService {
  AuthService(this._supabase);

  final SupabaseClient _supabase;

  Future<AuthSessionResult> iniciarSesion({
    required String usuarioName,
    required String contrasena,
  }) async {
    final response = await _invoke({
      'action': 'login',
      'usuario_name': usuarioName,
      'contrasena': contrasena,
    });
    return AuthSessionResult.fromJson(response);
  }

  Future<AuthSessionResult> registrarUsuario({
    required String usuarioName,
    required String contrasena,
  }) async {
    final response = await _invoke({
      'action': 'register',
      'usuario_name': usuarioName,
      'contrasena': contrasena,
    });
    return AuthSessionResult.fromJson(response);
  }

  Future<String> validarSesion(String token) async {
    final response = await _invoke({
      'action': 'session',
      'session_token': token,
    });
    final username = response['usuario_name'];
    if (username is! String) {
      throw const AuthServiceException(
        'El servidor devolvió una respuesta de sesión inválida.',
      );
    }
    return username;
  }

  Future<void> cerrarSesion(String token) async {
    await _invoke({'action': 'logout', 'session_token': token});
  }

  Future<Map<String, dynamic>> _invoke(Map<String, dynamic> body) async {
    try {
      final response = await _supabase.functions.invoke(
        'usuario-auth',
        body: body,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw const AuthServiceException(
        'El servidor devolvió una respuesta inválida.',
      );
    } on FunctionException catch (error) {
      dynamic details = error.details;
      if (details is String) {
        try {
          details = jsonDecode(details);
        } on FormatException {
          details = null;
        }
      }
      final message = details is Map && details['error'] is String
          ? details['error'] as String
          : error.status == 0
          ? 'No se pudo conectar con el servicio de autenticación.'
          : 'No se pudo completar la solicitud de autenticación.';
      throw AuthServiceException(message, statusCode: error.status);
    }
  }
}
