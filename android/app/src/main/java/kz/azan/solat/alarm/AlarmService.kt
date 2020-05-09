package kz.azan.solat.alarm

import android.app.AlarmManager
import android.app.PendingIntent
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

class AlarmService(private val context: Context) {

    fun setAll() {
        CoroutineScope(Dispatchers.IO).launch {
            val solatRepository = SolatRepository(context)
            val times = solatRepository.getTodayTimes() ?: return@launch

            val currentHours = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
            val currentMinutes = Calendar.getInstance().get(Calendar.MINUTE)

            if (isBefore(currentHours, currentMinutes, times.fadjr)) setOn(times.fadjr, ALARM_FADJR)
            if (isBefore(currentHours, currentMinutes, times.sunrise)) setOn(times.sunrise, ALARM_SUNRISE)
            if (isBefore(currentHours, currentMinutes, times.dhuhr)) setOn(times.dhuhr, ALARM_DHUHR)
            if (isBefore(currentHours, currentMinutes, times.asr)) setOn(times.asr, ALARM_ASR)
            if (isBefore(currentHours, currentMinutes, times.maghrib)) setOn(times.maghrib, ALARM_MAGHRIB)
            if (isBefore(currentHours, currentMinutes, times.isha)) setOn(times.isha, ALARM_ISHA)
        }
    }

    private fun setOn(time: String, type: Int) {
        val (hours, minutes) = parseTime(time)

        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            set(Calendar.HOUR_OF_DAY, hours)
            set(Calendar.MINUTE, minutes)
            set(Calendar.SECOND, 0)
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(context, SolatWidget::class.java).let {
            it.putExtra(ALARM_TYPE, type)
            PendingIntent.getBroadcast(context, type, it, 0)
        }

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
}