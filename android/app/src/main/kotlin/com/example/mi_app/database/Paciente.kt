package com.example.mi_app.database

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "Paciente",
    foreignKeys = [ForeignKey(
        entity = Usuario::class,
        parentColumns = ["usuario_id"],
        childColumns = ["usuario_id"],
        onDelete = ForeignKey.CASCADE
    )]
)
data class Paciente(
    @PrimaryKey(autoGenerate = true)
    val paciente_id: Int = 0,
    val usuario_id: Int,
    val edad: Int,
    val genero: String,
    val fecha_diagnostico: String,
    val contacto_emergencia: String,
    val notas_medicas: String?
)
