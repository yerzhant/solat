package kz.azan.solat.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kz.azan.solat.SolatWidget
import kz.azan.solat.repository.SolatRepository
import java.util.*

const val AZAN_FADJR = 1
const val AZAN_SUNRISE = 2
const val AZAN_DHUHR = 3
const val AZAN_ASR = 4
const val AZAN_MAGHRIB = 5
const val AZAN_ISHA = 6

class AlarmService : BroadcastReceiver() {

    private val actionInit = "kz.azan.solat.action.INIT"
    private val actionAzan = "kz.azan.solat.action.AZAN"
    private val azanType = "kz.azan.solat.azan.TYPE"
    private val azanTime = "kz.azan.solat.azan.TIME"

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "android.intent.action.BOOT_COMPLETED" -> init(context)
            actionInit -> init(context)
            actionAzan -> azan(context, intent)
        }
    }

    fun init(context: Context) {
        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            add(Calendar.DAY_OF_MONTH, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 5) // Add some lag to make sure that the server has already "moved" to the next day (in case phone is not using NTP/Network time sync)
        }

        val intent = Intent(context, this::class.java).let {
            it.action = actionInit
            PendingIntent.getBroadcast(context, 0, it, 0)
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, intent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, intent)
        }

        setAll(context)
        refreshWidget(context)
    }

    private fun azan(context: Context, intent: Intent) {
        val type = intent.getIntExtra(azanType, 0)
        val time = intent.getStringExtra(azanTime) ?: ""
        NotificationService(context).notify(type, time)

        refreshWidget(context)
    }

    private fun refreshWidget(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val provider = ComponentName(context, SolatWidget::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(provider)

        val solatWidgetIntent = Intent(context, SolatWidget::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
        }

        context.sendBroadcast(solatWidgetIntent)
    }

    private fun setAll(context: Context) {
        CoroutineScope(Dispatchers.IO).launch {
            val solatRepository = SolatRepository(context)
            val times = solatRepository.getTodayTimes() ?: return@launch

            val currentHours = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
            val currentMinutes = Calendar.getInstance().get(Calendar.MINUTE)

            if (isBefore(currentHours, currentMinutes, times.fadjr)) setAt(AZAN_FADJR, times.fadjr, context)
            if (isBefore(currentHours, currentMinutes, times.sunrise)) setAt(AZAN_SUNRISE, times.sunrise, context)
            if (isBefore(currentHours, currentMinutes, times.dhuhr)) setAt(AZAN_DHUHR, times.dhuhr, context)
            if (isBefore(currentHours, currentMinutes, times.asr)) setAt(AZAN_ASR, times.asr, context)
            if (isBefore(currentHours, currentMinutes, times.maghrib)) setAt(AZAN_MAGHRIB, times.maghrib, context)
            if (isBefore(currentHours, currentMinutes, times.isha)) setAt(AZAN_ISHA, times.isha, context)
        }
    }

    private fun setAt(type: Int, time: String, context: Context) {
        val (hours, minutes) = parseTime(time)

        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            set(Calendar.HOUR_OF_DAY, hours)
            set(Calendar.MINUTE, minutes)
            set(Calendar.SECOND, 0)
        }

        val intent = Intent(context, this::class.java).let {
            it.action = actionAzan
            it.putExtra(azanType, type)
            it.putExtra(azanTime, time)
            PendingIntent.getBroadcast(context, type, it, 0)
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, intent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, intent)
        }
    }

    private fun isBefore(currentHours: Int, currentMinutes: Int, time: String): Boolean {
        val (hours, minutes) = parseTime(time)

        if (currentHours < hours) return true
        if (currentHours == hours && currentMinutes < minutes) return true

        return false
    }

    private fun parseTime(time: String): Pair<Int, Int> {
        val timeParts = time.split(":")
        val hours = timeParts[0].toInt()
        val minutes = timeParts[1].toInt()
        return Pair(hours, minutes)
    }
}