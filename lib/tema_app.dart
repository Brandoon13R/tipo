import 'package:flutter/material.dart';

enum IdTemaApp {
  aceroElectrico,
  perlaCobalto,
  cafeCrema,
  bosqueEsmeralda,
}

class PaletaTema {
  const PaletaTema({
    required this.id,
    required this.nombre,
    required this.descripcionProporcion,
    required this.esOscuro,
    // 60% · Color Dominante (fondos principales y superficies interiores)
    required this.fondoPrincipal,
    required this.fondoGradienteInicio,
    required this.fondoGradienteFin,
    required this.superficieInterior,
    required this.barraSuperior,
    // 30% · Color Secundario (tarjetas, paneles, bordes y tipografía)
    required this.panelSecundario,
    required this.bordeSecundario,
    required this.textoPrincipal,
    required this.textoSecundario,
    required this.sombraPanel,
    // 10% · Color Terciario / Acento (botones CTA, pivotes, emblemas y focos)
    required this.acento,
    required this.textoSobreAcento,
    required this.superficieAcentoSuave,
    required this.sombraAcento,
    required this.botonDeshabilitadoFondo,
    // Semánticos de error
    required this.error,
    required this.errorTexto,
    required this.errorSuperficie,
  });

  final IdTemaApp id;
  final String nombre;
  final String descripcionProporcion;
  final bool esOscuro;

  // 60% Dominante
  final Color fondoPrincipal;
  final Color fondoGradienteInicio;
  final Color fondoGradienteFin;
  final Color superficieInterior;
  final Color barraSuperior;

  // 30% Secundario
  final Color panelSecundario;
  final Color bordeSecundario;
  final Color textoPrincipal;
  final Color textoSecundario;
  final Color sombraPanel;

  // 10% Terciario (Acento)
  final Color acento;
  final Color textoSobreAcento;
  final Color superficieAcentoSuave;
  final Color sombraAcento;
  final Color botonDeshabilitadoFondo;

  // Error
  final Color error;
  final Color errorTexto;
  final Color errorSuperficie;

  /// Tema Oscuro 60-30-10:
  /// - 60%: Negro Metálico (#12161D / #181D26)
  /// - 30%: Gris Niebla (#252D3A / #E2E8F0)
  /// - 10%: Azul Eléctrico (#00C8FF)
  static const PaletaTema aceroElectrico = PaletaTema(
    id: IdTemaApp.aceroElectrico,
    nombre: 'Acero Eléctrico (Oscuro)',
    descripcionProporcion:
        '60% Negro Metálico · 30% Gris Niebla · 10% Azul Eléctrico',
    esOscuro: true,
    // 60%
    fondoPrincipal: Color(0xFF12161D),
    fondoGradienteInicio: Color(0xFF1A202B),
    fondoGradienteFin: Color(0xFF0D1015),
    superficieInterior: Color(0xFF181D26),
    barraSuperior: Color(0xFF161B24),
    // 30%
    panelSecundario: Color(0xFF252D3A),
    bordeSecundario: Color(0xFF3E4A5E),
    textoPrincipal: Color(0xFFE2E8F0),
    textoSecundario: Color(0xFF9FB0C4),
    sombraPanel: Color(0x66000000),
    // 10%
    acento: Color(0xFF00C8FF),
    textoSobreAcento: Color(0xFF09131C),
    superficieAcentoSuave: Color(0xFF113548),
    sombraAcento: Color(0x3800C8FF),
    botonDeshabilitadoFondo: Color(0xFF283546),
    // Error
    error: Color(0xFFFF6B6B),
    errorTexto: Color(0xFFFF8787),
    errorSuperficie: Color(0xFF3B1A1F),
  );

  /// Tema Claro 60-30-10:
  /// - 60%: Blanco Perla / Alabastro (#EEF3F8 / #E6EDF5)
  /// - 30%: Nieve & Gris Pizarra (#FFFFFF / #CBD6E4 / texto #1B2430)
  /// - 10%: Azul Cobalto Eléctrico (#0066FF)
  static const PaletaTema perlaCobalto = PaletaTema(
    id: IdTemaApp.perlaCobalto,
    nombre: 'Perla & Cobalto (Claro)',
    descripcionProporcion:
        '60% Blanco Perla · 30% Gris Pizarra y Nieve · 10% Azul Cobalto',
    esOscuro: false,
    // 60%
    fondoPrincipal: Color(0xFFEEF3F8),
    fondoGradienteInicio: Color(0xFFF7FAFD),
    fondoGradienteFin: Color(0xFFE2EAF3),
    superficieInterior: Color(0xFFF3F7FB),
    barraSuperior: Color(0xFFFFFFFF),
    // 30%
    panelSecundario: Color(0xFFFFFFFF),
    bordeSecundario: Color(0xFFCBD6E4),
    textoPrincipal: Color(0xFF1B2430),
    textoSecundario: Color(0xFF55657A),
    sombraPanel: Color(0x1A0F172A),
    // 10%
    acento: Color(0xFF0066FF),
    textoSobreAcento: Color(0xFFFFFFFF),
    superficieAcentoSuave: Color(0xFFE0EDFF),
    sombraAcento: Color(0x280066FF),
    botonDeshabilitadoFondo: Color(0xFFD6E0EC),
    // Error
    error: Color(0xFFD92D20),
    errorTexto: Color(0xFFB42318),
    errorSuperficie: Color(0xFFFEE4E2),
  );

