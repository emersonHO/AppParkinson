package com.example.mi_app.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface RelacionMedicoPacienteDao {
    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insert(relacion: RelacionMedicoPaciente)

    @Query("SELECT * FROM Paciente INNER JOIN RelacionMedicoPaciente ON Paciente.paciente_id = RelacionMedicoPaciente.paciente_id WHERE RelacionMedicoPaciente.medico_id = :medicoId")
    suspend fun getPacientesOfMedico(medicoId: Int): List<Paciente>
}
