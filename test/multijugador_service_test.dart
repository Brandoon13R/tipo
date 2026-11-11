import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/multijugador_service.dart';

void main() {
  Map<String, dynamic> response({
    required String status,
    required Object? initialValues,
  }) => {
    'code': '123456',
    'status': status,
    'config_id': 'nivel_1',
    'initial_values': initialValues,
    'host_username': 'anfitrion',
    'is_host': false,
    'opponent_connected': true,
    'my_version': 0,
  };

  test('permite que el segundo jugador configure antes del inicio', () {
    final sala = EstadoSalaMultijugador.fromJson(
      response(status: 'configurando', initialValues: null),
    );

    expect(sala.estado, 'configurando');
    expect(sala.valoresIniciales, isNull);
  });

  test('requiere números iniciales para cargar una partida activa', () {
    expect(
      () => EstadoSalaMultijugador.fromJson(
        response(status: 'activa', initialValues: null),
      ),
      throwsA(isA<MultijugadorException>()),
    );
  });
}
