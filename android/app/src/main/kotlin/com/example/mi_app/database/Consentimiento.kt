package com.example.mi_app.database

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "Consentimiento",
    foreignKeys = [ForeignKey(
        entity = Usuario::class,
        parentColumns = ["usuario_id"],
        childColumns = ["usuario_id"],
        onDelete = ForeignKey.CASCADE
    )]
)
data class Consentimiento(
    @PrimaryKey(autoGenerate = true)
    val consentimiento_id: Int = 0,
    val usuario_id: Int,
    val fecha_aceptacion: String,
    val politica_version: String,
    val permisos_otorgados: Boolean
)
