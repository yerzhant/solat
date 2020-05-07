package kz.azan.solat.solatdata.model

data class MuftiyatTimes(
        val success: Boolean,
        val result: List<Times>
)

data class Times(
        val date: String,
        val Fajr: String,
        val Sunrise: String,
        val Dhuhr: String,
        val Asr: String,
        val Maghrib: String,
        val Isha: String
)