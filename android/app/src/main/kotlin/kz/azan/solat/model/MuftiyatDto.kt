package kz.azan.solat.model

import androidx.annotation.Keep

@Keep
data class MuftiyatDto(
        val success: Boolean,
        val result: List<TimesDto>
)

@Keep
data class TimesDto(
        val date: String,
        val Fajr: String,
        val Sunrise: String,
        val Dhuhr: String,
        val Asr: String,
        val Maghrib: String,
        val Isha: String
)