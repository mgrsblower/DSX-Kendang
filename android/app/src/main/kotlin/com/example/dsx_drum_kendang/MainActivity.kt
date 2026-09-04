package com.example.dsx_drum_kendang

import android.content.res.AssetFileDescriptor
import android.media.AudioAttributes
import android.media.SoundPool
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mgr.dsx_drum_kendang/audio"
    private var soundPool: SoundPool? = null
    private val pathToSoundId = HashMap<String, Int>()
    private val loadedSoundIds = HashSet<Int>()
    private val pendingPreloads = ArrayList<PendingPreload>()

    private data class PendingPreload(
        val soundIds: MutableSet<Int>,
        val result: MethodChannel.Result,
        var failed: Boolean = false,
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initSoundPool()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "preload" -> {
                    val paths = call.argument<List<String>>("paths")
                    if (paths != null) {
                        preloadSounds(paths, result)
                    } else {
                        result.error("INVALID_ARGS", "Paths are required", null)
                    }
                }
                "play" -> {
                    val path = call.argument<String>("path")
                    val volume = (call.argument<Double>("volume") ?: 1.0).toFloat().coerceIn(0.0f, 1.0f)
                    if (path != null) {
                        val soundId = pathToSoundId[path]
                        if (soundId != null && loadedSoundIds.contains(soundId)) {
                            soundPool?.play(soundId, volume, volume, 1, 0, 1.0f)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Path is required", null)
                    }
                }
                "release" -> {
                    releaseSoundPool()
                    initSoundPool()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initSoundPool() {
        if (soundPool != null) return
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        soundPool = SoundPool.Builder()
            .setMaxStreams(16)
            .setAudioAttributes(audioAttributes)
            .build()
        soundPool?.setOnLoadCompleteListener { _, sampleId, status ->
            if (status == 0) {
                loadedSoundIds.add(sampleId)
            }
            val iterator = pendingPreloads.iterator()
            while (iterator.hasNext()) {
                val pending = iterator.next()
                if (status != 0) {
                    pending.failed = true
                }
                pending.soundIds.remove(sampleId)
                if (pending.soundIds.isEmpty()) {
                    pending.result.success(!pending.failed)
                    iterator.remove()
                }
            }
        }
    }

    private fun preloadSounds(paths: List<String>, result: MethodChannel.Result) {
        val pendingIds = HashSet<Int>()
        var failed = false
        for (path in paths.toSet()) {
            val soundId = pathToSoundId[path] ?: loadSound(path)
            if (soundId == null || soundId <= 0) {
                failed = true
            } else if (!loadedSoundIds.contains(soundId)) {
                pendingIds.add(soundId)
            }
        }
        if (pendingIds.isEmpty()) {
            result.success(!failed)
        } else {
            pendingPreloads.add(PendingPreload(pendingIds, result, failed))
        }
    }

    private fun loadSound(path: String): Int? {
        if (pathToSoundId.containsKey(path)) {
            return pathToSoundId[path]
        }
        val pool = soundPool ?: return null
        var soundId: Int = -1
        try {
            if (path.startsWith("assets/")) {
                val assetKey = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(path)
                try {
                    val afd: AssetFileDescriptor = context.assets.openFd(assetKey)
                    soundId = pool.load(afd, 1)
                } catch (_: Exception) {
                    val cacheFile = File(context.cacheDir, "mgr_audio_" + path.replace("/", "_"))
                    if (!cacheFile.exists()) {
                        context.assets.open(assetKey).use { input ->
                            FileOutputStream(cacheFile).use { output ->
                                input.copyTo(output)
                            }
                        }
                    }
                    soundId = pool.load(cacheFile.absolutePath, 1)
                }
            } else {
                val file = File(path)
                if (file.exists()) {
                    soundId = pool.load(file.absolutePath, 1)
                }
            }
            if (soundId > 0) {
                pathToSoundId[path] = soundId
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return if (soundId > 0) soundId else null
    }

    private fun releaseSoundPool() {
        pendingPreloads.clear()
        soundPool?.release()
        soundPool = null
        pathToSoundId.clear()
        loadedSoundIds.clear()
    }

    override fun onDestroy() {
        releaseSoundPool()
        super.onDestroy()
    }
}
