import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/BDD.dart';
import 'package:tipo/main.dart';
import 'package:tipo/login.dart';
import 'package:tipo/registro.dart';
import 'package:tipo/sesion_usuario.dart';

void main() {
  group('MainApp y ValoresInicialesPage Tests', () {
    testWidgets(
      'Montaje inicial muestra interfaz base y botón Inicio deshabilitado',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MainApp());
        await tester.tap(find.byKey(const ValueKey('jugar')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('seleccionar-nivel_1')));
        await tester.pumpAndSettle();

        // Verifica textos y títulos iniciales
        expect(find.text('BRILLIANT'), findsOneWidget);
        expect(find.text('Mapa de colores'), findsOneWidget);
        expect(find.text('7 × 7'), findsOneWidget);

        // Verifica el contador de progreso inicial
        expect(find.byKey(const ValueKey('progreso')), findsOneWidget);
        expect(find.text('0 DE 6 NÚMEROS COLOCADOS'), findsOneWidget);

        // Verifica la instrucción de estado
        expect(
          find.text('Completa las seis casillas para habilitar Inicio.'),
          findsOneWidget,
        );

        // Verifica que el botón de inicio existe pero está deshabilitado (onPressed == null)
        final botonInicioFinder = find.byKey(const ValueKey('inicio'));
        expect(botonInicioFinder, findsOneWidget);

        final FilledButton botonInicio = tester.widget(botonInicioFinder);
        expect(botonInicio.onPressed, isNull);
      },
    );

    testWidgets(
      'Tocar una casilla inicial abre el diálogo y actualiza el progreso',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MainApp());
        await tester.tap(find.byKey(const ValueKey('jugar')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('seleccionar-nivel_1')));
        await tester.pumpAndSettle();

        // Busca el ícono '+' que tienen las casillas iniciales habilitadas
        final casillasLibres = find.byIcon(Icons.add);
        expect(casillasLibres, findsWidgets);

        // Simula el toque en la primera casilla disponible
        await tester.tap(casillasLibres.first);
        await tester.pumpAndSettle();

        // Verifica que el diálogo se abre mostrando las opciones y el botón de borrar
        expect(find.byType(SimpleDialog), findsOneWidget);
        expect(find.text('Borrar número'), findsOneWidget);
        expect(find.byKey(const ValueKey('opcion-4')), findsOneWidget);

        // Elige el número 4 dentro del diálogo
        await tester.tap(find.text('4'));
        await tester
            .pumpAndSettle(); // Espera a que la animación del diálogo termine

        // Verifica que el progreso del Bloc se actualizó en la UI
        expect(find.text('1 DE 6 NÚMEROS COLOCADOS'), findsOneWidget);

        // Verifica que el número 4 ahora se dibuja en la pantalla (como casilla seleccionada)
        expect(find.text('4'), findsWidgets);
      },
    );

    testWidgets('el menú abre la pantalla de inicio de sesión', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MainApp());

      expect(find.byType(MenuPage), findsOneWidget);
      expect(find.text('Jugar'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('iniciar-sesion')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Nombre de usuario'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('¿No tienes cuenta? Crea tu cuenta'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('login-crear-cuenta')));
      await tester.pumpAndSettle();
      expect(find.byType(RegistroPage), findsOneWidget);
      expect(find.text('Nombre de usuario'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('registro-volver')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('login-volver')));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('jugar')));
      await tester.pumpAndSettle();
      expect(find.byType(SeleccionNivelPage), findsOneWidget);
    });

    testWidgets('niveles permite regresar al inicio y cerrar la aplicación', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MainApp());
      await tester.tap(find.byKey(const ValueKey('jugar')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('volver-inicio')), findsOneWidget);
      expect(find.byKey(const ValueKey('cerrar-aplicacion')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('volver-inicio')));
      await tester.pumpAndSettle();

      expect(find.byType(MenuPage), findsOneWidget);
      expect(find.text('Jugar'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('cancelar la confirmación conserva la cuenta', (
      WidgetTester tester,
    ) async {
      final session = _FakeSesionUsuario();
      final authService = _FakeAuthService();
      await tester.pumpWidget(
        MaterialApp(
          home: MenuPage(sesionUsuario: session, authService: authService),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('eliminar-cuenta')));
      await tester.pumpAndSettle();
      expect(find.text('¿Eliminar cuenta?'), findsOneWidget);
      expect(find.textContaining('No se puede deshacer.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('cancelar-eliminar-cuenta')));
      await tester.pumpAndSettle();

      expect(authService.deletedToken, isNull);
      expect(session.activa, isTrue);
      expect(find.byKey(const ValueKey('eliminar-cuenta')), findsOneWidget);
    });

    testWidgets('confirmar elimina la cuenta y limpia la sesión local', (
      WidgetTester tester,
    ) async {
      final session = _FakeSesionUsuario();
      final authService = _FakeAuthService();
      await tester.pumpWidget(
        MaterialApp(
          home: MenuPage(sesionUsuario: session, authService: authService),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('eliminar-cuenta')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirmar-eliminar-cuenta')));
      await tester.pumpAndSettle();

      expect(authService.deletedToken, 'test-session-token');
      expect(session.activa, isFalse);
      expect(find.text('La cuenta se eliminó correctamente.'), findsOneWidget);
      expect(find.byKey(const ValueKey('eliminar-cuenta')), findsNothing);
    });
  });
}

class _FakeSesionUsuario extends SesionUsuario {
  bool _activa = true;

  @override
  String? get token => _activa ? 'test-session-token' : null;

  @override
  String? get usuarioName => _activa ? 'jugador' : null;

  @override
  bool get activa => _activa;

  @override
  Future<void> limpiar() async {
    _activa = false;
    notifyListeners();
  }
}

class _FakeAuthService implements AuthService {
  String? deletedToken;

  @override
  Future<void> eliminarCuenta(String token) async {
    deletedToken = token;
  }

  @override
  Future<AuthSessionResult> iniciarSesion({
    required String usuarioName,
    required String contrasena,
  }) => throw UnimplementedError();

  @override
  Future<AuthSessionResult> registrarUsuario({
    required String usuarioName,
    required String contrasena,
  }) => throw UnimplementedError();

  @override
  Future<void> cerrarSesion(String token) => throw UnimplementedError();

  @override
  Future<String> validarSesion(String token) => throw UnimplementedError();
}
