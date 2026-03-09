package com.infodat.iamokay

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Cancels the alarm notification when triggered by AlarmManager (e.g. 1 min after alarm fires).
 */
class AlarmCancelReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, -1)
        val tag = intent.getStringExtra(EXTRA_TAG)
        if (notificationId < 0) return

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && !tag.isNullOrEmpty()) {
            notificationManager.cancel(tag, notificationId)
        } else {
            @Suppress("DEPRECATION")
            notificationManager.cancel(notificationId)
        }
    }

    companion object {
        const val ACTION_CANCEL_ALARM = "com.infodat.iamokay.CANCEL_ALARM"
        const val EXTRA_NOTIFICATION_ID = "notification_id"
        const val EXTRA_TAG = "tag"
    }
}
