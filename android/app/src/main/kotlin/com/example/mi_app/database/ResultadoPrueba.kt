package com.example.mi_app.database

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "ResultadoPrueba",
    foreignKeys = [ForeignKey(
        entity = Paciente::class,
        parentColumns = ["paciente_id"],
        childColumns = ["paciente_id"],
        onDelete = ForeignKey.CASCADE
    )]
)
data class ResultadoPrueba(
    @PrimaryKey(autoGenerate = true)
    val resultado_id: Int = 0,
    val paciente_id: Int,
    val tipo_prueba: String, // "Tapping", "Espiral", "Voz", "Cuestionario"
    val fecha: String,
    val nivel_riesgo: String, // "Bajo", "Moderado", "Alto"
    val confianza: Int,
    val observaciones: String,
    val archivo_referencia: String?
)
