import 'package:flutter/material.dart';
import 'package:tipo/nivel_config.dart';
import 'package:tipo/tema_app.dart';

Future<void> mostrarDialogoReglasJuego(
  BuildContext context, {
  bool incluirMultijugador = true,
}) => showDialog<void>(
  context: context,
  builder: (_) =>
      DialogoReglasJuego(incluirMultijugador: incluirMultijugador),
);

class BotonReglasJuego extends StatelessWidget {
  const BotonReglasJuego({
    super.key,
    this.esCompacto = false,
    this.incluirMultijugador = true,
  });

  final bool esCompacto;
  final bool incluirMultijugador;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ControladorTema.instance,
    builder: (context, _) {
      final paleta = ControladorTema.instance.actual;

      if (esCompacto) {
        return Tooltip(
          message: 'Ver reglas del juego',
          child: Material(
            color: paleta.panelSecundario,
            shape: StadiumBorder(
              side: BorderSide(color: paleta.bordeSecundario, width: 1.4),
            ),
            elevation: 2,
            shadowColor: paleta.sombraPanel,
            child: InkWell(
              key: const ValueKey('boton-reglas-juego'),
              customBorder: const StadiumBorder(),
              onTap: () => mostrarDialogoReglasJuego(
                context,
                incluirMultijugador: incluirMultijugador,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: paleta.acento,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Reglas',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: paleta.textoPrincipal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return OutlinedButton.icon(
        key: const ValueKey('boton-reglas-juego'),
        onPressed: () => mostrarDialogoReglasJuego(
          context,
          incluirMultijugador: incluirMultijugador,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: paleta.superficieInterior,
          foregroundColor: paleta.textoPrincipal,
          side: BorderSide(color: paleta.acento, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(Icons.menu_book_rounded, color: paleta.acento),
        label: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            'Reglas del juego',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: paleta.textoPrincipal,
            ),
          ),
        ),
      );
    },
  );
}

class DialogoReglasJuego extends StatelessWidget {
  const DialogoReglasJuego({super.key, this.incluirMultijugador = true});

  final bool incluirMultijugador;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ControladorTema.instance,
    builder: (context, _) {
      final paleta = ControladorTema.instance.actual;

      return AlertDialog(
        key: const ValueKey('dialogo-reglas-juego'),
        backgroundColor: paleta.panelSecundario,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: paleta.bordeSecundario, width: 1.4),
        ),
        title: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: paleta.acento, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '¿Cómo jugar a Brilliant?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: paleta.textoPrincipal,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _seccionPaso(
                  paleta: paleta,
                  icono: Icons.looks_one_rounded,
                  titulo: '1. Coloca tus 6 números iniciales (Pivotes)',
                  descripcion:
                      'Antes de iniciar, asigna los números del 1 al 6 sin repetir '
                      'en las 6 casillas marcadas con el signo +.',
                ),
                const SizedBox(height: 10),
                _seccionPaso(
                  paleta: paleta,
                  icono: Icons.casino_outlined,
                  titulo: '2. Turno de dados: Pivote y Valor',
                  descripcion:
                      'En cada turno recibes 2 dados:\n'
                      '• Elige uno de los dados como PIVOTE (se iluminarán las casillas vacías vecinas a cualquier casilla que ya tenga ese número).\n'
                      '• El valor del OTRO dado es el número que colocarás en la casilla iluminada que toques.',
                ),
                const SizedBox(height: 14),
                Text(
                  '3. Reglas de las zonas por color',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: paleta.acento,
                  ),
                ),
                const SizedBox(height: 8),
                _filaColorRegla(
                  paleta: paleta,
                  color: ColorCasilla.azul.color,
                  nombre: 'Zona Azul (7 · 5 · 3 pts)',
                  regla: 'Todos los números de la zona deben ser IGUALES.',
                ),
                _filaColorRegla(
                  paleta: paleta,
                  color: ColorCasilla.rojo.color,
                  nombre: 'Zona Roja (6 · 4 · 2 pts)',
                  regla:
                      'Todos los números de la zona deben ser DISTINTOS (sin repetir).',
                ),
                _filaColorRegla(
                  paleta: paleta,
                  color: ColorCasilla.morado.color,
                  nombre: 'Zona Violeta / Morada (6 · 4 · 2 pts)',
                  regla:
                      'Acepta máximo 2 números distintos en Nivel 1 (o alternar par/impar entre casillas vecinas en niveles avanzados).',
                ),
                _filaColorRegla(
                  paleta: paleta,
                  color: ColorCasilla.verde.color,
                  nombre: 'Zona Verde (4 · 3 · 2 pts)',
                  regla:
                      'Acepta cualquier número del 1 al 6 (o alternar paridad en niveles avanzados).',
                ),
                _filaColorRegla(
                  paleta: paleta,
                  color: ColorCasilla.amarillo.color,
                  nombre: 'Casillas Amarillas (8 · 6 · 4 pts)',
                  regla:
                      'Repartidas por el tablero: deben completarse con números distintos o según el rango del nivel.',
                ),
                if (incluirMultijugador) ...[
                  const SizedBox(height: 14),
                  _seccionPaso(
                    paleta: paleta,
                    icono: Icons.emoji_events_outlined,
                    titulo: '4. Multijugador y Clasificatorias (Elo)',
                    descripcion:
                        '• Las posiciones de cada zona (1.º, 2.º y 3.º) son compartidas entre los jugadores de la sala según quién complete primero cada región.\n'
                        '• En Clasificatorias la partida termina cuando se ocupan los 3 primeros puestos del podio:\n'
                        '  1.º puesto: +12 Elo + puntos del tablero\n'
                        '  2.º puesto: +8 Elo + puntos del tablero\n'
                        '  3.º puesto: +5 Elo + puntos del tablero',
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            key: const ValueKey('cerrar-reglas-juego'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      );
    },
  );

  Widget _seccionPaso({
    required PaletaTema paleta,
    required IconData icono,
    required String titulo,
    required String descripcion,
  }) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: paleta.superficieInterior,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: paleta.bordeSecundario),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: paleta.acento),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: paleta.textoPrincipal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          descripcion,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.35,
            color: paleta.textoSecundario,
          ),
        ),
      ],
    ),
  );

  Widget _filaColorRegla({
    required PaletaTema paleta,
    required Color color,
    required String nombre,
    required String regla,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: paleta.superficieInterior,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: paleta.bordeSecundario, width: 0.8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: paleta.textoPrincipal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                regla,
                style: TextStyle(
                  fontSize: 12,
                  color: paleta.textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
