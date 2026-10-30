import 'package:flutter/material.dart';
import 'package:tipo/sesion_usuario.dart';

class PerfilUsuario extends StatelessWidget {
  const PerfilUsuario({super.key, required this.sesion});

  final SesionUsuario? sesion;

  @override
  Widget build(BuildContext context) {
    final userSession = sesion;
    if (userSession == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: userSession,
      builder: (context, _) {
        final username = userSession.usuarioName;
        if (username == null) return const SizedBox.shrink();

        return Chip(
          key: const ValueKey('perfil-usuario'),
          avatar: const Icon(Icons.account_circle_outlined, size: 20),
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(username, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }
}
