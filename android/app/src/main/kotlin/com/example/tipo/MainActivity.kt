package com.example.tipo

import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val canalAudio = "brilliant/audio_lobby"
    private var mediaPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, canalAudio)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "reproducirLoop" -> {
                        val path = call.argument<String>("path")
                        if (path.isNullOrBlank()) {
                            result.error("INVALID_PATH", "Ruta de audio vacía", null)
                        } else {
                            try {
                                detenerReproductor()
                                mediaPlayer = MediaPlayer().apply {
                                    setDataSource(path)
                                    isLooping = true
                                    setVolume(0.35f, 0.35f)
                                    prepare()
                                    start()
                                }
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("PLAY_ERROR", e.message, null)
                            }
                        }
                    }
                    "detener" -> {
                        detenerReproductor()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun detenerReproductor() {
        try {
            mediaPlayer?.let { player ->
                if (player.isPlaying) {
                    player.stop()
                }
                player.release()
            }
        } catch (_: Exception) {
        } finally {
            mediaPlayer = null
        }
    }

    override fun onDestroy() {
        detenerReproductor()
        super.onDestroy()
    }
}
