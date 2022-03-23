package kz.azan.solat.alarm

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import kz.azan.solat.MainActivity
import kz.azan.solat.R
import kz.azan.solat.repository.SETTINGS_NAME
import kz.azan.solat.repository.SolatRepository
import java.util.*

const val AZAN_CHANNEL_ID = "azan-human"

var azanRingtone: Ringtone? = null

class NotificationService(private val context: Context) {

    private val azanTypePrefix = "azan-type"

    fun notify(type: Int, time: String) {
        if (!isEnabled(type)) return

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
            PendingIntent.getActivity(context, 0, it, PendingIntent.FLAG_IMMUTABLE)
        }

        val snoozeIntent = Intent(context, Snooze::class.java).let {
            PendingIntent.getBroadcast(context, 0, it, PendingIntent.FLAG_IMMUTABLE)
        }

        val solatRepository = SolatRepository(context)
        val cityName = solatRepository.getCityName()

        val azan = when (type) {
            AZAN_FADJR -> R.raw.qasym_fadjr
            else -> R.raw.qasym
        }

        val azanUri: Uri = Uri.parse("android.resource://${context.packageName}/$azan")

        val builder = NotificationCompat.Builder(context, AZAN_CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_logo)
                .setContentTitle("$title · $time")
                .setContentText(cityName)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setContentIntent(mainActivityIntent)
                .setDeleteIntent(snoozeIntent)
                .setAutoCancel(true)
                .addAction(
                        R.drawable.ic_baseline_snooze_24,
                        context.getString(R.string.snooze).uppercase(Locale.ROOT),
                        snoozeIntent
                )

        azanRingtone = RingtoneManager.getRingtone(context, azanUri)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            azanRingtone?.volume = solatRepository.getAzanVolume()
        }
        azanRingtone?.play()

        with(NotificationManagerCompat.from(context)) {
            notify(0, builder.build())
        }
    }

    private fun isEnabled(type: Int): Boolean {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        return settings.getBoolean("$azanTypePrefix-$type", false)
    }

    fun setFlag(type: Int, value: Boolean) {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        with(settings.edit()) {
            putBoolean("$azanTypePrefix-$type", value)
            apply()
        }
    }

    fun setDefaultAzanFlags(settings: SharedPreferences) {
        if (settings.contains("$azanTypePrefix-$AZAN_FADJR")) return

        with(settings.edit()) {
            putBoolean("$azanTypePrefix-$AZAN_FADJR", true)
            putBoolean("$azanTypePrefix-$AZAN_SUNRISE", false)
            putBoolean("$azanTypePrefix-$AZAN_DHUHR", true)
            putBoolean("$azanTypePrefix-$AZAN_ASR", true)
            putBoolean("$azanTypePrefix-$AZAN_MAGHRIB", true)
            putBoolean("$azanTypePrefix-$AZAN_ISHA", true)
            apply()
        }
    }

    fun getAzanFlags(): HashMap<Int, Boolean> {
        return hashMapOf(
                AZAN_FADJR to isEnabled(AZAN_FADJR),
                AZAN_SUNRISE to isEnabled(AZAN_SUNRISE),
                AZAN_DHUHR to isEnabled(AZAN_DHUHR),
                AZAN_ASR to isEnabled(AZAN_ASR),
                AZAN_MAGHRIB to isEnabled(AZAN_MAGHRIB),
                AZAN_ISHA to isEnabled(AZAN_ISHA)
        )
    }
}