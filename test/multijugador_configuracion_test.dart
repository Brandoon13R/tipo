import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipo/multijugador.dart';
import 'package:tipo/multijugador_service.dart';

void main() {
  testWidgets('el segundo jugador ve los pivotes y espera su confirmación', (
    tester,
  ) async {
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    final service = MultijugadorService(
      client,
      'test-token',
    );
    final sala = EstadoSalaMultijugador(
      codigo: '123456',
      estado: 'configurando',
      configId: 'nivel_1',
      valoresIniciales: null,
      usuarioAnfitrion: 'anfitrion',
      usuarioOponente: 'invitado',
      esAnfitrion: false,
      oponenteConectado: true,
      reclamarDesde: null,
      horaServidor: null,
      horaLocalRecibida: DateTime.now(),
      estadoPropio: null,
      versionPropia: 0,
      estadoOponente: null,
      ganador: null,
      motivoFinalizacion: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ConfigurarTableroMultijugadorPage(
          service: service,
          salaInicial: sala,
          usuario: 'invitado',
        ),
      ),
    );

    expect(find.text('Nivel 1 · Tu tablero'), findsOneWidget);
    for (final pivot in [
      'celda-2-0',
      'celda-5-1',
      'celda-1-3',
      'celda-4-3',
      'celda-2-5',
      'celda-4-6',
    ]) {
      expect(find.byKey(ValueKey(pivot)), findsOneWidget);
    }
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('iniciar-partida-multijugador')),
          )
          .onPressed,
      isNull,
    );
  });
}
