import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tipo/tema_app.dart';

typedef _PlaySoundNative = ffi.Int32 Function(
  ffi.Pointer<ffi.Uint16> pszSound,
  ffi.IntPtr hmod,
  ffi.Uint32 fdwSound,
);
typedef _PlaySoundDart = int Function(
  ffi.Pointer<ffi.Uint16> pszSound,
  int hmod,
  int fdwSound,
);

typedef _MciSendStringNative = ffi.Uint32 Function(
  ffi.Pointer<ffi.Uint16> lpszCommand,
  ffi.Pointer<ffi.Uint16> lpszReturnString,
  ffi.Uint32 cchReturn,
  ffi.IntPtr hwndCallback,
);
typedef _MciSendStringDart = int Function(
  ffi.Pointer<ffi.Uint16> lpszCommand,
  ffi.Pointer<ffi.Uint16> lpszReturnString,
  int cchReturn,
  int hwndCallback,
);

/// Generador procedural de una pista musical estilo "Chill Puzzle Game / Elevator Bossa Lounge"
/// en formato WAV PCM de 16 bits (16 segundos, 90 BPM, bucle perfecto sin cortes).
class GeneradorAudioChillLobby {
  static const int sampleRate = 22050;
  static const double duracionSegundos = 16.0;

  // Frecuencias de notas musicales (Hz)
  static const double _c2 = 65.41;
  static const double _d2 = 73.42;
  static const double _e2 = 82.41;
  static const double _f2 = 87.31;
  static const double _g2 = 98.00;
  static const double _a2 = 110.00;
  static const double _b2 = 123.47;
  static const double _c3 = 130.81;

  static const double _f3 = 174.61;
  static const double _g3 = 196.00;
  static const double _a3 = 220.00;
  static const double _bb3 = 233.08;
  static const double _b3 = 246.94;
  static const double _c4 = 261.63;
  static const double _d4 = 293.66;
  static const double _e4 = 329.63;
  static const double _f4 = 349.23;
  static const double _g4 = 392.00;
  static const double _a4 = 440.00;
  static const double _c5 = 523.25;
  static const double _d5 = 587.33;
  static const double _e5 = 659.25;
  static const double _f5 = 698.46;
  static const double _g5 = 783.99;

