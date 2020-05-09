package kz.azan.solat.alarm

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import kz.azan.solat.MainActivity
import kz.azan.solat.R
import kz.azan.solat.repository.SETTINGS_NAME

const val AZAN_CHANNEL_ID = "azan"

class NotificationService(private val context: Context) {

    private val azanNotificationPrefix = "azan-notification"

    fun notify(type: Int, time: String) {
        if (!enabled(type)) return

        val title = when (type) {
            AZAN_FADJR -> context.getString(R.string.fadjr)
            AZAN_SUNRISE -> context.getString(R.string.sunrise)
            AZAN_DHUHR -> context.getString(R.string.dhuhr)
            AZAN_ASR -> context.getString(R.string.asr)
            AZAN_MAGHRIB -> context.getString(R.string.maghrib)
            AZAN_ISHA -> context.getString(R.string.isha)
            else -> "???"
        }

        val mainActivityIntent = Intent(context, MainActivity::class.java).let {
            PendingIntent.getActivity(context, 0, it, 0)
        }

        val builder = NotificationCompat.Builder(context, AZAN_CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_logo)
                .setContentTitle("$title $time")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setContentIntent(mainActivityIntent)
                .setAutoCancel(true)

        with(NotificationManagerCompat.from(context)) {
            notify(0, builder.build())
        }
    }

    private fun enabled(type: Int): Boolean {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        return settings.getBoolean("$azanNotificationPrefix-$type", false)
    }
}