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

class SolatWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val mainActivityIntent = Intent(context, MainActivity::class.java)
                .let {
                    PendingIntent.getActivity(context, 0, it, 0)
                }

        CoroutineScope(Dispatchers.IO).launch {
            val views = RemoteViews(context.packageName, R.layout.solat_widget).apply {
                setOnClickPendingIntent(R.id.solat_widget, mainActivityIntent)

                setTextViewText(R.id.widget_date, azanService.getCurrentDateByHidjra())

                val solatRepository = SolatRepository(context)
                solatRepository.refresh("Almaty7", "43.238293", "76.945465")
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
        setTextViewText(R.id.sunrise_active, times.sunrise)
        setInt(R.id.sunrise_layout, "setBackgroundResource", R.drawable.active_time_background)
        setImageViewResource(R.id.sunrise_divider, R.drawable.active_time_divider)
        setViewVisibility(R.id.sunrise_label, View.GONE)
        setViewVisibility(R.id.sunrise_label_active, View.VISIBLE)
        setViewVisibility(R.id.sunrise, View.GONE)
        setViewVisibility(R.id.sunrise_active, View.VISIBLE)
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