package kz.azan.solat.repository

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import kz.azan.solat.alarm.AlarmService
import kz.azan.solat.alarm.NotificationService
import kz.azan.solat.api.azanService
import kz.azan.solat.domain.PrayTime
import kz.azan.solat.domain.Times
import java.text.SimpleDateFormat
import java.time.chrono.HijrahDate
import java.time.format.DateTimeFormatter
import java.util.*

const val SETTINGS_NAME = "kz.azan.solat.settings"

class SolatRepository(private val context: Context) {

    private val settingCity = "city"
    private val settingLatitude = "latitude"
    private val settingLongitude = "longitude"
    private val settingTimeZone = "time-zone"
    private val settingRefreshedOn = "refreshedOn"
    private val settingFontsScale = "fontsScale"
    private val settingAzanVolume = "azanVolume"
    private val settingRequestHidjraDateFromServer = "request-hidjra-date-from-server"

    private val defaultTimeZone = 6

    suspend fun getCurrentDateByHidjra(): String {
        return try {
            if (getRequestHidjraDateFromServer()) return azanService.getCurrentDateByHidjra()
            return calculateHidjraDate()
        } catch (e: Exception) {
            "${calculateHidjraDate()}*"
        }
    }

    @SuppressLint("SimpleDateFormat")
    private fun calculateHidjraDate() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val formatter = DateTimeFormatter.ofPattern("d MMMM uuuu")
        HijrahDate.now().format(formatter)
    } else {
        SimpleDateFormat("d MMMM y").format(Date())
    }

    fun getTodayTimes(): Times? {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)

        if (settings.getString(settingCity, null) == null) return null

        return PrayTime().calculate(
                settings.getString(settingLatitude, null)?.toDouble()!!,
                settings.getString(settingLongitude, null)?.toDouble()!!,
                settings.getInt(settingTimeZone, defaultTimeZone)
        )
//        return Times("", "04:40", "07:02", "13:01", "19:11", "23:36", "23:23")
    }

    fun getCityName(): String? {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        return settings.getString(settingCity, null)
    }

    fun saveCity(city: String, latitude: String, longitude: String, timeZone: Double) {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)

        NotificationService(context).setDefaultAzanFlags(settings)

        with(settings.edit()) {
            putString(settingCity, city)
            putString(settingLatitude, latitude)
            putString(settingLongitude, longitude)
            putInt(settingTimeZone, timeZone.toInt())
            putLong(settingRefreshedOn, Calendar.getInstance().timeInMillis)
            apply()
        }

        AlarmService().init(context)
    }

    fun getFontsScale(): Float {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        return settings.getFloat(settingFontsScale, 1F)
    }

    fun setFontsScale(scale: Float) {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        with(settings.edit()) {
            putFloat(settingFontsScale, scale)
            apply()
        }
        AlarmService().refreshWidget(context)
    }

    fun getAzanVolume(): Float {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        return settings.getFloat(settingAzanVolume, .3F)
    }

    fun setAzanVolume(scale: Float) {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        with(settings.edit()) {
            putFloat(settingAzanVolume, scale)
            apply()
        }
    }

    fun getRequestHidjraDateFromServer(): Boolean {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        return settings.getBoolean(settingRequestHidjraDateFromServer, true)
    }

    fun setRequestHidjraDateFromServer(value: Boolean) {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        with(settings.edit()) {
            putBoolean(settingRequestHidjraDateFromServer, value)
            apply()
        }
    }
}