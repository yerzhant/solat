package kz.azan.solat.api.dto

import androidx.annotation.Keep

@Keep
data class MuftiyatDto(
        val success: Boolean,
        val result: List<TimesDto>
)

@Keep
data class TimesDto(
        val Date: String,
        val fajr: String,
        val sunrise: String,
        val dhuhr: String,
        val asr: String,
        val maghrib: String,
        val isha: String
)