  /// Genera los bytes de un archivo `.wav` con progresión Fmaj7 - Em7 - Dm7 - C9sus4.
  static Uint8List generarWavBytes() {
    final totalSamples = (sampleRate * duracionSegundos).round();
    final pcm = Float64List(totalSamples);

    // 4 compases de 4 segundos cada uno (90 BPM -> 1 pulso = 0.6667 s, 1 compás = 2.6667 s o 4.0 s en 60 BPM chill)
    // Usamos 4 compases de 4.0 segundos (tempo lounge relajado de 60-120 BPM).
    const acordes = <List<double>>[
      [_f3, _a3, _c4, _e4], // Compás 1: Fmaj7
      [_e4 * 0.5, _g3, _b3, _d4], // Compás 2: Em7
      [_d4 * 0.5, _f3, _a3, _c4], // Compás 3: Dm7
      [_g3, _bb3, _d4, _e4], // Compás 4: C9
    ];

    const bajos = <List<double>>[
      [_f2, _c3],
      [_e2, _b2],
      [_d2, _a2],
      [_c2, _g2],
    ];

    // Patrón rítmico Bossa Nova / Lounge para el piano eléctrico Rhodes (en segundos dentro de cada compás de 4s)
    const golpesAcorde = <({double inicio, double duracion, double ganancia})>[
      (inicio: 0.0, duracion: 1.35, ganancia: 1.0),
      (inicio: 1.5, duracion: 0.90, ganancia: 0.82),
      (inicio: 2.5, duracion: 0.70, ganancia: 0.78),
      (inicio: 3.25, duracion: 0.72, ganancia: 0.85),
    ];

    // Melodía suave estilo videojuego de puzles / elevador
    const notasMelodia = <({double inicio, double duracion, double freq})>[
      // Compás 1 (Fmaj7)
      (inicio: 0.5, duracion: 0.9, freq: _c5),
      (inicio: 1.5, duracion: 0.9, freq: _a4),
      (inicio: 2.5, duracion: 1.3, freq: _e5),
      // Compás 2 (Em7)
      (inicio: 4.5, duracion: 0.9, freq: _d5),
      (inicio: 5.5, duracion: 0.9, freq: _g4),
      (inicio: 6.5, duracion: 1.3, freq: _e5),
      // Compás 3 (Dm7)
      (inicio: 8.5, duracion: 0.75, freq: _f5),
      (inicio: 9.25, duracion: 0.75, freq: _e5),
      (inicio: 10.0, duracion: 0.9, freq: _c5),
      (inicio: 11.0, duracion: 0.9, freq: _a4),
      // Compás 4 (C9)
      (inicio: 12.25, duracion: 0.95, freq: _d5),
      (inicio: 13.25, duracion: 0.95, freq: _e5),
      (inicio: 14.25, duracion: 1.5, freq: _g5),
    ];

    // 1. Sintetizar acordes de piano eléctrico Rhodes y bajo suave
    for (var compas = 0; compas < 4; compas++) {
      final offsetCompas = compas * 4.0;
      final acorde = acordes[compas];
      final bajo = bajos[compas];

      for (final golpe in golpesAcorde) {
        _mezclarAcordeRhodes(
          pcm,
          inicioSeg: offsetCompas + golpe.inicio,
          duracionSeg: golpe.duracion,
          frecuencias: acorde,
          volumen: 0.055 * golpe.ganancia,
        );
      }

      // Bajo Bossa Nova (pulsos en 0.0, 1.5, 2.0, 3.5)
      _mezclarNotaBajo(
        pcm,
        inicioSeg: offsetCompas + 0.0,
        duracionSeg: 1.4,
        freq: bajo[0],
        volumen: 0.11,
      );
      _mezclarNotaBajo(
        pcm,
        inicioSeg: offsetCompas + 1.5,
        duracionSeg: 0.48,
        freq: bajo[1],
        volumen: 0.085,
      );
      _mezclarNotaBajo(
        pcm,
        inicioSeg: offsetCompas + 2.0,
        duracionSeg: 1.4,
        freq: bajo[0],
        volumen: 0.105,
      );
      _mezclarNotaBajo(
        pcm,
        inicioSeg: offsetCompas + 3.5,
        duracionSeg: 0.48,
        freq: bajo[1],
        volumen: 0.085,
      );
    }

    // 2. Sintetizar melodía principal tipo vibráfono / marimba suave
    for (final nota in notasMelodia) {
      _mezclarNotaVibraphono(
        pcm,
        inicioSeg: nota.inicio,
        duracionSeg: nota.duracion,
        freq: nota.freq,
        volumen: 0.065,
      );
    }

    // 3. Shaker / escobilla suave de jazz cada 0.5 s
    final rng = math.Random(42);
    for (var paso = 0; paso < 32; paso++) {
      final inicio = paso * 0.5;
      final acentuado = paso % 4 == 2;
      _mezclarEscobillaSuave(
        pcm,
        rng: rng,
        inicioSeg: inicio,
        duracionSeg: 0.07,
        volumen: acentuado ? 0.015 : 0.008,
      );
    }

    // 4. Suavizado de bordes (fade-in/fade-out de 15 ms) para que el loop sea imperceptible
    final fadeSamples = (sampleRate * 0.015).round();
    for (var i = 0; i < fadeSamples && i < totalSamples; i++) {
      final factor = i / fadeSamples;
      pcm[i] *= factor;
      pcm[totalSamples - 1 - i] *= factor;
    }

    return _empaquetarWav16Bit(pcm);
  }

  static void _mezclarAcordeRhodes(
    Float64List pcm, {
    required double inicioSeg,
    required double duracionSeg,
    required List<double> frecuencias,
    required double volumen,
  }) {
    final start = (inicioSeg * sampleRate).round();
    final length = (duracionSeg * sampleRate).round();
    final attack = (0.018 * sampleRate).round();
    final release = (0.12 * sampleRate).round();

    for (var i = 0; i < length; i++) {
      final idx = start + i;
      if (idx < 0 || idx >= pcm.length) continue;
      final t = i / sampleRate;

      var env = math.exp(-1.6 * t);
      if (i < attack) {
        env *= i / attack;
      } else if (i > length - release) {
        env *= (length - i) / release;
      }

      // Efecto trémolo suave tipo Rhodes (4.5 Hz)
      final tremolo = 1.0 + 0.08 * math.sin(2 * math.pi * 4.5 * t);

      var suma = 0.0;
      for (final f in frecuencias) {
        final w = 2 * math.pi * f * t;
        final fundamental = math.sin(w);
        final armonico2 = 0.18 * math.sin(2 * w) * math.exp(-3.0 * t);
        final campana = 0.04 * math.sin(4 * w) * math.exp(-14.0 * t);
        suma += fundamental + armonico2 + campana;
      }
      pcm[idx] += suma * env * tremolo * volumen;
    }
  }

