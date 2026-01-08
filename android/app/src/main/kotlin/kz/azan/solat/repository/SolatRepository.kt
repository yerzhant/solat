package kz.azan.solat.repository

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import androidx.core.content.edit
import kz.azan.solat.alarm.AlarmService
import kz.azan.solat.alarm.notificationService
import kz.azan.solat.api.azanService
import kz.azan.solat.domain.PrayTime
import kz.azan.solat.domain.Times
import java.text.SimpleDateFormat
import java.time.chrono.HijrahDate
import java.time.format.DateTimeFormatter
import java.util.Calendar
import java.util.Date

const val SETTINGS_NAME = "kz.azan.solat.settings"

class SolatRepository(private val context: Context) {

    private val settingCity = "city"
    private val settingCityId = "city-id"
    private val settingLatitude = "latitude"
    private val settingLongitude = "longitude"
    private val settingTimeZone = "time-zone"
    private val settingRefreshedOn = "refreshedOn"
    private val settingFontsScale = "fontsScale"
    private val settingAzanVolume = "azanVolume"
    private val settingBackgroundOpacity = "background-opacity"
    private val settingRequestHidjraDateFromServer = "request-hidjra-date-from-server"

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

    fun resetCityIdIfTimeZoneNotSet() {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        if (!settings.contains(settingTimeZone)) {
            with(settings.edit()) {
                remove(settingCityId)
                apply()
            }
        }
    }

    fun getTodayTimes(): Times? {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        val cityId = settings.getInt(settingCityId, -1)
        if (cityId == -1) return null

        val calendar = Calendar.getInstance()
        val timeZoneSwitchDate = Calendar.getInstance().apply { set(2024, 2, 1) }
        val latitude = settings.getString(settingLatitude, null)!!.toDouble()
        val longitude = settings.getString(settingLongitude, null)!!.toDouble()
        val timeZone = if (calendar < timeZoneSwitchDate)
            settings.getInt(settingTimeZone, 0).toDouble()
        else 5.0

        val prayTime = PrayTime().apply {
            calcMethod = ISNA
            asrJuristic = Hanafi
            adjustHighLats = AngleBased
        }
        val offsets = if (latitude < 48)
            intArrayOf(0, -3, 3, 3, 0, 3, 0) // {Fadjr,Sunrise,Dhuhr,Asr,Sunset,Maghrib,Isha}
        else
            intArrayOf(0, -5, 5, 5, 0, 5, 0) // {Fadjr,Sunrise,Dhuhr,Asr,Sunset,Maghrib,Isha}
        prayTime.tune(offsets)
        val times = prayTime.getPrayerTimes(calendar, latitude, longitude, timeZone)

        return Times(times[0], times[1], times[2], times[3], times[5], times[6])
//        return Times("04:40", "07:02", "13:01", "14:11", "15:36", "21:15")
    }

    fun saveCityParams(
        city: String,
        cityId: Int,
        latitude: String,
        longitude: String,
        timeZone: Int
    ) {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)

        notificationService.setDefaultAzanFlags(settings)

        with(settings.edit()) {
            remove(settingCityId)
            apply()
        }

        AlarmService().init(context)

        with(settings.edit()) {
            putString(settingCity, city)
            putInt(settingCityId, cityId)
            putString(settingLatitude, latitude)
            putString(settingLongitude, longitude)
            putInt(settingTimeZone, timeZone)
            putLong(settingRefreshedOn, Calendar.getInstance().timeInMillis)
            apply()
        }
    }

    fun getCityName(): String? {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        return settings.getString(settingCity, null)
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

    fun getBackgroundOpacity(): Float {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        return settings.getFloat(settingBackgroundOpacity, .7F)
    }

    fun setBackgroundOpacity(value: Float) {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        settings.edit { putFloat(settingBackgroundOpacity, value) }
        AlarmService().refreshWidget(context)
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
