import 'package:flutter/material.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/region.dart';
import 'package:tipo/juego_bloc.dart';
import 'package:tipo/tablero_config.dart';
import 'package:tipo/valores_iniciales_bloc.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF193E37)),
      scaffoldBackgroundColor: const Color(0xFFF4F7F4),
    ),
    home: const ValoresInicialesPage(),
  );
}

class ValoresInicialesPage extends StatefulWidget {
  const ValoresInicialesPage({super.key});
  @override
  State<ValoresInicialesPage> createState() => _ValoresInicialesPageState();
}

class _ValoresInicialesPageState extends State<ValoresInicialesPage> {
  final _bloc = ValoresInicialesBloc();
  Tablero? _tableroIniciado;
  JuegoBloc? _juego;

  Future<void> _elegir(String region) async {
    if (_tableroIniciado != null) return;
    final valor = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Número inicial · $region'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Actual: ${_bloc.valores[region] ?? "sin asignar"}'),
          ),
          for (var numero = 1; numero <= 6; numero++)
            SimpleDialogOption(
              key: ValueKey('opcion-$numero'),
              onPressed: () => Navigator.pop(context, numero),
              child: Text('$numero'),
            ),
          SimpleDialogOption(
            key: const ValueKey('borrar'),
            onPressed: () => Navigator.pop(context, 0),
            child: const Text('Borrar número'),
          ),
        ],
      ),
    );
    if (!mounted || valor == null) return;
    _bloc.actualizar(region, valor == 0 ? '' : '$valor');
  }

  void _iniciar() {
    if (_tableroIniciado != null || !_bloc.puedeContinuar) return;
    final datos = _bloc.confirmar();
    final tablero = TableroConfig.crearTablero();
    for (final entrada in datos.entries) {
      if (!tablero.agregar(TableroConfig.iniciales[entrada.key]!, entrada.value)) {
        throw StateError('Configuración inicial incompatible con las regiones.');
      }
    }
    setState(() {
      _tableroIniciado = tablero;
      _juego = JuegoBloc(tablero);
    });
  }

  Widget _controlesJuego(JuegoBloc juego) {
    final pendientes = juego.tiradaPendiente;
    final pivote = juego.pivote;
    final posibles = juego.casillasIluminadas.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Turno de juego', style: TextStyle(
          fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(pendientes
          ? pivote == null
            ? 'Elige un dado como pivote. Colocarás el valor del otro.'
            : posibles == 0
              ? 'No hay casillas válidas con ese pivote. Prueba el otro dado o pulsa Omitir.'
              : 'Toca una casilla iluminada para colocar ${juego.valorAColocar}.'
          : 'Tira los dados para comenzar la siguiente jugada.',
          key: const ValueKey('instruccion-turno')),
        const SizedBox(height: 12),
        Row(children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: OutlinedButton(
              key: ValueKey('dado-$i'),
              onPressed: pendientes ? () => juego.elegirPivote(i) : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: pivote == i
                  ? const Color(0xFFD4F4D8) : Colors.white,
                side: BorderSide(
                  color: pivote == i
                    ? const Color(0xFF193E37) : Colors.black38,
                  width: pivote == i ? 2 : 1,
                ),
              ),
              child: Text('${i == 0 ? juego.dadoA ?? "–" : juego.dadoB ?? "–"}',
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            )),
          ],
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: FilledButton(
            key: const ValueKey('tirar'),
            onPressed: pendientes ? null : juego.tirar,
            child: const Text('Tirar dados'),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton(
            key: const ValueKey('omitir'),
            onPressed: pendientes ? juego.omitir : null,
            child: const Text('Omitir'),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton(
            key: const ValueKey('reiniciar'),
            onPressed: () {
              setState(() {
                _tableroIniciado = null;
                _juego?.dispose();
                _juego = null;
              });
            },
            child: const Text('Reiniciar'),
          )),
        ]),
        const SizedBox(height: 4),
        Text('Jugadas: ${juego.turnosJugados} · Omitidas: ${juego.turnosOmitidos}',
          key: const ValueKey('contador-turnos')),
      ],
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    _juego?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: StreamBuilder<bool>(
              stream: _bloc.cambios,
              initialData: _bloc.puedeContinuar,
              builder: (context, snapshot) {
                final valores = _bloc.valores;
                final cantidad = valores.values.whereType<int>().length;
                final iniciado = _tableroIniciado != null;
                final completos = snapshot.data ?? false;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(children: [
                      Icon(Icons.grid_view_rounded, color: Color(0xFF193E37)),
                      SizedBox(width: 10),
                      Text('BRILLIANT', style: TextStyle(
                        letterSpacing: 2, fontWeight: FontWeight.w700)),
                      Spacer(),
                      Text('7 × 7'),
                    ]),
                    const SizedBox(height: 24),
                    const Text('Mapa de colores', style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w700,
                      color: Color(0xFF193E37))),
                    const SizedBox(height: 8),
                    const Text('Toca las seis casillas con + y distribuye '
                      'los números del 1 al 6 sin repetir.'),
                    const SizedBox(height: 20),
                    StreamBuilder<int>(
                      stream: _juego?.cambios,
                      initialData: 0,
                      builder: (context, _) {
                        final juego = _juego;
                        return Column(
                          children: [
                            TableroVisual(
                              valores: valores,
                              habilitado: !iniciado,
                              onSeleccionar: _elegir,
                              tablero: juego?.tablero,
                              iluminadas: juego?.casillasIluminadas ?? const {},
                              onJugar: juego?.colocar,
                            ),
                            if (juego != null) ...[
                              const SizedBox(height: 18),
                              _controlesJuego(juego),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text('$cantidad DE 6 NÚMEROS COLOCADOS',
                      key: const ValueKey('progreso'),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(iniciado
                      ? 'Datos iniciales guardados en el tablero.'
                      : completos
                        ? 'Todo listo. Puedes pulsar Inicio.'
                        : cantidad == 6
                          ? 'Hay números repetidos. Usa cada número una sola vez.'
                          : 'Completa las seis casillas para habilitar Inicio.',
                      key: const ValueKey('estado')),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 14, runSpacing: 8,
                      children: [
                        for (final color in ColorCasilla.values)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: 9, height: 9,
                              decoration: BoxDecoration(color: color.color,
                                borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 5),
                            Text(color.nombre, style: const TextStyle(fontSize: 12)),
                          ]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const ValueKey('inicio'),
                      onPressed: completos && !iniciado ? _iniciar : null,
                      child: const Text('Inicio'),
                    ),
                    if (iniciado) ...[
                      const SizedBox(height: 16),
                      const Text('Selección inicial confirmada',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      for (final entrada in TableroConfig.iniciales.entries)
                        Text('${entrada.key} · fila ${entrada.value.y + 1}, '
                          'columna ${entrada.value.x + 1}: '
                          '${_tableroIniciado!.valorEn(entrada.value)}'),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

/// Componente reutilizable: 49 cuadrados y un espacio uniforme de 6 px.
class TableroVisual extends StatelessWidget {
  const TableroVisual({
    super.key,
    required this.valores,
    required this.habilitado,
    required this.onSeleccionar,
    this.tablero,
    this.iluminadas = const {},
    this.onJugar,
  });
  final Map<String, int?> valores;
  final bool habilitado;
  final ValueChanged<String> onSeleccionar;
  final Tablero? tablero;
  final Set<Coordenada> iluminadas;
  final ValueChanged<Coordenada>? onJugar;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var y = 0; y < 7; y++) ...[
        if (y > 0) const SizedBox(height: 6),
        Row(
          children: [
            for (var x = 0; x < 7; x++) ...[
              if (x > 0) const SizedBox(width: 6),
              Expanded(child: AspectRatio(
                aspectRatio: 1,
                child: _celda(x, y),
              )),
            ],
          ],
        ),
      ],
    ],
  );

  Widget _celda(int x, int y) {
    String? region;
    for (final entrada in TableroConfig.iniciales.entries) {
      if (entrada.value.x == x && entrada.value.y == y) region = entrada.key;
    }
    final seleccionable = region;
    final posicion = Coordenada(x, y);
    final destacada = iluminadas.contains(posicion);
    final numero = tablero?.valorEn(posicion) ?? valores[region];
    final color = TableroConfig.matriz[y][x];
    final etiqueta = 'Fila ${y + 1}, columna ${x + 1}, ${color.nombre}'
        '${region == null ? "" : ", $region, número ${numero ?? "sin asignar"}"}';
    return Semantics(
      label: destacada ? '$etiqueta, disponible para colocar' : etiqueta,
      button: region != null,
      child: Tooltip(
        message: etiqueta,
        child: Material(
          key: ValueKey('celda-$x-$y'),
          color: destacada ? Color.lerp(color.color, Colors.white, 0.38)! : color.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: destacada ? Colors.white
                  : region != null ? const Color(0xFF193E37) : Colors.transparent,
              width: destacada ? 3 : 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: destacada && onJugar != null
                ? () => onJugar!(posicion)
                : habilitado && seleccionable != null
                  ? () => onSeleccionar(seleccionable) : null,
            child: Center(
              child: numero != null
                  ? Text('$numero', style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: Color(0xFF102A25)))
                  : destacada
                    ? const Icon(Icons.add_circle_outline, size: 22,
                        color: Color(0xFF102A25))
                    : region != null
                      ? const Icon(Icons.add, size: 18, color: Color(0xFF193E37))
                      : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
