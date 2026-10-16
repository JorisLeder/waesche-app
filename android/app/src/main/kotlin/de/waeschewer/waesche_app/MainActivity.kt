package de.waeschewer.waesche_app

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "waeschewer/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "deviceInfo" -> {
                        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val mem = ActivityManager.MemoryInfo()
                        am.getMemoryInfo(mem)
                        val stat = StatFs(filesDir.absolutePath)
                        result.success(
                            mapOf(
                                "model" to "${Build.MANUFACTURER} ${Build.MODEL}",
                                "soc" to (if (Build.VERSION.SDK_INT >= 31) Build.SOC_MODEL else Build.HARDWARE),
                                "sdkInt" to Build.VERSION.SDK_INT,
                                "totalRamBytes" to mem.totalMem,
                                "availRamBytes" to mem.availMem,
                                "lowRamThresholdBytes" to mem.threshold,
                                "lowMemory" to mem.lowMemory,
                                "freeDiskBytes" to stat.availableBytes,
                            )
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
