package com.tksobhan.v2ray_stk

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "core_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "startCore" -> {
                    val type = call.argument<String>("type") ?: "singbox"
                    val config = call.argument<String>("config") ?: ""

                    Log.d("CORE", "startCore called - type: $type")

                    val intent = Intent(this, CoreService::class.java)
                    intent.putExtra("type", type)
                    intent.putExtra("config", config)

                    startService(intent)

                    result.success("Core Started")
                }

                "stopCore" -> {
                    Log.d("CORE", "stopCore called")
                    stopService(Intent(this, CoreService::class.java))
                    result.success("Core Stopped")
                }

                "switchCore" -> {
                    val type = call.argument<String>("type") ?: "xray"
                    val config = call.argument<String>("config") ?: ""

                    Log.d("CORE", "switchCore called - type: $type")

                    val intent = Intent(this, CoreService::class.java)
                    intent.putExtra("type", type)
                    intent.putExtra("config", config)

                    startService(intent)

                    result.success("Core Switched")
                }

                "getStatus" -> {
                    result.success("OK")
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
