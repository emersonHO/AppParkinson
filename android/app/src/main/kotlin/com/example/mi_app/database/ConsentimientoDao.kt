package com.example.mi_app.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface ConsentimientoDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(consentimiento: Consentimiento)

    @Query("SELECT * FROM Consentimiento WHERE usuario_id = :usuarioId")
    suspend fun getByUsuarioId(usuarioId: Int): Consentimiento?
}
