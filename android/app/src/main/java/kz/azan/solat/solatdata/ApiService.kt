package kz.azan.solat.solatdata

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET

interface ApiService {

    @GET("site/current-date-by-hidjra")
    suspend fun getCurrentDateByHidjra(): String

    companion object {
        fun create(): ApiService {
            val retrofit = Retrofit.Builder()
                    .addConverterFactory(GsonConverterFactory.create())
                    .baseUrl("https://azan.kz/api/")
                    .build()

            return retrofit.create(ApiService::class.java)
        }
    }
}

val apiService by lazy {
    ApiService.create()
}