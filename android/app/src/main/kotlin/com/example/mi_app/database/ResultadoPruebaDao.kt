package com.example.mi_app.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface ResultadoPruebaDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(resultado: ResultadoPrueba)

    @Query("SELECT * FROM ResultadoPrueba WHERE paciente_id = :pacienteId ORDER BY fecha DESC")
    fun getResultadosByPacienteId(pacienteId: Int): Flow<List<ResultadoPrueba>>
}
