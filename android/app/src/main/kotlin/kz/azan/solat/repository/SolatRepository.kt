package kz.azan.solat.repository

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import androidx.room.Room
import kz.azan.solat.alarm.AlarmService
import kz.azan.solat.alarm.NotificationService
import kz.azan.solat.api.azanService
import kz.azan.solat.api.muftiyatService
import kz.azan.solat.database.SolatDatabase
import kz.azan.solat.model.Times
import java.text.SimpleDateFormat
import java.time.chrono.HijrahDate
import java.time.format.DateTimeFormatter
import java.util.*

const val SETTINGS_NAME = "kz.azan.solat.settings"

class SolatRepository(private val context: Context) {

    private val settingCity = "city"
    private val settingLatitude = "latitude"
    private val settingLongitude = "longitude"
    private val settingRefreshedOn = "refreshedOn"
    private val settingFontsScale = "fontsScale"
    private val settingAzanVolume = "azanVolume"
    private val settingRequestHidjraDateFromServer = "request-hidjra-date-from-server"

    private fun getSolatDatabase(): SolatDatabase {
        return Room.databaseBuilder(
                context,
                SolatDatabase::class.java,
                "solat.db"
        ).build()
    }

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

    suspend fun getTodayTimes(): Times? {
        val calendar = Calendar.getInstance()
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        val month = calendar.get(Calendar.MONTH) + 1
        val year = calendar.get(Calendar.YEAR)
        val date = "%02d-%02d-%d".format(day, month, year)
        val solatDatabase = getSolatDatabase()
        val times = solatDatabase.timesDao().findByDate(date)
                ?: refreshTimesIfCityIsSet(solatDatabase, date)
        solatDatabase.close()
        return times
//        return Times("", "04:40", "07:02", "13:01", "19:11", "23:36", "23:23")
    }

    private suspend fun refreshTimesIfCityIsSet(solatDatabase: SolatDatabase, date: String): Times? {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        val city = settings.getString(settingCity, null)
        if (city != null) {
            val latitude = settings.getString(settingLatitude, null)
            val longitude = settings.getString(settingLongitude, null)
            refresh(city, latitude!!, longitude!!)
            return solatDatabase.timesDao().findByDate(date)
        }
        return null
    }

    suspend fun refresh(city: String, latitude: String, longitude: String) {
        val times = getTimes(latitude, longitude)

        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)

        NotificationService(context).setDefaultAzanFlags(settings)

        with(settings.edit()) {
            remove(settingCity)
            apply()
        }

        val solatDatabase = getSolatDatabase()
        solatDatabase.timesDao().deleteAll()
        solatDatabase.timesDao().addAll(*times)
        solatDatabase.close()

        AlarmService().init(context)

        with(settings.edit()) {
            putString(settingCity, city)
            putString(settingLatitude, latitude)
            putString(settingLongitude, longitude)
            putLong(settingRefreshedOn, Calendar.getInstance().timeInMillis)
            apply()
        }
    }

    private suspend fun getTimes(latitude: String, longitude: String): Array<Times> {
        val year = Calendar.getInstance().get(Calendar.YEAR)
        val muftiyatDto = muftiyatService.getTimes(year, latitude, longitude)

        if (muftiyatDto.success) {
            return muftiyatDto.result.map {
                Times(it.date.trim(),
                        it.Fajr.trim(),
                        it.Sunrise.trim(),
                        it.Dhuhr.trim(),
                        it.Asr.trim(),
                        it.Maghrib.trim(),
                        it.Isha.trim())
            }.toTypedArray()
        }

        throw Exception("Failed to retrieve solat times from muftiyat.")
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