  /// Tema Cálido 60-30-10 (Café + Crema + Ámbar Dorado):
  /// - 60%: Café Espresso / Nogal (#1E1510 / #261B14)
  /// - 30%: Crema Marfil & Cacao Suave (paneles #33241B, bordes #5C4332, textos crema #F5E6D3 y #CEB59A)
  /// - 10%: Ámbar Dorado (#F59E0B)
  static const PaletaTema cafeCrema = PaletaTema(
    id: IdTemaApp.cafeCrema,
    nombre: 'Café & Crema (Ámbar)',
    descripcionProporcion:
        '60% Café Espresso · 30% Crema Marfil · 10% Ámbar Dorado',
    esOscuro: true,
    // 60% Café Espresso dominante
    fondoPrincipal: Color(0xFF1E1510),
    fondoGradienteInicio: Color(0xFF2A1D16),
    fondoGradienteFin: Color(0xFF140D0A),
    superficieInterior: Color(0xFF261B14),
    barraSuperior: Color(0xFF231812),
    // 30% Crema Marfil (textos, bordes cálidos y paneles cacao/crema tostado)
    panelSecundario: Color(0xFF33241B),
    bordeSecundario: Color(0xFF634835),
    textoPrincipal: Color(0xFFF5E6D3),
    textoSecundario: Color(0xFFD2B89C),
    sombraPanel: Color(0x66090503),
    // 10% Ámbar Dorado (color terciario)
    acento: Color(0xFFF59E0B),
    textoSobreAcento: Color(0xFF1C1108),
    superficieAcentoSuave: Color(0xFF473016),
    sombraAcento: Color(0x38F59E0B),
    botonDeshabilitadoFondo: Color(0xFF453428),
    // Error
    error: Color(0xFFFF7A6B),
    errorTexto: Color(0xFFFF9B8F),
    errorSuperficie: Color(0xFF421C19),
  );

  /// Tema Naturaleza / Estrategia 60-30-10 (Pino Profundo + Salvia Niebla + Verde Esmeralda):
  /// - 60%: Pino Profundo / Obsidiana Bosque (#0E1E1B / #132824)
  /// - 30%: Salvia Brumosa (paneles #1B3631, bordes #2F5C53, textos #E4F4F0 y #9BC2B9)
  /// - 10%: Verde Esmeralda Brillante (#00E5A3)
  static const PaletaTema bosqueEsmeralda = PaletaTema(
    id: IdTemaApp.bosqueEsmeralda,
    nombre: 'Bosque & Esmeralda',
    descripcionProporcion:
        '60% Pino Profundo · 30% Salvia Niebla · 10% Verde Esmeralda',
    esOscuro: true,
    // 60% Pino Profundo dominante
    fondoPrincipal: Color(0xFF0E1E1B),
    fondoGradienteInicio: Color(0xFF152C27),
    fondoGradienteFin: Color(0xFF081210),
    superficieInterior: Color(0xFF132824),
    barraSuperior: Color(0xFF112420),
    // 30% Salvia Niebla (tarjetas, bordes y tipografía)
    panelSecundario: Color(0xFF1B3631),
    bordeSecundario: Color(0xFF2F5C53),
    textoPrincipal: Color(0xFFE4F4F0),
    textoSecundario: Color(0xFF9BC2B9),
    sombraPanel: Color(0x66040B09),
    // 10% Verde Esmeralda Brillante (color terciario)
    acento: Color(0xFF00E5A3),
    textoSobreAcento: Color(0xFF062018),
    superficieAcentoSuave: Color(0xFF104237),
    sombraAcento: Color(0x3800E5A3),
    botonDeshabilitadoFondo: Color(0xFF22403A),
    // Error
    error: Color(0xFFFF6B6B),
    errorTexto: Color(0xFFFF8E8E),
    errorSuperficie: Color(0xFF3D1A1E),
  );

  static const List<PaletaTema> todas = [
    aceroElectrico,
    perlaCobalto,
    cafeCrema,
    bosqueEsmeralda,
  ];

