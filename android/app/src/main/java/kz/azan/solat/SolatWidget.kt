package kz.azan.solat

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

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

        val views = RemoteViews(context.packageName, R.layout.solat_widget)
                .apply {
                    setOnClickPendingIntent(R.id.solat_widget, mainActivityIntent)
                }

        views.setTextViewText(R.id.widget_date, "12 Рамадан 1441")
        views.setTextViewText(R.id.widget_city, "Алматы")
        views.setTextViewText(R.id.fadjr, "04:08")

        views.setImageViewResource(R.id.sunrise_divider, R.drawable.active_time_divider)
        views.setTextViewText(R.id.sunrise, "04:08")
        views.setTextViewText(R.id.sunrise_active, "04:08")

        views.setViewVisibility(R.id.sunrise_label, View.GONE)
        views.setViewVisibility(R.id.sunrise_label_active, View.VISIBLE)
        views.setViewVisibility(R.id.sunrise, View.GONE)
        views.setViewVisibility(R.id.sunrise_active, View.VISIBLE)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}