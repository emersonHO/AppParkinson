package com.example.mi_app.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface MedicoDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(medico: Medico): Long

    @Query("SELECT * FROM Medico WHERE usuario_id = :usuarioId")
    suspend fun getByUsuarioId(usuarioId: Int): Medico?
}
