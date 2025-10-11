package com.example.mi_app.database

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "Medico",
    foreignKeys = [ForeignKey(
        entity = Usuario::class,
        parentColumns = ["usuario_id"],
        childColumns = ["usuario_id"],
        onDelete = ForeignKey.CASCADE
    )]
)
data class Medico(
    @PrimaryKey(autoGenerate = true)
    val medico_id: Int = 0,
    val usuario_id: Int,
    val especialidad: String,
    val centro_medico: String,
    val nro_colegiatura: String
)