  static void _mezclarNotaBajo(
    Float64List pcm, {
    required double inicioSeg,
    required double duracionSeg,
    required double freq,
    required double volumen,
  }) {
    final start = (inicioSeg * sampleRate).round();
    final length = (duracionSeg * sampleRate).round();
    final attack = (0.015 * sampleRate).round();
    final release = (0.08 * sampleRate).round();

    for (var i = 0; i < length; i++) {
      final idx = start + i;
      if (idx < 0 || idx >= pcm.length) continue;
      final t = i / sampleRate;

      var env = math.exp(-2.1 * t);
      if (i < attack) {
        env *= i / attack;
      } else if (i > length - release) {
        env *= (length - i) / release;
      }

      final w = 2 * math.pi * freq * t;
      final muestra = math.sin(w) + 0.25 * math.sin(2 * w) * math.exp(-4.0 * t);
      pcm[idx] += muestra * env * volumen;
    }
  }

  static void _mezclarNotaVibraphono(
    Float64List pcm, {
    required double inicioSeg,
    required double duracionSeg,
    required double freq,
    required double volumen,
  }) {
    final start = (inicioSeg * sampleRate).round();
    final length = (duracionSeg * sampleRate).round();
    final attack = (0.012 * sampleRate).round();
    final release = (0.10 * sampleRate).round();

    for (var i = 0; i < length; i++) {
      final idx = start + i;
      if (idx < 0 || idx >= pcm.length) continue;
      final t = i / sampleRate;

      var env = math.exp(-2.4 * t);
      if (i < attack) {
        env *= i / attack;
      } else if (i > length - release) {
        env *= (length - i) / release;
      }

      final vibrato = 1.0 + 0.10 * math.sin(2 * math.pi * 5.5 * t);
      final w = 2 * math.pi * freq * t;
      final muestra =
          math.sin(w) + 0.12 * math.sin(3 * w) * math.exp(-10.0 * t);
      pcm[idx] += muestra * env * vibrato * volumen;
    }
  }

  static void _mezclarEscobillaSuave(
    Float64List pcm, {
    required math.Random rng,
    required double inicioSeg,
    required double duracionSeg,
    required double volumen,
  }) {
    final start = (inicioSeg * sampleRate).round();
    final length = (duracionSeg * sampleRate).round();
    var filtro = 0.0;

    for (var i = 0; i < length; i++) {
      final idx = start + i;
      if (idx < 0 || idx >= pcm.length) continue;
      final progreso = i / length;
      final env = math.sin(math.pi * progreso) * math.exp(-3.5 * progreso);
      final ruido = rng.nextDouble() * 2.0 - 1.0;
      filtro = 0.75 * filtro + 0.25 * ruido;
      pcm[idx] += filtro * env * volumen;
    }
  }

