package kz.azan.solat.solatdata.api

import kz.azan.solat.solatdata.model.MuftiyatDto
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path

interface MuftiyatService {

    @GET("times/{year}/{latitude}/{longitude}")
    suspend fun getTimes(@Path("year") year: Int,
                         @Path("latitude") latitude: String,
                         @Path("longitude") longitude: String): MuftiyatDto

    companion object {
        fun create(): MuftiyatService {
            val retrofit = Retrofit.Builder()
                    .baseUrl("http://namaz.muftyat.kz/api/")
                    .addConverterFactory(GsonConverterFactory.create())
                    .build()

            return retrofit.create(MuftiyatService::class.java)
        }
    }
}

val muftiyatService by lazy {
    MuftiyatService.create()
}