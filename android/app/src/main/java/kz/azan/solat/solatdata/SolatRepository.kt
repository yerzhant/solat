package kz.azan.solat.solatdata

import android.content.Context
import androidx.room.Room
import kz.azan.solat.solatdata.database.SolatDatabase
import kz.azan.solat.solatdata.model.Times
import java.util.*

class SolatRepository(context: Context) {

    private val solatDatabase = Room.databaseBuilder(
            context,
            SolatDatabase::class.java,
            "solat.db"
    ).build()

    fun getTodayTimes(): Times? {
        return solatDatabase.timesDao().findByDate("08-05-2020")
    }

    fun getCityName(): String {
        return "Almaty"
    }

    suspend fun refresh(city: String, latitude: String, longitude: String) {
        val times = getTimes(latitude, longitude)
        solatDatabase.timesDao().deleteAll()
        solatDatabase.timesDao().addAll(*times)
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