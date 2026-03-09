package com.infodat.iamokay

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL = "com.infodat.iamokay/full_screen_intent"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarmCancel" -> {
                    try {
                        val notificationId = call.argument<Int>("notificationId") ?: -1
                        val tag = call.argument<String>("tag") ?: ""
                        val cancelAtMillis = call.argument<Number>("cancelAtMillis")?.toLong() ?: 0L
                        if (notificationId < 0 || cancelAtMillis <= 0) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        val intent = Intent(this, AlarmCancelReceiver::class.java).apply {
                            action = AlarmCancelReceiver.ACTION_CANCEL_ALARM
                            putExtra(AlarmCancelReceiver.EXTRA_NOTIFICATION_ID, notificationId)
                            putExtra(AlarmCancelReceiver.EXTRA_TAG, tag)
                        }
                        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
                        val pendingIntent = PendingIntent.getBroadcast(this, notificationId, intent, flags)
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, cancelAtMillis, pendingIntent)
                        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, cancelAtMillis, pendingIntent)
                        } else {
                            @Suppress("DEPRECATION")
                            alarmManager.setExact(AlarmManager.RTC_WAKEUP, cancelAtMillis, pendingIntent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SCHEDULE_FAILED", e.message, null)
                    }
                }
                "openSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val intent = Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT)
                                .setData(Uri.parse("package:$packageName"))
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Could not open full-screen intent settings", null)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "getAlarmUri" -> {
                    try {
                        val uri: Uri? = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        result.success(uri?.toString())
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Could not get alarm URI", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
