package kz.azan.solat.database

import androidx.room.Database
import androidx.room.RoomDatabase
import kz.azan.solat.model.Times

@Database(entities = [Times::class], version = 1, exportSchema = false)
abstract class SolatDatabase : RoomDatabase() {
    abstract fun timesDao(): TimesDao
}