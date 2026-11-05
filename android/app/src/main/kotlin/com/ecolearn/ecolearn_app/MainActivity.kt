package com.ecolearn.ecolearn_app

import android.net.TrafficStats
import android.os.Process
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // NEW: lets the Dart PerformanceLogger read how many bytes
    // THIS app has received / sent (Android TrafficStats, per app UID).
    // Used to measure network traffic for Eco vs Normal Mode.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ecolearn/metrics"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getTrafficBytes") {
                val uid = Process.myUid()
                result.success(
                    listOf(
                        TrafficStats.getUidRxBytes(uid),
                        TrafficStats.getUidTxBytes(uid)
                    )
                )
            } else {
                result.notImplemented()
            }
        }
    }
}
