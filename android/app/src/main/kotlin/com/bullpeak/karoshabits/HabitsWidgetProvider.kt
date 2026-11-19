package com.bullpeak.karoshabits

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Home screen widget: how many of today's habits are done. */
class HabitsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val totals = try {
            JSONObject(widgetData.getString("totals", "{}") ?: "{}")
        } catch (e: Exception) {
            JSONObject()
        }
        val total = totals.optInt(today, 0)
        // After midnight the saved count belongs to yesterday: start at 0.
        val done = if (widgetData.getString("doneDate", "") == today) {
            widgetData.getInt("done", 0)
        } else {
            0
        }
        val pattern = widgetData.getString("summaryPattern", "{done} / {total}")
            ?: "{done} / {total}"
        val noHabits = widgetData.getString("noHabits", "") ?: ""
        val title = widgetData.getString("title", "Karos Habits") ?: "Karos Habits"

        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.habits_widget).apply {
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_count, "$done / $total")
                setProgressBar(
                    R.id.widget_progress,
                    100,
                    if (total == 0) 0 else (done * 100 / total),
                    false,
                )
                setTextViewText(
                    R.id.widget_summary,
                    if (total == 0) noHabits
                    else pattern.replace("{done}", "$done").replace("{total}", "$total"),
                )
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
