package kz.azan.solat.solatdata.database

import androidx.room.Database
import androidx.room.RoomDatabase
import kz.azan.solat.solatdata.model.Times

@Database(entities = [Times::class], version = 1)
abstract class SolatDatabase : RoomDatabase() {
    abstract fun timesDao(): TimesDao
}