  ThemeData toThemeData() {
    final brightness = esOscuro ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: acento,
      onPrimary: textoSobreAcento,
      secondary: textoPrincipal,
      onSecondary: fondoPrincipal,
      surface: panelSecundario,
      onSurface: textoPrincipal,
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: fondoPrincipal,
      appBarTheme: AppBarTheme(
        backgroundColor: barraSuperior,
        foregroundColor: textoPrincipal,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: acento),
        titleTextStyle: TextStyle(
          color: textoPrincipal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: panelSecundario,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: bordeSecundario, width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panelSecundario,
        titleTextStyle: TextStyle(
          color: textoPrincipal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: textoPrincipal,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: bordeSecundario, width: 1.2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: bordeSecundario,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: acento,
          foregroundColor: textoSobreAcento,
          disabledBackgroundColor: botonDeshabilitadoFondo,
          disabledForegroundColor: textoSecundario,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: superficieInterior,
          foregroundColor: textoPrincipal,
          side: BorderSide(color: acento, width: 1.3),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: acento),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficieInterior,
        labelStyle: TextStyle(color: textoSecundario),
        hintStyle: TextStyle(color: textoSecundario),
        floatingLabelStyle: TextStyle(
          color: acento,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: bordeSecundario, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: acento, width: 1.8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: bordeSecundario, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: superficieInterior,
        selectedColor: superficieAcentoSuave,
        side: BorderSide(color: bordeSecundario),
        labelStyle: TextStyle(color: textoPrincipal),
        secondaryLabelStyle: TextStyle(
          color: acento,
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: acento,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panelSecundario,
        contentTextStyle: TextStyle(color: textoPrincipal),
      ),
    );
  }
}

class ControladorTema extends ChangeNotifier {
  ControladorTema._();

  static final ControladorTema instance = ControladorTema._();

  PaletaTema _actual = PaletaTema.aceroElectrico;

  PaletaTema get actual => _actual;

  void seleccionar(IdTemaApp id) {
    final nuevo = switch (id) {
      IdTemaApp.perlaCobalto => PaletaTema.perlaCobalto,
      IdTemaApp.cafeCrema => PaletaTema.cafeCrema,
      IdTemaApp.bosqueEsmeralda => PaletaTema.bosqueEsmeralda,
      IdTemaApp.aceroElectrico => PaletaTema.aceroElectrico,
    };
    if (_actual.id == nuevo.id) return;
    _actual = nuevo;
    notifyListeners();
  }
}

/// Botón desplegable para elegir el tema 60-30-10 de la aplicación.
class SelectorTemaButton extends StatelessWidget {
  const SelectorTemaButton({super.key, this.controlador});

  final ControladorTema? controlador;

  @override
  Widget build(BuildContext context) {
    final ctrl = controlador ?? ControladorTema.instance;
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final paleta = ctrl.actual;
        return PopupMenuButton<IdTemaApp>(
          key: const ValueKey('selector-tema'),
          tooltip: 'Cambiar tema de colores',
          position: PopupMenuPosition.under,
          color: paleta.panelSecundario,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: paleta.bordeSecundario, width: 1.2),
          ),
          onSelected: ctrl.seleccionar,
          itemBuilder: (context) => [
            for (final opcion in PaletaTema.todas)
              PopupMenuItem<IdTemaApp>(
                key: ValueKey('tema-${opcion.id.name}'),
                value: opcion.id,
                child: Row(
                  children: [
                    _MuestraProporcionColores(paleta: opcion),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            opcion.nombre,
                            style: TextStyle(
                              fontWeight: opcion.id == paleta.id
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: paleta.textoPrincipal,
                              fontSize: 13.5,
                            ),
                          ),
                          Text(
                            opcion.descripcionProporcion,
                            style: TextStyle(
                              fontSize: 11,
                              color: paleta.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (opcion.id == paleta.id) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: paleta.acento,
                      ),
                    ],
                  ],
                ),
              ),
          ],
          child: Material(
            color: paleta.panelSecundario,
            shape: StadiumBorder(
              side: BorderSide(color: paleta.bordeSecundario, width: 1.4),
            ),
            elevation: 2,
            shadowColor: paleta.sombraPanel,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 18,
                    color: paleta.acento,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Temas',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: paleta.textoPrincipal,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: paleta.acento,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MuestraProporcionColores extends StatelessWidget {
  const _MuestraProporcionColores({required this.paleta});

  final PaletaTema paleta;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 20,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: paleta.bordeSecundario),
    ),
    child: Row(
      children: [
        // 60%
        Expanded(
          flex: 6,
          child: Container(color: paleta.fondoPrincipal),
        ),
        // 30%
        Expanded(
          flex: 3,
          child: Container(color: paleta.bordeSecundario),
        ),
        // 10%
        Expanded(
          flex: 2,
          child: Container(color: paleta.acento),
        ),
      ],
    ),
  );
}
