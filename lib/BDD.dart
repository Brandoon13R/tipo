import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService([SupabaseClient? client])
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<void> registrarUsuario(String nombre, String contrasena) async {
    await _supabase.from('usuarios').insert({
      'Usuario_name': nombre.trim(),
      'contrasena': contrasena,
    });
  }
}
