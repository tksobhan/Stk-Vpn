package com.tksobhan.v2ray_stk

import android.app.*
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.*
import android.system.OsConstants
import android.util.Log
import androidx.core.app.NotificationCompat
import java.io.File
import java.net.Socket
import java.util.*
import kotlin.concurrent.thread

class CoreService : VpnService() {

    private val CHANNEL_ID = "vpn_core_channel"
    private val NOTIFICATION_ID = 1234

    private var vpnInterface: ParcelFileDescriptor? = null
    private var currentProcess: Process? = null
    private var retryCount = 0
    private var trafficTimer: Timer? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        val type = intent?.getStringExtra("type") ?: "singbox"
        val config = intent?.getStringExtra("config") ?: ""

        Log.d("CORE_SERVICE", "START $type")

        startForegroundService()

        if (VpnService.prepare(this) != null) {
            requestVpnPermission()
            return START_STICKY
        }

        if (config.isBlank() || !config.trim().startsWith("{")) {
            Log.e("CORE_SERVICE", "INVALID CONFIG")
            return START_STICKY
        }

        val configFile = File(filesDir, "config.json")
        configFile.writeText(config)

        when (type.lowercase()) {
            "singbox" -> startSingBox(configFile.absolutePath)
            "xray" -> startXray(configFile.absolutePath)
        }

        protectSockets()
        startTrafficMonitor()
        readProcessOutput()

        return START_STICKY
    }

    private fun startForegroundService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "VPN",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("VPN Running")
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun requestVpnPermission() {
        val i = Intent(this, MainActivity::class.java)
        i.putExtra("vpn_request", true)
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(i)
    }

    private fun protectSockets() {
        try {
            val s = Socket()
            protect(s)
            s.close()
        } catch (_: Exception) {}
    }

    private fun startVpn(): ParcelFileDescriptor? {
        return Builder()
            .setSession("VPN")
            .addAddress("172.19.0.1", 30)
            .addRoute("0.0.0.0", 0)
            .addDnsServer("1.1.1.1")
            .setMtu(1500)
            .establish()
    }

    private fun startSingBox(path: String) {
        stopCore()

        vpnInterface?.close()
        vpnInterface = startVpn()

        val bin = File(filesDir, "sing-box")
        if (!bin.exists()) {
            Log.e("CORE_SERVICE", "sing-box binary missing")
            return
        }

        currentProcess = Runtime.getRuntime().exec(arrayOf(bin.absolutePath, "run", "-c", path))
        Log.d("CORE_SERVICE", "sing-box started")
    }

    private fun startXray(path: String) {
        stopCore()

        val bin = File(filesDir, "xray")
        if (!bin.exists()) {
            Log.e("CORE_SERVICE", "xray binary missing")
            return
        }

        currentProcess = Runtime.getRuntime().exec(arrayOf(bin.absolutePath, "-config", path))
        Log.d("CORE_SERVICE", "xray started")
    }

    private fun stopCore() {
        currentProcess?.destroy()
        currentProcess = null
    }

    private fun readProcessOutput() {
        currentProcess?.let { proc ->
            thread {
                proc.inputStream.bufferedReader().forEachLine {
                    Log.d("CORE_OUT", it)
                    MainActivity.logSink?.success(it)
                }
            }
            thread {
                proc.errorStream.bufferedReader().forEachLine {
                    Log.e("CORE_ERR", it)
                    MainActivity.logSink?.success("[ERROR] $it")
                }
            }
        }
    }

    private fun startTrafficMonitor() {
        trafficTimer = Timer()
        trafficTimer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                val rx = android.net.TrafficStats.getTotalRxBytes()
                val tx = android.net.TrafficStats.getTotalTxBytes()
                MainActivity.trafficSink?.success("$tx|$rx")
            }
        }, 0, 1000)
    }

    override fun onDestroy() {
        trafficTimer?.cancel()
        stopCore()
        vpnInterface?.close()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?) = null
}
