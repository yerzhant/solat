package kz.azan.solat.solatdata

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET

interface AzanService {

    @GET("site/current-date-by-hidjra")
    suspend fun getCurrentDateByHidjra(): String

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