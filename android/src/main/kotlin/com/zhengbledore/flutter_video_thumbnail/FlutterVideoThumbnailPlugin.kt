package com.zhengbledore.flutter_video_thumbnail

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Bitmap.CompressFormat
import android.media.MediaMetadataRetriever
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.math.roundToInt

/** FlutterVideoThumbnailPlugin */
class FlutterVideoThumbnailPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        const val TAG = "VideoThumbnail"
    }

    private lateinit var channel: MethodChannel
    private lateinit var executor: ExecutorService
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        executor = Executors.newCachedThreadPool()
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_video_thumbnail")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        executor.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments<Map<String, Any>>()!!

        val video = args["video"] as String
        val headers = args["headers"] as HashMap<String, String>?
        val format = args["format"] as Int
        val maxH = args["maxh"] as Int
        val maxW = args["maxw"] as Int
        val timeMs = args["timeMs"] as Int
        val quality = args["quality"] as Int
        executor.execute {
            var handled = false
            var thumbnail: Any? = null
            var ex: Exception? = null
            try {
                when (call.method) {
                    "file" -> {
                        val path = args["path"] as String?
                        thumbnail = buildThumbnailFile(
                            video, headers, path, format, maxH, maxW, timeMs, quality
                        )
                        handled = true
                    }
                    "data" -> {
                        thumbnail =
                            buildThumbnailData(video, headers, format, maxH, maxW, timeMs, quality)
                        handled = true
                    }
                    else -> {
                        thumbnail = null
                        handled = false
                    }
                }
            } catch (e: Exception) {
                ex = e
            }
            onResult(result, thumbnail, handled, ex)
        }
    }

    private fun buildThumbnailFile(
        vidPath: String,
        headers: HashMap<String, String>?,
        path: String?,
        format: Int,
        maxH: Int,
        maxW: Int,
        timeMs: Int,
        quality: Int
    ): String? {
        val bytes = buildThumbnailData(
            vidPath, headers, format, maxH, maxW, timeMs, quality
        ) ?: return null
        val ext: String = formatExt(format)
        val i: Int = vidPath.lastIndexOf(".")
        var fullPath: String = vidPath.substring(0, i) + timeMs + "." + ext
        val isLocalFile = vidPath.startsWith("/") || vidPath.startsWith("file://")
        var thumbnailPath = path
        if (thumbnailPath == null && !isLocalFile) {
            thumbnailPath = context.cacheDir.absolutePath
        }
        if (thumbnailPath != null) {
            fullPath = if (thumbnailPath.endsWith(ext)) {
                thumbnailPath
            } else {
                val j = fullPath.lastIndexOf("/")
                if (thumbnailPath.endsWith("/")) {
                    thumbnailPath + fullPath.substring(j + 1)
                } else {
                    thumbnailPath + fullPath.substring(j)
                }
            }
        }

        try {
            val f = FileOutputStream(fullPath)
            f.write(bytes)
            f.close()
            Log.d(
                TAG, String.format("buildThumbnailFile( written:%d )", bytes.size)
            )
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return fullPath
    }

    private fun buildThumbnailData(
        vidPath: String,
        headers: HashMap<String, String>?,
        format: Int,
        maxH: Int,
        maxW: Int,
        timeMs: Int,
        quality: Int
    ): ByteArray? {
        val bitmap: Bitmap? = createVideoThumbnail(vidPath, headers, maxH, maxW, timeMs)
        bitmap?.let {
            val stream = ByteArrayOutputStream()
            it.compress(
                intToFormat(format), quality, stream
            )
            it.recycle()
            return stream.toByteArray()
        }
        return null
    }

    private fun createVideoThumbnail(
        video: String, headers: HashMap<String, String>?, targetH: Int, targetW: Int, timeMs: Int
    ): Bitmap? {
        var bitmap: Bitmap? = null
        val retriever = MediaMetadataRetriever()
        try {
            if (video.startsWith("/")) {
                setDataSource(video, retriever)
            } else if (video.startsWith("file://")) {
                setDataSource(
                    video.substring(7), retriever
                )
            } else {
                retriever.setDataSource(
                    video, headers
                )
            }
            if (targetH != 0 || targetW != 0) {
                if (Build.VERSION.SDK_INT >= 27 && targetH != 0 && targetW != 0) {
                    bitmap = retriever.getScaledFrameAtTime(
                        (timeMs * 1000).toLong(),
                        MediaMetadataRetriever.OPTION_CLOSEST,
                        targetW,
                        targetH
                    )
                } else {
                    bitmap = retriever.getFrameAtTime(
                        (timeMs * 1000).toLong(), MediaMetadataRetriever.OPTION_CLOSEST
                    )
                    if (bitmap != null) {
                        val width = bitmap.width
                        val height = bitmap.height
                        var tarW = targetW
                        if (targetW == 0) {
                            tarW = (targetH.toFloat() / height * width).roundToInt()
                        }
                        var tarH = targetH
                        if (targetH == 0) {
                            tarH = (targetW.toFloat() / width * height).roundToInt()
                        }
                        bitmap = Bitmap.createScaledBitmap(bitmap, tarW, tarH, true)
                    }
                }
            } else {
                bitmap = retriever.getFrameAtTime(
                    (timeMs * 1000).toLong(), MediaMetadataRetriever.OPTION_CLOSEST
                )
            }
        } catch (ex: IllegalArgumentException) {
            ex.printStackTrace()
        } catch (ex: RuntimeException) {
            ex.printStackTrace()
        } catch (ex: IOException) {
            ex.printStackTrace()
        } finally {
            try {
                retriever.release()
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
        return bitmap
    }

    @Throws(IOException::class)
    private fun setDataSource(video: String, retriever: MediaMetadataRetriever) {
        val videoFile = File(video)
        val inputStream = FileInputStream(videoFile.absolutePath)
        retriever.setDataSource(inputStream.fd)
    }

    private fun onResult(
        result: Result, thumbnail: Any?, handled: Boolean, e: java.lang.Exception?
    ) {
        runOnUiThread(Runnable {
            if (!handled) {
                result.notImplemented()
                return@Runnable
            }
            if (e != null) {
                e.printStackTrace()
                result.error("exception", e.message, null)
                return@Runnable
            }
            result.success(thumbnail)
        })
    }

    private fun runOnUiThread(runnable: Runnable) {
        Handler(Looper.getMainLooper()).post(runnable)
    }

    private fun intToFormat(format: Int): CompressFormat {
        return when (format) {
            0 -> CompressFormat.JPEG
            1 -> CompressFormat.PNG
            2 -> CompressFormat.WEBP
            else -> CompressFormat.JPEG
        }
    }

    private fun formatExt(format: Int): String {
        return when (format) {
            0 -> "jpg"
            1 -> "png"
            2 -> "webp"
            else -> "jpg"
        }
    }
}
