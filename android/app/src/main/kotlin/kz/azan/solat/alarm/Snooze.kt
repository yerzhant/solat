package kz.azan.solat.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class Snooze : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        azanRingtone?.stop()
    }
}