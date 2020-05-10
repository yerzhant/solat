package kz.azan.solat

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kz.azan.solat.alarm.*
import kz.azan.solat.api.azanService
import kz.azan.solat.repository.SolatRepository

class MainActivity : FlutterActivity() {

    private val mainChannel = "solat.azan.kz/main"

    private val channelParamCity = "city"
    private val channelParamLatitude = "latitude"
    private val channelParamLongitude = "longitude"

    private val channelParamCurrentDateByHidjra = "currentDateByHidjra"

    private val channelParamAzanFlags = "azanFlags"
    private val channelParamAzanFlagType = "azanFlagType"
    private val channelParamAzanFlagValue = "azanFlagValue"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
        AlarmService().init(context)
        createNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mainChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "get-today-times" -> getTodayTimes(result)
                "refresh-times" -> refreshTimes(call, result)
                "set-azan-flag" -> setAzanFlag(call, result)
                "get-azan-flags" -> getAzanFlags(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun getAzanFlags(result: MethodChannel.Result) {
        val azanFlags = NotificationService(context).getAzanFlags()
        result.success(azanFlags)
    }

    private fun setAzanFlag(call: MethodCall, result: MethodChannel.Result) {
        val type = call.argument<Int>(channelParamAzanFlagType)
        val value = call.argument<Boolean>(channelParamAzanFlagValue)

        if (type == null || value == null) {
            result.error("not-enough-params", "Not enough params.", null)
            return
        }

        NotificationService(context).setFlag(type, value)
    }

    private fun refreshTimes(call: MethodCall, result: MethodChannel.Result) {
        val city = call.argument<String>(channelParamCity)
        val latitude = call.argument<String>(channelParamLatitude)
        val longitude = call.argument<String>(channelParamLongitude)

        if (city == null || latitude == null || longitude == null) {
            result.error("not-enough-params", "Not enough params.", null)
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            SolatRepository(context).refresh(city, latitude, longitude)
        }
    }

    private fun getTodayTimes(result: MethodChannel.Result) {
        val solatRepository = SolatRepository(context)

        val cityName = solatRepository.getCityName()
        if (cityName == null) {
            result.error("city-not-set", null, null)
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            val todayTimes = solatRepository.getTodayTimes()
            if (todayTimes == null) {
                result.error("no-times-for-today", null, null)
                return@launch
            }

            val currentDateByHidjra = azanService.getCurrentDateByHidjra()

            result.success(hashMapOf(
                    channelParamCity to cityName,
                    channelParamCurrentDateByHidjra to currentDateByHidjra,
                    AZAN_FADJR to todayTimes.fadjr,
                    AZAN_SUNRISE to todayTimes.sunrise,
                    AZAN_DHUHR to todayTimes.dhuhr,
                    AZAN_ASR to todayTimes.asr,
                    AZAN_MAGHRIB to todayTimes.maghrib,
                    AZAN_ISHA to todayTimes.isha
            ))
        }
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
