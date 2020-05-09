package kz.azan.solat

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import kz.azan.solat.alarm.AZAN_CHANNEL_ID
import kz.azan.solat.alarm.AlarmService

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()

        AlarmService().init(context)
//        solatRepository.refresh(context, "Almaty77", "43.238293", "76.945465")
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = context.getString(R.string.azan)
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(AZAN_CHANNEL_ID, name, importance)
            val notificationManager: NotificationManager =
                    context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