  static Uint8List _empaquetarWav16Bit(Float64List pcm) {
    final numSamples = pcm.length;
    final dataSize = numSamples * 2;
    final fileSize = 36 + dataSize;
    final buffer = ByteData(44 + dataSize);

    // Cabecera RIFF/WAVE
    const riff = [0x52, 0x49, 0x46, 0x46]; // "RIFF"
    const wave = [0x57, 0x41, 0x56, 0x45]; // "WAVE"
    const fmt = [0x66, 0x6D, 0x74, 0x20]; // "fmt "
    const data = [0x64, 0x61, 0x74, 0x61]; // "data"

    for (var i = 0; i < 4; i++) {
      buffer.setUint8(i, riff[i]);
      buffer.setUint8(8 + i, wave[i]);
      buffer.setUint8(12 + i, fmt[i]);
      buffer.setUint8(36 + i, data[i]);
    }
    buffer.setUint32(4, fileSize, Endian.little);
    buffer.setUint32(16, 16, Endian.little); // PCM chunk size
    buffer.setUint16(20, 1, Endian.little); // AudioFormat = 1 (PCM)
    buffer.setUint16(22, 1, Endian.little); // NumChannels = 1 (Mono)
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    buffer.setUint16(32, 2, Endian.little); // BlockAlign
    buffer.setUint16(34, 16, Endian.little); // BitsPerSample
    buffer.setUint32(40, dataSize, Endian.little);

    var offset = 44;
    for (var i = 0; i < numSamples; i++) {
      final clamped = pcm[i].clamp(-0.95, 0.95);
      final sample16 = (clamped * 32767).round();
      buffer.setInt16(offset, sample16, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }
}

/// Servicio que controla la música de fondo del Menú Principal, Lobby y Sala de Espera.
/// Se detiene automáticamente en Login, Registro y al iniciar una partida.
class MusicaLobbyService extends ChangeNotifier {
  MusicaLobbyService._();

  static final MusicaLobbyService instance = MusicaLobbyService._();

  final Set<Object> _pantallasLobbyActivas = <Object>{};
  final Set<Object> _pantallasSilenciadasEncima = <Object>{};

  bool _silenciadoPorUsuario = false;
  bool _reproduciendo = false;
  bool _usandoMciMp3 = false;
  String? _rutaAudioPreparada;

  _PlaySoundDart? _playSoundW;
  _MciSendStringDart? _mciSendStringW;
  ffi.Pointer<ffi.Void> Function(int, int)? _callocWin;
  void Function(ffi.Pointer<ffi.Void>)? _freeWin;
  bool _ffiInicializado = false;

  static const MethodChannel _canalAndroid = MethodChannel(
    'brilliant/audio_lobby',
  );

  bool get silenciado => _silenciadoPorUsuario;
  bool get reproduciendo => _reproduciendo;
  bool get debeSonar =>
      !_silenciadoPorUsuario &&
      _pantallasLobbyActivas.isNotEmpty &&
      _pantallasSilenciadasEncima.isEmpty;

  void registrarPantallaLobby(Object token) {
    _pantallasLobbyActivas.add(token);
    _actualizarEstadoAudio();
  }

  void retirarPantallaLobby(Object token) {
    _pantallasLobbyActivas.remove(token);
    _actualizarEstadoAudio();
  }

  void registrarPantallaSinMusica(Object token) {
    _pantallasSilenciadasEncima.add(token);
    _actualizarEstadoAudio();
  }

  void retirarPantallaSinMusica(Object token) {
    _pantallasSilenciadasEncima.remove(token);
    _actualizarEstadoAudio();
  }

  void alternarSilencio() {
    _silenciadoPorUsuario = !_silenciadoPorUsuario;
    _actualizarEstadoAudio();
    notifyListeners();
  }

  /// Garantiza que la carpeta `assets/audio/` y el archivo `lobby_chill.wav` existan en disco.
  String? asegurarArchivoAudioGenerado() => _prepararArchivoAudio();

  /// Detiene inmediatamente cualquier reproducción activa antes de cerrar la aplicación.
  Future<void> detenerTodo() async {
    _pantallasLobbyActivas.clear();
    _reproduciendo = false;
    if (!_enEntornoDePruebas) {
      await _detenerAudioMultiplataforma();
    }
  }

  void reiniciarParaPruebas() {
    _pantallasLobbyActivas.clear();
    _pantallasSilenciadasEncima.clear();
    _silenciadoPorUsuario = false;
    _reproduciendo = false;
  }

  bool get _enEntornoDePruebas {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return true;
    }
  }

  void _actualizarEstadoAudio() {
    final activar = debeSonar;
    if (activar == _reproduciendo) return;
    _reproduciendo = activar;
    if (_enEntornoDePruebas) return;

    if (activar) {
      unawaited(_iniciarAudioMultiplataforma());
    } else {
      unawaited(_detenerAudioMultiplataforma());
    }
  }

  void _inicializarWinMM() {
    if (_ffiInicializado || kIsWeb || !Platform.isWindows) return;
    _ffiInicializado = true;
    try {
      final winmm = ffi.DynamicLibrary.open('winmm.dll');
      _playSoundW = winmm
          .lookupFunction<_PlaySoundNative, _PlaySoundDart>('PlaySoundW');
      _mciSendStringW = winmm
          .lookupFunction<_MciSendStringNative, _MciSendStringDart>(
            'mciSendStringW',
          );
      final msvcrt = ffi.DynamicLibrary.open('msvcrt.dll');
      _callocWin = msvcrt
          .lookupFunction<
            ffi.Pointer<ffi.Void> Function(ffi.IntPtr, ffi.IntPtr),
            ffi.Pointer<ffi.Void> Function(int, int)
          >('calloc');
      _freeWin = msvcrt
          .lookupFunction<
            ffi.Void Function(ffi.Pointer<ffi.Void>),
            void Function(ffi.Pointer<ffi.Void>)
          >('free');
    } catch (_) {}
  }

  String? _prepararArchivoAudio() {
    if (_rutaAudioPreparada != null &&
        File(_rutaAudioPreparada!).existsSync()) {
      return _rutaAudioPreparada;
    }

    try {
      final cwd = Directory.current.path;
      // 1. En desarrollo o junto al ejecutable: busca lobby.mp3, lobby.wav o lobby_chill.wav
      final candidatosLocales = [
        '$cwd${Platform.pathSeparator}assets${Platform.pathSeparator}audio${Platform.pathSeparator}lobby.mp3',
        '$cwd${Platform.pathSeparator}assets${Platform.pathSeparator}audio${Platform.pathSeparator}lobby.wav',
        '$cwd${Platform.pathSeparator}assets${Platform.pathSeparator}audio${Platform.pathSeparator}lobby_chill.wav',
        '$cwd${Platform.pathSeparator}data${Platform.pathSeparator}flutter_assets${Platform.pathSeparator}assets${Platform.pathSeparator}audio${Platform.pathSeparator}lobby.mp3',
        '$cwd${Platform.pathSeparator}data${Platform.pathSeparator}flutter_assets${Platform.pathSeparator}assets${Platform.pathSeparator}audio${Platform.pathSeparator}lobby_chill.wav',
      ];
      for (final ruta in candidatosLocales) {
        final archivo = File(ruta);
        if (archivo.existsSync() && archivo.lengthSync() > 44) {
          _rutaAudioPreparada = archivo.path;
          return _rutaAudioPreparada;
        }
      }

      // 2. Genera el archivo WAV chill (funciona en Windows .exe y en Android .apk en Directory.systemTemp)
      final wavBytes = GeneradorAudioChillLobby.generarWavBytes();
      try {
        if (Platform.isWindows) {
          final dirAssets = Directory(
            '$cwd${Platform.pathSeparator}assets${Platform.pathSeparator}audio',
          );
          if (dirAssets.existsSync()) {
            final archivoAsset = File(
              '${dirAssets.path}${Platform.pathSeparator}lobby_chill.wav',
            );
            archivoAsset.writeAsBytesSync(wavBytes, flush: true);
            _rutaAudioPreparada = archivoAsset.path;
            return _rutaAudioPreparada;
          }
        }
      } catch (_) {}

      final archivoTemp = File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}brilliant_lobby_chill.wav',
      );
      archivoTemp.writeAsBytesSync(wavBytes, flush: true);
      _rutaAudioPreparada = archivoTemp.path;
      return _rutaAudioPreparada;
    } catch (_) {
      return null;
    }
  }

  /// Carga un `.mp3` o `.wav` empaquetado dentro del `.apk` o `.exe` mediante `rootBundle`
  /// o genera la pista chill en `Directory.systemTemp`.
  Future<String?> _prepararArchivoAudioMultiplataforma() async {
    final sincrono = _prepararArchivoAudio();
    if (sincrono != null && sincrono.toLowerCase().endsWith('.mp3')) {
      return sincrono;
    }

    // Intenta extraer assets/audio/lobby.mp3 del bundle empaquetado (útil en APK release)
    for (final nombre in ['lobby.mp3', 'lobby.wav', 'lobby_chill.wav']) {
      try {
        final data = await rootBundle.load('assets/audio/$nombre');
        if (data.lengthInBytes > 44) {
          final bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          final destino = File(
            '${Directory.systemTemp.path}${Platform.pathSeparator}brilliant_$nombre',
          );
          await destino.writeAsBytes(bytes, flush: true);
          _rutaAudioPreparada = destino.path;
          return _rutaAudioPreparada;
        }
      } catch (_) {}
    }

    return sincrono;
  }

  Future<void> _iniciarAudioMultiplataforma() async {
    if (kIsWeb) return;
    final ruta = await _prepararArchivoAudioMultiplataforma();
    if (ruta == null || !_reproduciendo) return;

    if (Platform.isAndroid) {
      try {
        await _canalAndroid.invokeMethod<void>('reproducirLoop', {
          'path': ruta,
        });
      } catch (_) {}
      return;
    }

    if (!Platform.isWindows) return;
    _inicializarWinMM();

    if (ruta.toLowerCase().endsWith('.mp3') && _mciSendStringW != null) {
      _usandoMciMp3 = true;
      _ejecutarMci('close brilliant_lobby');
      _ejecutarMci('open "$ruta" type mpegvideo alias brilliant_lobby');
      _ejecutarMci('setaudio brilliant_lobby volume to 320');
      _ejecutarMci('play brilliant_lobby repeat');
      return;
    }

    _usandoMciMp3 = false;
    final playSound = _playSoundW;
    if (playSound == null) return;
    // SND_ASYNC (0x0001) | SND_NODEFAULT (0x0002) | SND_LOOP (0x0008) | SND_FILENAME (0x00020000)
    const flags = 0x0001 | 0x0002 | 0x0008 | 0x00020000;
    _conUtf16(ruta, (ptr) {
      playSound(ptr, 0, flags);
    });
  }

  Future<void> _detenerAudioMultiplataforma() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      try {
        await _canalAndroid.invokeMethod<void>('detener');
      } catch (_) {}
      return;
    }

    if (!Platform.isWindows) return;
    _inicializarWinMM();
    if (_usandoMciMp3 && _mciSendStringW != null) {
      _ejecutarMci('stop brilliant_lobby');
      _ejecutarMci('close brilliant_lobby');
      _usandoMciMp3 = false;
    }
    final playSound = _playSoundW;
    if (playSound != null) {
      playSound(ffi.nullptr, 0, 0);
    }
  }

  void _ejecutarMci(String comando) {
    final mci = _mciSendStringW;
    if (mci == null) return;
    _conUtf16(comando, (ptr) {
      mci(ptr, ffi.nullptr, 0, 0);
    });
  }

  void _conUtf16(String texto, void Function(ffi.Pointer<ffi.Uint16>) accion) {
    final callocFn = _callocWin;
    final freeFn = _freeWin;
    if (callocFn == null || freeFn == null) return;
    final unidades = texto.codeUnits;
    final ptr = callocFn(unidades.length + 1, 2).cast<ffi.Uint16>();
    for (var i = 0; i < unidades.length; i++) {
      (ptr + i).value = unidades[i];
    }
    (ptr + unidades.length).value = 0;
    try {
      accion(ptr);
    } finally {
      freeFn(ptr.cast<ffi.Void>());
    }
  }
}

