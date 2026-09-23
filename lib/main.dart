import 'package:flutter/material.dart';

import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tipo.dart';
import 'package:tipo/valores_iniciales_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ValoresInicialesPage(),
    );
  }
}

class ValoresInicialesPage extends StatefulWidget {
  const ValoresInicialesPage({super.key});

  @override
  State<ValoresInicialesPage> createState() =>
      _ValoresInicialesPageState();
}

class _ValoresInicialesPageState extends State<ValoresInicialesPage> {
  static const casillasIniciales = [
    Coordenada(0, 0),
    Coordenada(1, 0),
  ];

  late final ValoresInicialesBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = ValoresInicialesBloc(
      casillasIniciales: casillasIniciales,
      crearTablero: () => Tablero(
        filas: 1,
        columnas: 3,
        regiones: [
          Region(
            tipo: TipoAzul(),
            coordenadas: [
              ...casillasIniciales,
              const Coordenada(2, 0),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_bloc.puedeAvanzar) return;

    final tablero = _bloc.avanzar();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Partida iniciada')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Valores iniciales guardados:'),
              for (final entrada in tablero.datos.entries)
                Text(
                  'Casilla (${entrada.key.x}, ${entrada.key.y}): '
                  '${entrada.value}',
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Valores iniciales')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Completa ambas casillas con números enteros iguales '
            'para iniciar la zona azul.',
          ),
          const SizedBox(height: 16),
          for (final casilla in casillasIniciales)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                decoration: InputDecoration(
                  labelText: 'Casilla (${casilla.x}, ${casilla.y})',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (texto) => _bloc.actualizar(casilla, texto),
              ),
            ),
          StreamBuilder<bool>(
            stream: _bloc.cambios,

            initialData: _bloc.puedeAvanzar,
            builder: (context, snapshot) {
              final habilitado = snapshot.data ?? false;

              return ElevatedButton(
                onPressed: habilitado ? _continuar : null,
                child: const Text('Continuar'),
              );
            },
          ),
        ],
      ),
    );
  }
}
