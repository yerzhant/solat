package kz.azan.solat.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kz.azan.solat.SolatWidget
import kz.azan.solat.repository.SolatRepository
import java.util.*

const val ALARM_TYPE = "kz.azan.solat.alarm-type"
const val ALARM_FADJR = 1
const val ALARM_SUNRISE = 2
const val ALARM_DHUHR = 3
const val ALARM_ASR = 4
const val ALARM_MAGHRIB = 5
const val ALARM_ISHA = 6

class AlarmService : BroadcastReceiver() {

    private val setAllHours = 0
    private val setAllMinutes = 7

    fun init(context: Context) {
        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            set(Calendar.HOUR_OF_DAY, setAllHours)
            set(Calendar.MINUTE, setAllMinutes)
        }

        val intent = Intent(context, AlarmService::class.java).let {
            PendingIntent.getBroadcast(context, 0, it, 0)
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setInexactRepeating(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                AlarmManager.INTERVAL_DAY,
                intent
        )
    }

    private fun setAll(context: Context) {
        CoroutineScope(Dispatchers.IO).launch {
            val solatRepository = SolatRepository(context)
            val times = solatRepository.getTodayTimes() ?: return@launch

            val currentHours = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
            val currentMinutes = Calendar.getInstance().get(Calendar.MINUTE)

            if (isBefore(currentHours, currentMinutes, times.fadjr)) setAt(times.fadjr, ALARM_FADJR, context)
            if (isBefore(currentHours, currentMinutes, times.sunrise)) setAt(times.sunrise, ALARM_SUNRISE, context)
            if (isBefore(currentHours, currentMinutes, times.dhuhr)) setAt(times.dhuhr, ALARM_DHUHR, context)
            if (isBefore(currentHours, currentMinutes, times.asr)) setAt(times.asr, ALARM_ASR, context)
            if (isBefore(currentHours, currentMinutes, times.maghrib)) setAt(times.maghrib, ALARM_MAGHRIB, context)
            if (isBefore(currentHours, currentMinutes, times.isha)) setAt(times.isha, ALARM_ISHA, context)
        }
    }

    private fun setAt(time: String, type: Int, context: Context) {
        val (hours, minutes) = parseTime(time)

        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            set(Calendar.HOUR_OF_DAY, hours)
            set(Calendar.MINUTE, minutes)
            set(Calendar.SECOND, 0)
        }

        val intent = Intent(context, SolatWidget::class.java).let {
            it.putExtra(ALARM_TYPE, type)
            PendingIntent.getBroadcast(context, type, it, 0)
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, intent)
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

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.intent.action.BOOT_COMPLETED") {
            init(context)
        } else {
            setAll(context)
        }
    }
}