/// Envuelve una pantalla para indicar si debe sonar la música de lobby o si debe silenciarse
/// (por ejemplo durante Login, Registro o una partida en curso).
class ZonaMusicaLobby extends StatefulWidget {
  const ZonaMusicaLobby({
    super.key,
    required this.child,
    this.habilitarMusica = true,
  });

  final Widget child;
  final bool habilitarMusica;

  @override
  State<ZonaMusicaLobby> createState() => _ZonaMusicaLobbyState();
}

class _ZonaMusicaLobbyState extends State<ZonaMusicaLobby> {
  final Object _token = Object();

  @override
  void initState() {
    super.initState();
    _sincronizarRegistro();
  }

  @override
  void didUpdateWidget(covariant ZonaMusicaLobby oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habilitarMusica != widget.habilitarMusica) {
      _retirarRegistro();
      _sincronizarRegistro();
    }
  }

  void _sincronizarRegistro() {
    if (widget.habilitarMusica) {
      MusicaLobbyService.instance.registrarPantallaLobby(_token);
    } else {
      MusicaLobbyService.instance.registrarPantallaSinMusica(_token);
    }
  }

  void _retirarRegistro() {
    MusicaLobbyService.instance.retirarPantallaLobby(_token);
    MusicaLobbyService.instance.retirarPantallaSinMusica(_token);
  }

  @override
  void dispose() {
    _retirarRegistro();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Botón para activar o silenciar la música del lobby.
class BotonMusicaLobby extends StatelessWidget {
  const BotonMusicaLobby({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      MusicaLobbyService.instance,
      ControladorTema.instance,
    ]),
    builder: (context, _) {
      final musica = MusicaLobbyService.instance;
      final paleta = ControladorTema.instance.actual;
      final silenciado = musica.silenciado;

      return Tooltip(
        message: silenciado
            ? 'Activar música del lobby'
            : 'Silenciar música del lobby',
        child: Material(
          color: paleta.panelSecundario,
          shape: StadiumBorder(
            side: BorderSide(color: paleta.bordeSecundario, width: 1.4),
          ),
          elevation: 2,
          shadowColor: paleta.sombraPanel,
          child: InkWell(
            key: const ValueKey('boton-musica-lobby'),
            customBorder: const StadiumBorder(),
            onTap: musica.alternarSilencio,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    silenciado
                        ? Icons.volume_off_rounded
                        : Icons.music_note_rounded,
                    size: 18,
                    color: silenciado ? paleta.textoSecundario : paleta.acento,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    silenciado ? 'Silencio' : 'Música',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: silenciado
                          ? paleta.textoSecundario
                          : paleta.textoPrincipal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
