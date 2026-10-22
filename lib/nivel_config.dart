import 'package:flutter/material.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tipo.dart';

enum ColorCasilla {
  amarillo('Amarillo', Color(0xFFF1C40F)),
  verde('Verde', Color(0xFF2ECC71)),
  azul('Azul', Color(0xFF3498DB)),
  morado('Morado', Color(0xFF9B59B6)),
  rojo('Rojo', Color(0xFFE74C3C)),
  blanco('Blanco', Color(0xFFFFFFFF));

  const ColorCasilla(this.nombre, this.color);
  final String nombre;
  final Color color;

  Tipo crearTipo() => switch (this) {
    amarillo => TipoAmarillo(),
    verde => TipoVerde(),
    azul => TipoAzul(),
    morado => TipoMorado(),
    rojo => TipoRojo(),
    blanco => TipoAzul(),
  };
}

abstract class NivelConfig {
  String get id;
  String get nombre;
  List<List<ColorCasilla>> get matriz;
  Map<String, Coordenada> get iniciales;
  List<Region> get regiones;
  List<Region> get regionesDeJuego => regiones;
}
