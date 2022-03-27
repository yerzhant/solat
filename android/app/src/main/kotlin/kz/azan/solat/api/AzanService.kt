package kz.azan.solat.api

import androidx.annotation.Keep
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path

interface AzanService {

    @GET("site/current-date-by-hidjra")
    suspend fun getCurrentDateByHidjra(): String

    @GET("asr/year-v2/{city-id}/{year}")
    suspend fun getTimes(@Path("city-id") cityId: Int,
                         @Path("year") date: Int): List<TimesDto>

    companion object {
        fun create(): AzanService {
            val retrofit = Retrofit.Builder()
                    .baseUrl("https://azan.kz/api/")
                    .addConverterFactory(GsonConverterFactory.create())
                    .build()

            return retrofit.create(AzanService::class.java)
        }
    }
}

val azanService by lazy {
    AzanService.create()
}

@Keep
data class TimesDto(
        val date: String,
        val fadjr: String,
        val sunrise: String,
        val dhuhr: String,
        val asr: String,
        val maghrib: String,
        val isha: String
)
