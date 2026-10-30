import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilUsuario extends StatelessWidget {
  const PerfilUsuario({super.key, required this.client});

  final SupabaseClient? client;

  @override
  Widget build(BuildContext context) {
    final supabaseClient = client;
    if (supabaseClient == null) return const SizedBox.shrink();

    final auth = supabaseClient.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final usuario = snapshot.hasData
            ? snapshot.data!.session?.user
            : auth.currentUser;
        if (usuario == null) return const SizedBox.shrink();

        final metadata = usuario.userMetadata;
        final nombre = metadata?['usuario_name'] as String?;
        final etiqueta = nombre?.trim().isNotEmpty == true
            ? nombre!.trim()
            : usuario.email ?? 'Perfil';

        return Chip(
          key: const ValueKey('perfil-usuario'),
          avatar: const Icon(Icons.account_circle_outlined, size: 20),
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(etiqueta, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }
}
