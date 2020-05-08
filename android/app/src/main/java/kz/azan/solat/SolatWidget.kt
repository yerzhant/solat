package kz.azan.solat

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kz.azan.solat.solatdata.SolatRepository
import kz.azan.solat.solatdata.azanService
import kz.azan.solat.solatdata.model.Times
import java.util.*

class SolatWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val mainActivityIntent = Intent(context, MainActivity::class.java).let {
            PendingIntent.getActivity(context, 0, it, 0)
        }

        CoroutineScope(Dispatchers.IO).launch {
            val views = RemoteViews(context.packageName, R.layout.solat_widget).apply {
                setOnClickPendingIntent(R.id.solat_widget, mainActivityIntent)

                setTextViewText(R.id.widget_date, azanService.getCurrentDateByHidjra())

                val solatRepository = SolatRepository(context)
//                solatRepository.refresh("Almaty7", "43.238293", "76.945465")
                val times = solatRepository.getTodayTimes()

                if (times == null) {
                    setTextViewText(R.id.widget_city, context.getString(R.string.selectCity))
                } else {
                    setTextViewText(R.id.widget_city, solatRepository.getCityName())

                    setTimes(times)
                    setActiveTime(times)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun RemoteViews.setActiveTime(times: Times) {
        val currentHours = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        val currentMinutes = Calendar.getInstance().get(Calendar.MINUTE)

        when {
            isBefore(currentHours, currentMinutes, times.fadjr) -> setIshaActive(times)
            isBefore(currentHours, currentMinutes, times.sunrise) -> setFadjrActive(times)
            isBefore(currentHours, currentMinutes, times.dhuhr) -> setSunriseActive(times)
            isBefore(currentHours, currentMinutes, times.asr) -> setDhuhrActive(times)
            isBefore(currentHours, currentMinutes, times.maghrib) -> setAsrActive(times)
            isBefore(currentHours, currentMinutes, times.isha) -> setMaghribActive(times)
            else -> setIshaActive(times)
        }
    }

    private fun isBefore(currentHours: Int, currentMinutes: Int, time: String): Boolean {
        val timeParts = time.split(":")
        val hours = timeParts[0].toInt()
        val minutes = timeParts[1].toInt()

        if (currentHours < hours) return true
        if (currentHours == hours && currentMinutes < minutes) return true
        return false
    }

    private fun RemoteViews.setFadjrActive(times: Times) {
        setActive(
                times.fadjr,
                R.id.fadjr,
                R.id.fadjr_active,
                R.id.fadjr_label,
                R.id.fadjr_label_active,
                R.id.fadjr_divider,
                R.id.fadjr_layout
        )
    }

    private fun RemoteViews.setSunriseActive(times: Times) {
        setActive(
                times.sunrise,
                R.id.sunrise,
                R.id.sunrise_active,
                R.id.sunrise_label,
                R.id.sunrise_label_active,
                R.id.sunrise_divider,
                R.id.sunrise_layout
        )
    }

    private fun RemoteViews.setDhuhrActive(times: Times) {
        setActive(
                times.dhuhr,
                R.id.dhuhr,
                R.id.dhuhr_active,
                R.id.dhuhr_label,
                R.id.dhuhr_label_active,
                R.id.dhuhr_divider,
                R.id.dhuhr_layout
        )
    }

    private fun RemoteViews.setAsrActive(times: Times) {
        setActive(
                times.asr,
                R.id.asr,
                R.id.asr_active,
                R.id.asr_label,
                R.id.asr_label_active,
                R.id.asr_divider,
                R.id.asr_layout
        )
    }

    private fun RemoteViews.setMaghribActive(times: Times) {
        setActive(
                times.maghrib,
                R.id.maghrib,
                R.id.maghrib_active,
                R.id.maghrib_label,
                R.id.maghrib_label_active,
                R.id.maghrib_divider,
                R.id.maghrib_layout
        )
    }

    private fun RemoteViews.setIshaActive(times: Times) {
        setActive(
                times.isha,
                R.id.isha,
                R.id.isha_active,
                R.id.isha_label,
                R.id.isha_label_active,
                R.id.isha_divider,
                R.id.isha_layout
        )
    }

    private fun RemoteViews.setActive(
            time: String,
            value: Int,
            valueActive: Int,
            label: Int,
            labelActive: Int,
            divider: Int,
            layout: Int
    ) {
        setTextViewText(valueActive, time)
        setViewVisibility(label, View.GONE)
        setViewVisibility(labelActive, View.VISIBLE)
        setViewVisibility(value, View.GONE)
        setViewVisibility(valueActive, View.VISIBLE)
        setImageViewResource(divider, R.drawable.active_time_divider)
        setInt(layout, "setBackgroundResource", R.drawable.active_time_background)
    }

    private fun RemoteViews.setTimes(times: Times) {
        setTextViewText(R.id.fadjr, times.fadjr)
        setTextViewText(R.id.sunrise, times.sunrise)
        setTextViewText(R.id.dhuhr, times.dhuhr)
        setTextViewText(R.id.asr, times.asr)
        setTextViewText(R.id.maghrib, times.maghrib)
        setTextViewText(R.id.isha, times.isha)
    }
}