package kz.azan.solat.repository

import android.content.Context
import android.os.Build
import androidx.room.Room
import kz.azan.solat.alarm.AlarmService
import kz.azan.solat.alarm.NotificationService
import kz.azan.solat.api.azanService
import kz.azan.solat.api.muftiyatService
import kz.azan.solat.database.SolatDatabase
import kz.azan.solat.model.Times
import java.time.chrono.HijrahDate
import java.time.format.DateTimeFormatter
import java.util.*

const val SETTINGS_NAME = "kz.azan.solat.settings"

class SolatRepository(private val context: Context) {

    private val settingCity = "city"
    private val settingLatitude = "latitude"
    private val settingLongitude = "longitude"
    private val settingRefreshedOn = "refreshedOn"

    private fun getSolatDatabase(): SolatDatabase {
        return Room.databaseBuilder(
                context,
                SolatDatabase::class.java,
                "solat.db"
        ).build()
    }

    suspend fun getCurrentDateByHidjra(): String {
        return try {
            azanService.getCurrentDateByHidjra()
        } catch (e: Exception) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val formatter = DateTimeFormatter.ofPattern("d MMM uuuu")
                val date = HijrahDate.now().format(formatter)
                "$date*"
            } else {
                ""
            }
        }
    }

    suspend fun getTodayTimes(): Times? {
        val calendar = Calendar.getInstance()
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        val month = calendar.get(Calendar.MONTH) + 1
        val year = calendar.get(Calendar.YEAR)
        val date = "%02d-%02d-%d".format(day, month, year)
        val solatDatabase = getSolatDatabase()
        val times = solatDatabase.timesDao().findByDate(date)
        solatDatabase.close()
        return times
//        return Times("", "04:40", "07:02", "13:01", "19:11", "22:22", "23:23")
    }

    fun getCityName(): String? {
        val settings = context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        return settings.getString(settingCity, null)
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
}