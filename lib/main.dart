import 'package:flutter/material.dart';
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
  final _bloc = ValoresInicialesBloc();

  Map<String, int>? _datosGuardados;

  void _actualizar(String region, String texto) {
    _bloc.actualizar(region, texto);

    // Si se edita un dato, el resumen anterior deja de estar confirmado.
    if (_datosGuardados != null) {
      setState(() {
        _datosGuardados = null;
      });
    }
  }

  void _continuar() {
    if (!_bloc.puedeContinuar) return;

    final datos = _bloc.confirmar();

    setState(() {
      _datosGuardados = datos;
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardados = _datosGuardados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos iniciales'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Elige un número inicial para cada región. '
            'Debes utilizar los números del 1 al 6 sin repetir.',
          ),
          const SizedBox(height: 20),

          for (final region in ValoresInicialesBloc.regiones)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                key: ValueKey(region),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: region,
                  hintText: 'Escribe un número del 1 al 6',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (texto) => _actualizar(region, texto),
              ),
            ),

          StreamBuilder<bool>(
            stream: _bloc.cambios,
            initialData: _bloc.puedeContinuar,
            builder: (context, snapshot) {
              final habilitado = snapshot.data ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    habilitado
                        ? 'Todos los datos están completos y son válidos.'
                        : 'Completa las seis regiones con números '
                            'del 1 al 6, sin repetir.',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: habilitado ? _continuar : null,
                    child: const Text('Continuar'),
                  ),
                ],
              );
            },
          ),

          if (guardados != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Estos son los datos iniciales guardados:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            for (final entrada in guardados.entries)
              Text('${entrada.key}: ${entrada.value}'),
          ],
        ],
      ),
    );
  }
}