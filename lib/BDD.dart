import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService([SupabaseClient? client])
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<AuthResponse> iniciarSesion({
    required String correo,
    required String contrasena,
  }) => _supabase.auth.signInWithPassword(
    email: correo.trim(),
    password: contrasena,
  );
}
