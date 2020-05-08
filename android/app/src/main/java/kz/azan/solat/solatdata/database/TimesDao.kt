package kz.azan.solat.solatdata.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kz.azan.solat.solatdata.model.Times

@Dao
interface TimesDao {

    @Query("SELECT * FROM times WHERE date = :date")
    suspend fun findByDate(date: String): Times?

    @Insert
    suspend fun addAll(vararg times: Times)

    @Query("DELETE FROM times")
    suspend fun deleteAll()
}