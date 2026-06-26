package com.tksobhan.v2ray_stk

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import java.io.File
import kotlin.concurrent.thread

class CoreService : VpnService() {

    companion object {
        private const val CHANNEL_ID = "vpn_pro"
        private const val NOTIFICATION_ID = 1001
    }

    // ✅ استفاده از java.lang.Process (نه android.os.Process)
    private var currentProcess: java.lang.Process? = null
    private val watchdog = Handler(Looper.getMainLooper())

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {

        val type = intent?.getStringExtra("type") ?: "singbox"
        val config = intent?.getStringExtra("config") ?: ""

        startVpnForeground()

        if (config.isBlank()) {
            Log.e("VPN", "config empty")
            return START_STICKY
        }

        val configFile = File(filesDir, "config.json")
        configFile.writeText(config)

        when (type.lowercase()) {
            "singbox" -> startSingBox(configFile.absolutePath)
            "xray" -> startXray(configFile.absolutePath)
        }

        startWatchdog()

        return START_STICKY
    }

    private fun startVpnForeground() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channel = NotificationChannel(
                CHANNEL_ID,
                "VPN PRO",
                NotificationManager.IMPORTANCE_LOW
            )

            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        val notification: Notification =
            NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("VPN Running")
                .setContentText("Connected")
                .setSmallIcon(
                    android.R.drawable.stat_sys_download_done
                )
                .build()

        startForeground(
            NOTIFICATION_ID,
            notification
        )
    }

    private fun startSingBox(config: String) {

        stopCore()

        val binary = File(filesDir, "sing-box")

        if (!binary.exists()) {
            Log.e("VPN", "sing-box missing")
            return
        }

        // ✅ استفاده از java.lang.Process
        currentProcess = Runtime.getRuntime().exec(
            arrayOf(
                binary.absolutePath,
                "run",
                "-c",
                config
            )
        )

        readLogs()
    }

    private fun startXray(config: String) {

        stopCore()

        val binary = File(filesDir, "xray")

        if (!binary.exists()) {
            Log.e("VPN", "xray missing")
            return
        }

        currentProcess = Runtime.getRuntime().exec(
            arrayOf(
                binary.absolutePath,
                "-config",
                config
            )
        )

        readLogs()
    }

    // ✅ اصلاح readLogs با استفاده از متغیر صریح برای خطوط
    private fun readLogs() {

        currentProcess?.let { proc ->

            thread {
                proc.inputStream
                    .bufferedReader()
                    .forEachLine { line ->
                        Log.d("VPN", line)
                        MainActivity.logSink?.success(line)
                    }
            }

            thread {
                proc.errorStream
                    .bufferedReader()
                    .forEachLine { line ->
                        Log.e("VPN", line)
                        MainActivity.logSink?.success("[ERROR] $line")
                    }
            }
        }
    }

    private fun startWatchdog() {

        watchdog.postDelayed(
            object : Runnable {

                override fun run() {

                    try {

                        if (currentProcess == null) {
                            Log.e(
                                "VPN",
                                "core crashed"
                            )
                        }

                    } finally {

                        watchdog.postDelayed(
                            this,
                            5000
                        )
                    }
                }
            },
            5000
        )
    }

    // ✅ استفاده از destroy() روی java.lang.Process
    private fun stopCore() {
        currentProcess?.destroy()
        currentProcess = null
    }

    override fun onDestroy() {

        stopCore()

        watchdog.removeCallbacksAndMessages(
            null
        )

        super.onDestroy()
    }

    override fun onBind(
        intent: Intent?
    ) = null
}
