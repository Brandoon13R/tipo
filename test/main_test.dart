import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/BDD.dart';
import 'package:tipo/main.dart';
import 'package:tipo/login.dart';
import 'package:tipo/musica_lobby.dart';
import 'package:tipo/registro.dart';
import 'package:tipo/sesion_usuario.dart';
import 'package:tipo/tema_app.dart';

void main() {
  group('MainApp y ValoresInicialesPage Tests', () {
    testWidgets(
      'Montaje inicial muestra interfaz base y botón Inicio deshabilitado',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MainApp(sesionUsuario: SesionUsuario.activa()),
        );
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
        await tester.pumpWidget(
          MainApp(sesionUsuario: SesionUsuario.activa()),
        );
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

    testWidgets(
      'al iniciar sin sesión pide primero iniciar sesión o crear cuenta antes de mostrar Jugar y Multijugador',
      (WidgetTester tester) async {
        await tester.pumpWidget(MainApp(sesionUsuario: SesionUsuario()));

        // La primera pantalla es LoginPage y no muestra Jugar ni Multijugador
        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.byKey(const ValueKey('jugar')), findsNothing);
        expect(find.byKey(const ValueKey('multijugador')), findsNothing);
        expect(find.text('Nombre de usuario'), findsOneWidget);
        expect(find.text('Contraseña'), findsOneWidget);
        expect(find.text('¿No tienes cuenta? Crea tu cuenta'), findsOneWidget);

        // Puede ir a crear cuenta y volver al login
        await tester.tap(find.byKey(const ValueKey('login-crear-cuenta')));
        await tester.pumpAndSettle();
        expect(find.byType(RegistroPage), findsOneWidget);
        expect(find.text('Nombre de usuario'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('registro-volver')));
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
      },
    );

    testWidgets(
      'con sesión activa permite acceder a Jugar en solitario y Multijugador',
      (WidgetTester tester) async {
        final session = _FakeSesionUsuario();
        await tester.pumpWidget(MainApp(sesionUsuario: session));

        expect(find.byKey(const ValueKey('jugar')), findsOneWidget);
        expect(find.byKey(const ValueKey('multijugador')), findsOneWidget);
        expect(find.byKey(const ValueKey('perfil-usuario')), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('jugar')));
        await tester.pumpAndSettle();
        expect(find.byType(SeleccionNivelPage), findsOneWidget);
      },
    );

    testWidgets('niveles permite regresar al inicio y el botón Salir del juego está en la pantalla inicial', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MainApp(sesionUsuario: SesionUsuario.activa()),
      );

      // En la pantalla de inicio aparecen Jugar, Multijugador y Salir del juego
      expect(find.byKey(const ValueKey('jugar')), findsOneWidget);
      expect(find.byKey(const ValueKey('multijugador')), findsOneWidget);
      expect(find.byKey(const ValueKey('cerrar-aplicacion')), findsOneWidget);
      expect(find.text('Salir del juego'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('jugar')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('volver-inicio')), findsOneWidget);
      expect(find.byKey(const ValueKey('cerrar-aplicacion')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('volver-inicio')));
      await tester.pumpAndSettle();

      expect(find.byType(MenuPage), findsOneWidget);
      expect(find.text('Jugar'), findsOneWidget);
      expect(find.byKey(const ValueKey('cerrar-aplicacion')), findsOneWidget);
      expect(find.byKey(const ValueKey('perfil-usuario')), findsOneWidget);
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

      expect(find.byKey(const ValueKey('perfil-usuario')), findsOneWidget);
      expect(find.text('jugador'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('perfil-usuario')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('cerrar-sesion')), findsOneWidget);
      expect(find.byKey(const ValueKey('eliminar-cuenta')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('eliminar-cuenta')));
      await tester.pumpAndSettle();
      expect(find.text('¿Eliminar cuenta?'), findsOneWidget);
      expect(find.textContaining('No se puede deshacer.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('cancelar-eliminar-cuenta')));
      await tester.pumpAndSettle();

      expect(authService.deletedToken, isNull);
      expect(session.activa, isTrue);
      expect(find.byKey(const ValueKey('perfil-usuario')), findsOneWidget);
    });

    testWidgets('confirmar elimina la cuenta y regresa a la pantalla de inicio de sesión', (
      WidgetTester tester,
    ) async {
      final session = _FakeSesionUsuario();
      final authService = _FakeAuthService();
      await tester.pumpWidget(
        MaterialApp(
          home: MenuPage(sesionUsuario: session, authService: authService),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('perfil-usuario')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('eliminar-cuenta')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirmar-eliminar-cuenta')));
      await tester.pumpAndSettle();

      expect(authService.deletedToken, 'test-session-token');
      expect(session.activa, isFalse);
      expect(find.text('La cuenta se eliminó correctamente.'), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byKey(const ValueKey('jugar')), findsNothing);
    });

    testWidgets('permite cambiar entre el tema oscuro y el tema claro 60-30-10 desde el botón desplegable Temas', (
      WidgetTester tester,
    ) async {
      ControladorTema.instance.seleccionar(IdTemaApp.aceroElectrico);
      await tester.pumpWidget(
        MainApp(sesionUsuario: SesionUsuario.activa()),
      );

      expect(ControladorTema.instance.actual.id, IdTemaApp.aceroElectrico);
      expect(find.byKey(const ValueKey('selector-tema')), findsOneWidget);
      expect(find.text('Temas'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('selector-tema')));
      await tester.pumpAndSettle();

      expect(find.text('Acero Eléctrico (Oscuro)'), findsOneWidget);
      expect(find.text('Perla & Cobalto (Claro)'), findsOneWidget);
      expect(find.text('Café & Crema (Ámbar)'), findsOneWidget);
      expect(find.text('Bosque & Esmeralda'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('tema-perlaCobalto')));
      await tester.pumpAndSettle();

      expect(ControladorTema.instance.actual.id, IdTemaApp.perlaCobalto);
      expect(ControladorTema.instance.actual.esOscuro, isFalse);

      await tester.tap(find.byKey(const ValueKey('selector-tema')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tema-cafeCrema')));
      await tester.pumpAndSettle();

      expect(ControladorTema.instance.actual.id, IdTemaApp.cafeCrema);

      await tester.tap(find.byKey(const ValueKey('selector-tema')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tema-bosqueEsmeralda')));
      await tester.pumpAndSettle();

      expect(ControladorTema.instance.actual.id, IdTemaApp.bosqueEsmeralda);

      // Volver al tema oscuro por defecto
      ControladorTema.instance.seleccionar(IdTemaApp.aceroElectrico);
    });

    testWidgets('la música del lobby suena en Menú pero se apaga en Login, Registro y al entrar a jugar', (
      WidgetTester tester,
    ) async {
      final servicioMusica = MusicaLobbyService.instance;
      servicioMusica.reiniciarParaPruebas();
      final rutaWav = servicioMusica.asegurarArchivoAudioGenerado();
      expect(rutaWav, isNotNull);

      // 1. Sin sesión activa (en LoginPage): la música NO debe sonar
      await tester.pumpWidget(MainApp(sesionUsuario: SesionUsuario()));
      expect(find.byType(LoginPage), findsOneWidget);
      expect(servicioMusica.debeSonar, isFalse);

      // En RegistroPage tampoco debe sonar
      await tester.tap(find.byKey(const ValueKey('login-crear-cuenta')));
      await tester.pumpAndSettle();
      expect(find.byType(RegistroPage), findsOneWidget);
      expect(servicioMusica.debeSonar, isFalse);

      await tester.tap(find.byKey(const ValueKey('registro-volver')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(servicioMusica.debeSonar, isFalse);

      // 2. Con sesión activa (en MenuPage): la música SÍ debe sonar
      servicioMusica.reiniciarParaPruebas();
      await tester.pumpWidget(
        MainApp(key: UniqueKey(), sesionUsuario: SesionUsuario.activa()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
      expect(servicioMusica.debeSonar, isTrue);

      // 3. El botón de música permite silenciar y reactivar
      expect(find.byKey(const ValueKey('boton-musica-lobby')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('boton-musica-lobby')));
      await tester.pumpAndSettle();
      expect(servicioMusica.silenciado, isTrue);
      expect(servicioMusica.debeSonar, isFalse);

      await tester.tap(find.byKey(const ValueKey('boton-musica-lobby')));
      await tester.pumpAndSettle();
      expect(servicioMusica.silenciado, isFalse);
      expect(servicioMusica.debeSonar, isTrue);

      // 4. Al entrar a Selección de Nivel y Partida en solitario, la música continúa sonando
      await tester.tap(find.byKey(const ValueKey('jugar')));
      await tester.pumpAndSettle();
      expect(find.byType(SeleccionNivelPage), findsOneWidget);
      expect(servicioMusica.debeSonar, isTrue);

      // 5. En Selección de Nivel aparece el botón de Reglas del juego y abre el diálogo explicativo
      expect(find.byKey(const ValueKey('boton-reglas-juego')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('boton-reglas-juego')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('dialogo-reglas-juego')), findsOneWidget);
      expect(find.text('¿Cómo jugar a Brilliant?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('cerrar-reglas-juego')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('dialogo-reglas-juego')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('seleccionar-nivel_1')));
      await tester.pumpAndSettle();
      expect(find.byType(ValoresInicialesPage), findsOneWidget);
      expect(servicioMusica.debeSonar, isTrue);

      // Al regresar al menú principal, sigue sonando
      await tester.tap(find.byKey(const ValueKey('volver-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('volver-inicio')));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
      expect(servicioMusica.debeSonar, isTrue);
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
