package com.example.smart_local_notification

import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import java.io.File

class SmartAudioManager(private val context: Context) {
    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private var audioFocusRequest: AudioFocusRequest? = null
    private val handler = Handler(Looper.getMainLooper())
    private var fadeInRunnable: Runnable? = null
    private var fadeOutRunnable: Runnable? = null

    companion object {
        private const val FADE_STEP_DURATION = 100L // milliseconds
        private const val FADE_STEPS = 20
    }

    fun initialize() {
        // Initialize audio focus handling
        setupAudioFocus()
    }

    private fun setupAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(audioAttributes)
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener { focusChange ->
                    handleAudioFocusChange(focusChange)
                }
                .build()
        }
    }

    private fun handleAudioFocusChange(focusChange: Int) {
        when (focusChange) {
            AudioManager.AUDIOFOCUS_LOSS -> {
                stopAudio()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                pauseAudio()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                // Lower volume
                mediaPlayer?.setVolume(0.3f, 0.3f)
            }
            AudioManager.AUDIOFOCUS_GAIN -> {
                // Resume normal volume
                resumeAudio()
            }
        }
    }

    fun playAudio(settings: Map<String, Any>) {
        try {
            val audioPath = settings["audioPath"] as? String ?: return
            val sourceType = settings["sourceType"] as? String ?: "asset"
            val loop = settings["loop"] as? Boolean ?: false
            val volume = (settings["volume"] as? Double)?.toFloat() ?: 1.0f
            val fadeInDuration = settings["fadeInDuration"] as? Int
            val fadeOutDuration = settings["fadeOutDuration"] as? Int
            val playInBackground = settings["playInBackground"] as? Boolean ?: true

            // Debug logging
            android.util.Log.d("SmartAudioManager", "Playing audio: path=$audioPath, sourceType=$sourceType, loop=$loop, volume=$volume")

            // Stop any currently playing audio
            stopAudio()

            // Request audio focus
            requestAudioFocus()

            // Create MediaPlayer
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )

                // Set data source based on type
                when (sourceType) {
                    "asset" -> {
                        // Normalize asset path - remove 'assets/' prefix if present
                        val normalizedPath = if (audioPath.startsWith("assets/")) {
                            audioPath.substring(7) // Remove 'assets/' prefix
                        } else {
                            audioPath
                        }

                        android.util.Log.d("SmartAudioManager", "Normalized asset path: $normalizedPath")

                        try {
                            val assetFileDescriptor = context.assets.openFd(normalizedPath)
                            setDataSource(
                                assetFileDescriptor.fileDescriptor,
                                assetFileDescriptor.startOffset,
                                assetFileDescriptor.length
                            )
                            assetFileDescriptor.close()
                            android.util.Log.d("SmartAudioManager", "Successfully loaded asset: $normalizedPath")
                        } catch (e: Exception) {
                            android.util.Log.w("SmartAudioManager", "Failed to load asset '$normalizedPath', trying with audio/ prefix: ${e.message}")
                            // If the normalized path fails, try with 'audio/' prefix
                            val audioPathWithPrefix = if (normalizedPath.startsWith("audio/")) {
                                normalizedPath
                            } else {
                                "audio/$normalizedPath"
                            }
                            android.util.Log.d("SmartAudioManager", "Trying asset path with prefix: $audioPathWithPrefix")
                            val assetFileDescriptor = context.assets.openFd(audioPathWithPrefix)
                            setDataSource(
                                assetFileDescriptor.fileDescriptor,
                                assetFileDescriptor.startOffset,
                                assetFileDescriptor.length
                            )
                            assetFileDescriptor.close()
                            android.util.Log.d("SmartAudioManager", "Successfully loaded asset with prefix: $audioPathWithPrefix")
                        }
                    }
                    "file" -> {
                        val file = File(audioPath)
                        if (file.exists()) {
                            setDataSource(audioPath)
                        } else {
                            throw IllegalArgumentException("Audio file not found: $audioPath")
                        }
                    }
                    "url" -> {
                        setDataSource(context, Uri.parse(audioPath))
                    }
                }

                isLooping = loop
                setVolume(if (fadeInDuration != null) 0f else volume, if (fadeInDuration != null) 0f else volume)

                setOnPreparedListener { player ->
                    player.start()
                    
                    // Start fade in if specified
                    if (fadeInDuration != null && fadeInDuration > 0) {
                        startFadeIn(volume, fadeInDuration)
                    }

                    // Start foreground service for background playback
                    if (playInBackground) {
                        startAudioService()
                    }
                }

                setOnCompletionListener { player ->
                    // Handle fade out if specified and not looping
                    if (fadeOutDuration != null && fadeOutDuration > 0 && !loop) {
                        startFadeOut(fadeOutDuration) {
                            stopAudio()
                        }
                    } else if (!loop) {
                        stopAudio()
                    }
                }

                setOnErrorListener { _, what, extra ->
                    stopAudio()
                    true
                }

                prepareAsync()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            stopAudio()
        }
    }

    private fun startFadeIn(targetVolume: Float, duration: Int) {
        cancelFadeRunnables()
        val stepVolume = targetVolume / FADE_STEPS
        val stepDuration = duration / FADE_STEPS
        var currentStep = 0

        fadeInRunnable = object : Runnable {
            override fun run() {
                if (currentStep < FADE_STEPS && mediaPlayer != null) {
                    val volume = stepVolume * currentStep
                    mediaPlayer?.setVolume(volume, volume)
                    currentStep++
                    handler.postDelayed(this, stepDuration.toLong())
                } else {
                    mediaPlayer?.setVolume(targetVolume, targetVolume)
                }
            }
        }
        handler.post(fadeInRunnable!!)
    }

    private fun startFadeOut(duration: Int, onComplete: () -> Unit) {
        cancelFadeRunnables()
        val currentVolume = 1.0f // Assume current volume is max
        val stepVolume = currentVolume / FADE_STEPS
        val stepDuration = duration / FADE_STEPS
        var currentStep = FADE_STEPS

        fadeOutRunnable = object : Runnable {
            override fun run() {
                if (currentStep > 0 && mediaPlayer != null) {
                    val volume = stepVolume * currentStep
                    mediaPlayer?.setVolume(volume, volume)
                    currentStep--
                    handler.postDelayed(this, stepDuration.toLong())
                } else {
                    onComplete()
                }
            }
        }
        handler.post(fadeOutRunnable!!)
    }

    private fun cancelFadeRunnables() {
        fadeInRunnable?.let { handler.removeCallbacks(it) }
        fadeOutRunnable?.let { handler.removeCallbacks(it) }
        fadeInRunnable = null
        fadeOutRunnable = null
    }

    private fun requestAudioFocus(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { request ->
                audioManager.requestAudioFocus(request) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
            } ?: false
        } else {
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                { focusChange -> handleAudioFocusChange(focusChange) },
                AudioManager.STREAM_NOTIFICATION,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
            ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
    }

    private fun abandonAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { request ->
                audioManager.abandonAudioFocusRequest(request)
            }
        } else {
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus { focusChange -> handleAudioFocusChange(focusChange) }
        }
    }

    private fun startAudioService() {
        val intent = Intent(context, AudioPlaybackService::class.java).apply {
            putExtra("action", "start_audio")
            putExtra("audio_path", mediaPlayer?.let { "current_audio" } ?: "")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    private fun stopAudioService() {
        val intent = Intent(context, AudioPlaybackService::class.java)
        context.stopService(intent)
    }

    fun stopAudio() {
        cancelFadeRunnables()
        mediaPlayer?.let { player ->
            if (player.isPlaying) {
                player.stop()
            }
            player.release()
        }
        mediaPlayer = null
        abandonAudioFocus()
        stopAudioService()
    }

    private fun pauseAudio() {
        mediaPlayer?.let { player ->
            if (player.isPlaying) {
                player.pause()
            }
        }
    }

    private fun resumeAudio() {
        mediaPlayer?.let { player ->
            if (!player.isPlaying) {
                player.start()
            }
            // Restore normal volume
            player.setVolume(1.0f, 1.0f)
        }
    }

    fun isPlaying(): Boolean {
        return mediaPlayer?.isPlaying ?: false
    }

    fun cleanup() {
        stopAudio()
    }
}
