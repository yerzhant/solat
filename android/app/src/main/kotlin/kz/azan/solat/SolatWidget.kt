package kz.azan.solat

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kz.azan.solat.domain.Times
import kz.azan.solat.repository.SolatRepository
import java.util.Calendar

class SolatWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val mainActivityIntent = Intent(context, MainActivity::class.java).let {
            PendingIntent.getActivity(context, 0, it, PendingIntent.FLAG_IMMUTABLE)
        }

        CoroutineScope(Dispatchers.IO).launch {
            val views = RemoteViews(context.packageName, R.layout.solat_widget).apply {
                setOnClickPendingIntent(R.id.solat_widget, mainActivityIntent)

                val solatRepository = SolatRepository(context)
                setTextViewText(R.id.widget_date, solatRepository.getCurrentDateByHidjra())
                val cityName = solatRepository.getCityName()
                val times = solatRepository.getTodayTimes()

                if (cityName == null || times == null) {
                    setTextViewText(R.id.widget_city, context.getString(R.string.selectCity))
                } else {
                    setTextViewText(R.id.widget_city, cityName)
                    setTimes(times)
                    setAllInactive(context)
                    setActiveTime(times, context)
                }

                val opacity = solatRepository.getBackgroundOpacity().let { (it * 255).toInt() }
                val bgColor = Color.argb(opacity, 0x1B, 0xA2, 0xDD)
                setInt(R.id.solat_widget, "setBackgroundColor", bgColor)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun RemoteViews.setActiveTime(times: Times, context: Context) {
        val currentHours = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        val currentMinutes = Calendar.getInstance().get(Calendar.MINUTE)

        val solatRepository = SolatRepository(context)
        val fontsScale = solatRepository.getFontsScale()

        when {
            isBefore(currentHours, currentMinutes, times.fadjr) -> setIshaActive(times, fontsScale)
            isBefore(currentHours, currentMinutes, times.sunrise) -> setFadjrActive(times, fontsScale)
            isBefore(currentHours, currentMinutes, times.dhuhr) -> setSunriseActive(times, fontsScale)
            isBefore(currentHours, currentMinutes, times.asr) -> setDhuhrActive(times, fontsScale)
            isBefore(currentHours, currentMinutes, times.maghrib) -> setAsrActive(times, fontsScale)
            isBefore(currentHours, currentMinutes, times.isha) -> setMaghribActive(times, fontsScale)
            else -> setIshaActive(times, fontsScale)
        }
    }

    private fun isBefore(currentHours: Int, currentMinutes: Int, time: String): Boolean {
        val timeParts = time.split(":")
        val hours = timeParts[0].toInt()
        val minutes = timeParts[1].toInt()

        if (currentHours < hours) return true
        return currentHours == hours && currentMinutes < minutes
    }

    private fun RemoteViews.setFadjrActive(times: Times, fontsScale: Float) {
        setActive(
                times.fadjr,
                R.id.fadjr,
                R.id.fadjr_active,
                R.id.fadjr_label,
                R.id.fadjr_label_active,
                R.id.fadjr_divider,
                R.id.fadjr_layout,
                fontsScale
        )
    }

    private fun RemoteViews.setSunriseActive(times: Times, fontsScale: Float) {
        setActive(
                times.sunrise,
                R.id.sunrise,
                R.id.sunrise_active,
                R.id.sunrise_label,
                R.id.sunrise_label_active,
                R.id.sunrise_divider,
                R.id.sunrise_layout,
                fontsScale
        )
    }

    private fun RemoteViews.setDhuhrActive(times: Times, fontsScale: Float) {
        setActive(
                times.dhuhr,
                R.id.dhuhr,
                R.id.dhuhr_active,
                R.id.dhuhr_label,
                R.id.dhuhr_label_active,
                R.id.dhuhr_divider,
                R.id.dhuhr_layout,
                fontsScale
        )
    }

    private fun RemoteViews.setAsrActive(times: Times, fontsScale: Float) {
        setActive(
                times.asr,
                R.id.asr,
                R.id.asr_active,
                R.id.asr_label,
                R.id.asr_label_active,
                R.id.asr_divider,
                R.id.asr_layout,
                fontsScale
        )
    }

    private fun RemoteViews.setMaghribActive(times: Times, fontsScale: Float) {
        setActive(
                times.maghrib,
                R.id.maghrib,
                R.id.maghrib_active,
                R.id.maghrib_label,
                R.id.maghrib_label_active,
                R.id.maghrib_divider,
                R.id.maghrib_layout,
                fontsScale
        )
    }

    private fun RemoteViews.setIshaActive(times: Times, fontsScale: Float) {
        setActive(
                times.isha,
                R.id.isha,
                R.id.isha_active,
                R.id.isha_label,
                R.id.isha_label_active,
                R.id.isha_divider,
                R.id.isha_layout,
                fontsScale
        )
    }

    private fun RemoteViews.setActive(
            time: String,
            value: Int,
            valueActive: Int,
            label: Int,
            labelActive: Int,
            divider: Int,
            layout: Int,
            fontsScale: Float
    ) {
        setTextViewText(valueActive, time)

        setViewVisibility(label, View.GONE)
        setViewVisibility(labelActive, View.VISIBLE)
        setViewVisibility(value, View.GONE)
        setViewVisibility(valueActive, View.VISIBLE)

        setImageViewResource(divider, R.drawable.active_time_divider)
        setInt(layout, "setBackgroundResource", R.drawable.active_time_background)

        setTextViewTextSize(labelActive, TypedValue.COMPLEX_UNIT_SP, 12 * fontsScale)
        setTextViewTextSize(valueActive, TypedValue.COMPLEX_UNIT_SP, 13 * fontsScale)
    }

    private fun RemoteViews.setAllInactive(context: Context) {
        val solatRepository = SolatRepository(context)
        val fontsScale = solatRepository.getFontsScale()

        setInactive(
                R.id.fadjr,
                R.id.fadjr_active,
                R.id.fadjr_label,
                R.id.fadjr_label_active,
                R.id.fadjr_divider,
                R.id.fadjr_layout,
                fontsScale
        )
        setInactive(
                R.id.sunrise,
                R.id.sunrise_active,
                R.id.sunrise_label,
                R.id.sunrise_label_active,
                R.id.sunrise_divider,
                R.id.sunrise_layout,
                fontsScale
        )
        setInactive(
                R.id.dhuhr,
                R.id.dhuhr_active,
                R.id.dhuhr_label,
                R.id.dhuhr_label_active,
                R.id.dhuhr_divider,
                R.id.dhuhr_layout,
                fontsScale
        )
        setInactive(
                R.id.asr,
                R.id.asr_active,
                R.id.asr_label,
                R.id.asr_label_active,
                R.id.asr_divider,
                R.id.asr_layout,
                fontsScale
        )
        setInactive(
                R.id.maghrib,
                R.id.maghrib_active,
                R.id.maghrib_label,
                R.id.maghrib_label_active,
                R.id.maghrib_divider,
                R.id.maghrib_layout,
                fontsScale
        )
        setInactive(
                R.id.isha,
                R.id.isha_active,
                R.id.isha_label,
                R.id.isha_label_active,
                R.id.isha_divider,
                R.id.isha_layout,
                fontsScale
        )
    }

    private fun RemoteViews.setInactive(
            value: Int,
            valueActive: Int,
            label: Int,
            labelActive: Int,
            divider: Int,
            layout: Int,
            fontsScale: Float
    ) {
        setViewVisibility(label, View.VISIBLE)
        setViewVisibility(labelActive, View.GONE)
        setViewVisibility(value, View.VISIBLE)
        setViewVisibility(valueActive, View.GONE)

        setImageViewResource(divider, R.drawable.time_divider)
        setInt(layout, "setBackgroundResource", R.drawable.inactive_time_background)

        setTextViewTextSize(label, TypedValue.COMPLEX_UNIT_SP, 12 * fontsScale)
        setTextViewTextSize(value, TypedValue.COMPLEX_UNIT_SP, 13 * fontsScale)
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