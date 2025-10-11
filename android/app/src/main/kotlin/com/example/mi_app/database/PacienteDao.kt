package com.example.mi_app.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction

@Dao
interface PacienteDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(paciente: Paciente): Long

    @Query("SELECT * FROM Paciente WHERE usuario_id = :usuarioId")
    suspend fun getByUsuarioId(usuarioId: Int): Paciente?
}
