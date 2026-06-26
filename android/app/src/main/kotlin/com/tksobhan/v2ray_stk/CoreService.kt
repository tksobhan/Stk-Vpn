package com.tksobhan.v2ray_stk

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class CoreService : Service() {

    private lateinit var manager: CoreManager
    private val CHANNEL_ID = "vpn_core_channel"
    private val NOTIFICATION_ID = 1234

    override fun onCreate() {
        super.onCreate()
        manager = CoreManager(this)
        Log.d("CORE_SERVICE", "✅ CoreManager مقداردهی شد")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val type = intent?.getStringExtra("type") ?: "singbox"
        val config = intent?.getStringExtra("config") ?: ""

        Log.d("CORE_SERVICE", "🚀 شروع $type با کانفیگ: $config")

        startForegroundService()

        when (type.lowercase()) {
            "singbox" -> manager.startSingBox(config)
            "xray" -> manager.startXray(config)
            else -> Log.e("CORE_SERVICE", "نوع هسته پشتیبانی نمی‌شود: $type")
        }

        return START_STICKY
    }

    private fun startForegroundService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "VPN Core Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("V2RAY stk")
            .setContentText("هسته VPN در حال اجرا است...")
            .setSmallIcon(android.R.drawable.stat_sys_vpn_ic)
            .build()

        startForeground(NOTIFICATION_ID, notification)
        Log.d("CORE_SERVICE", "✅ سرویس foreground شروع شد")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        Log.d("CORE_SERVICE", "🛑 سرویس متوقف شد")
        manager.stopAll()
        super.onDestroy()
    }
}
