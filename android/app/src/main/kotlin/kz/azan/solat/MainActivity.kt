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
import kotlinx.coroutines.withContext
import kz.azan.solat.alarm.*
import kz.azan.solat.repository.SolatRepository

class MainActivity : FlutterActivity() {

    private val mainChannel = "solat.azan.kz/main"

    private val channelParamCity = "city"
    private val channelParamLatitude = "latitude"
    private val channelParamLongitude = "longitude"
    private val channelParamTimeZone = "time-zone"

    private val channelParamFontsScale = "fontsScale"
    private val channelParamAzanVolume = "azanVolume"

    private val channelParamCurrentDateByHidjra = "currentDateByHidjra"

    private val channelParamAzanFlagType = "azanFlagType"
    private val channelParamAzanFlagValue = "azanFlagValue"

    private val channelErrorCityNotSet = "city-not-set"
    private val channelErrorNotEnoughParams = "not-enough-params"
    private val channelErrorNoTimesForToday = "no-times-for-today"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        AlarmService().init(context)
        createNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mainChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "get-today-times" -> getTodayTimes(result)
                "save-city" -> saveCity(call, result)
                "get-azan-flags" -> getAzanFlags(result)
                "set-azan-flag" -> setAzanFlag(call, result)
                "get-fonts-scale" -> getFontsScale(result)
                "set-fonts-scale" -> setFontsScale(call, result)
                "get-azan-volume" -> getAzanVolume(result)
                "set-azan-volume" -> setAzanVolume(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun getAzanVolume(result: MethodChannel.Result) {
        val solatRepository = SolatRepository(context)
        result.success(solatRepository.getAzanVolume())
    }

    private fun setAzanVolume(call: MethodCall, result: MethodChannel.Result) {
        val volume = call.argument<Double>(channelParamAzanVolume)

        if (volume == null) {
            result.error(channelErrorNotEnoughParams, null, null)
            return
        }

        val solatRepository = SolatRepository(context)
        solatRepository.setAzanVolume(volume.toFloat())

        result.success(true)
    }

    private fun getFontsScale(result: MethodChannel.Result) {
        val solatRepository = SolatRepository(context)
        result.success(solatRepository.getFontsScale())
    }

    private fun setFontsScale(call: MethodCall, result: MethodChannel.Result) {
        val scale = call.argument<Double>(channelParamFontsScale)

        if (scale == null) {
            result.error(channelErrorNotEnoughParams, null, null)
            return
        }

        val solatRepository = SolatRepository(context)
        solatRepository.setFontsScale(scale.toFloat())

        result.success(true)
    }

    private fun getAzanFlags(result: MethodChannel.Result) {
        val azanFlags = NotificationService(context).getAzanFlags()
        result.success(azanFlags)
    }

    private fun setAzanFlag(call: MethodCall, result: MethodChannel.Result) {
        val type = call.argument<Int>(channelParamAzanFlagType)
        val value = call.argument<Boolean>(channelParamAzanFlagValue)

        if (type == null || value == null) {
            result.error(channelErrorNotEnoughParams, null, null)
            return
        }

        NotificationService(context).setFlag(type, value)
        result.success(true)
    }

    private fun saveCity(call: MethodCall, result: MethodChannel.Result) {
        val city = call.argument<String>(channelParamCity)
        val latitude = call.argument<Double>(channelParamLatitude)
        val longitude = call.argument<Double>(channelParamLongitude)
        val timeZone = call.argument<Double>(channelParamTimeZone)

        if (city == null || latitude == null || longitude == null || timeZone == null) {
            result.error(channelErrorNotEnoughParams, null, null)
            return
        }

        SolatRepository(context).saveCity(
                city,
                latitude.toString(),
                longitude.toString(),
                timeZone
        )

        result.success(true)
    }

    private fun getTodayTimes(result: MethodChannel.Result) {
        val solatRepository = SolatRepository(context)

        val cityName = solatRepository.getCityName()
        if (cityName == null) {
            result.error(channelErrorCityNotSet, null, null)
            return
        }

        CoroutineScope(Dispatchers.Main).launch {
            val todayTimes = solatRepository.getTodayTimes()
            if (todayTimes == null) {
                result.error(channelErrorNoTimesForToday, null, null)
                return@launch
            }

            val currentDateByHidjra = solatRepository.getCurrentDateByHidjra()

            withContext(Dispatchers.Main.immediate) {
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

    override fun onResume() {
        super.onResume()
        azanRingtone?.stop()
    }
}
