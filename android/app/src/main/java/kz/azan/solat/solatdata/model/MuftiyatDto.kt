package kz.azan.solat.solatdata.model

data class MuftiyatDto(
        val success: Boolean,
        val result: List<TimesDto>
)

data class TimesDto(
        val date: String,
        val Fajr: String,
        val Sunrise: String,
        val Dhuhr: String,
        val Asr: String,
        val Maghrib: String,
        val Isha: String
)