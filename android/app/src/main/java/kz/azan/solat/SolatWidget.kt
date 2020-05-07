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
import kz.azan.solat.solatdata.apiService

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
            val views = RemoteViews(context.packageName, R.layout.solat_widget)
                    .apply {
                        setOnClickPendingIntent(R.id.solat_widget, mainActivityIntent)

                        setTextViewText(R.id.widget_date, apiService.getCurrentDateByHidjra())
                        setTextViewText(R.id.widget_city, "111 Алматы Алматы Алматы Алматы Алматы Алматы Алматы Алматы 999")

                        setTextViewText(R.id.fadjr, "04:08")
                        setTextViewText(R.id.sunrise_active, "05:37")
                        setTextViewText(R.id.dhuhr, "12:52")
                        setTextViewText(R.id.asr, "17:53")
                        setTextViewText(R.id.maghrib, "20:01")
                        setTextViewText(R.id.isha, "21:31")

                        setInt(R.id.sunrise_layout, "setBackgroundResource", R.drawable.active_time_background)
                        setImageViewResource(R.id.sunrise_divider, R.drawable.active_time_divider)
                        setViewVisibility(R.id.sunrise_label, View.GONE)
                        setViewVisibility(R.id.sunrise_label_active, View.VISIBLE)
                        setViewVisibility(R.id.sunrise, View.GONE)
                        setViewVisibility(R.id.sunrise_active, View.VISIBLE)
                    }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}