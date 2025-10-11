package com.example.mi_app.database

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "RelacionMedicoPaciente",
    foreignKeys = [
        ForeignKey(entity = Medico::class, parentColumns = ["medico_id"], childColumns = ["medico_id"], onDelete = ForeignKey.CASCADE),
        ForeignKey(entity = Paciente::class, parentColumns = ["paciente_id"], childColumns = ["paciente_id"], onDelete = ForeignKey.CASCADE)
    ]
)
data class RelacionMedicoPaciente(
    @PrimaryKey(autoGenerate = true)
    val relacion_id: Int = 0,
    val medico_id: Int,
    val paciente_id: Int,
    val fecha_asignacion: String
)
