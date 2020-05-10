package kz.azan.solat.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class Times(
        @PrimaryKey
        val date: String,
        val fadjr: String,
        val sunrise: String,
        val dhuhr: String,
        val asr: String,
        val maghrib: String,
        val isha: String
)