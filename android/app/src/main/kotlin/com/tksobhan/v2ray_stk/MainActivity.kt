package com.tksobhan.v2ray_stk

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.*
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.*

class MainActivity : FlutterActivity() {

    private val CHANNEL = "core_channel"
    private val VPN_REQUEST_CODE = 1001

    companion object {
        var logSink: EventChannel.EventSink? = null
        var trafficSink: EventChannel.EventSink? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= 33) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    1002
                )
            }
        }

        if (intent?.getBooleanExtra("vpn_request", false) == true) {
            VpnService.prepare(this)?.let {
                startActivityForResult(it, VPN_REQUEST_CODE)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "core_logs")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                    logSink = events
                }
                override fun onCancel(args: Any?) {
                    logSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {

                    "startCore" -> {
                        val type = call.argument<String>("type") ?: "singbox"
                        val config = call.argument<String>("config") ?: ""

                        val intent = Intent(this, CoreService::class.java)
                        intent.putExtra("type", type)
                        intent.putExtra("config", config)

                        startForegroundService(intent)
                        result.success("Started")
                    }

                    "stopCore" -> {
                        stopService(Intent(this, CoreService::class.java))
                        result.success("Stopped")
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
