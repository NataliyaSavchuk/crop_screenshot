package com.example.screenshot_cropper

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.media.ImageReader
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.Surface
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    private var lastKeyPressTime: Long = 0

    private val projectionManager by lazy {
        getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
    }

    private var mediaProjectionPermissionResult: Intent? = null

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == RESULT_OK) {
            mediaProjectionPermissionResult = result.data
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        methodChannel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, "screenshot_channel")
        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "captureScreenshot") {
                captureScreenshot(result)
            }
        }

        eventChannel = EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, "screenshot_event_channel")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        // Запрашиваем разрешение на захват экрана
        val intent = projectionManager.createScreenCaptureIntent()
        permissionLauncher.launch(intent)
    }

    override fun dispatchKeyEvent(event: KeyEvent?): Boolean {
        if (event?.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN && event.action == KeyEvent.ACTION_DOWN) {
            val now = System.currentTimeMillis()
            if (now - lastKeyPressTime < 400) {
                eventSink?.success("double_press")
            }
            lastKeyPressTime = now
        }
        return super.dispatchKeyEvent(event)
    }

    private fun captureScreenshot(result: MethodChannel.Result) {
        val permissionData = mediaProjectionPermissionResult ?: run {
            result.error("NO_PERMISSION", "No permission granted for screen capture", null)
            return
        }

        val metrics = resources.displayMetrics
        val imageReader = ImageReader.newInstance(metrics.widthPixels, metrics.heightPixels, PixelFormat.RGBA_8888, 2)
        val mediaProjection = projectionManager.getMediaProjection(RESULT_OK, permissionData)
        mediaProjection?.createVirtualDisplay(
            "ScreenCapture",
            metrics.widthPixels, metrics.heightPixels, metrics.densityDpi,
            0,
            imageReader.surface,
            null,
            Handler(Looper.getMainLooper())
        )

        Handler(Looper.getMainLooper()).postDelayed({
            val image = imageReader.acquireLatestImage()
            if (image != null) {
                val planes = image.planes
                val buffer = planes[0].buffer
                val pixelStride = planes[0].pixelStride
                val rowStride = planes[0].rowStride
                val rowPadding = rowStride - pixelStride * metrics.widthPixels

                val bitmap = Bitmap.createBitmap(
                    metrics.widthPixels + rowPadding / pixelStride,
                    metrics.heightPixels,
                    Bitmap.Config.ARGB_8888
                )
                bitmap.copyPixelsFromBuffer(buffer)
                image.close()

                // Сохраняем временно скриншот
                val file = File(cacheDir, "screenshot_${System.currentTimeMillis()}.png")
                val fos = FileOutputStream(file)
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos)
                fos.flush()
                fos.close()

                result.success(file.absolutePath)
            } else {
                result.error("NO_IMAGE", "Failed to capture screen", null)
            }
        }, 500)
    }
}
