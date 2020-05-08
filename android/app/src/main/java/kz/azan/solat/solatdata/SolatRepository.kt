package kz.azan.solat.solatdata

import android.content.Context
import androidx.room.Room
import kz.azan.solat.solatdata.database.SolatDatabase
import kz.azan.solat.solatdata.model.Times
import java.util.*

class SolatRepository(private val context: Context) {

    private val settingsName = "kz.azan.solat.settings"
    private val settingCity = "city"
    private val settingLatitude = "latitude"
    private val settingLongitude = "longitude"
    private val settingRefreshedOn = "refreshedOn"

    private val solatDatabase = Room.databaseBuilder(
            context,
            SolatDatabase::class.java,
            "solat.db"
    ).build()

    suspend fun getTodayTimes(): Times? {
        val calendar = Calendar.getInstance()
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        val month = calendar.get(Calendar.MONTH) + 1
        val year = calendar.get(Calendar.YEAR)
        val date = "%02d-%02d-%d".format(day, month, year)
        return solatDatabase.timesDao().findByDate(date)
    }

    fun getCityName(): String? {
        val settings = context.getSharedPreferences(settingsName, Context.MODE_PRIVATE)
        return settings.getString(settingCity, null)
    }

    suspend fun refresh(city: String, latitude: String, longitude: String) {
        val times = getTimes(latitude, longitude)

        val settings = context.getSharedPreferences(settingsName, Context.MODE_PRIVATE)
        with(settings.edit()) {
            remove(settingCity)
            apply()
        }

        solatDatabase.timesDao().deleteAll()
        solatDatabase.timesDao().addAll(*times)

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