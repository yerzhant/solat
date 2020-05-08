package kz.azan.solat.solatdata.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kz.azan.solat.solatdata.model.Times

@Dao
interface TimesDao {

    @Query("SELECT * FROM times WHERE date = :date")
    fun findByDate(date: String): Times?

    @Insert
    fun addAll(vararg times: Times)

    @Query("DELETE FROM times")
    fun deleteAll()
}