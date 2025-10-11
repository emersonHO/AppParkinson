package com.example.mi_app.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "PruebaConfiguracion")
data class PruebaConfiguracion(
    @PrimaryKey(autoGenerate = true)
    val config_id: Int = 0,
    val tipo_prueba: String,
    val parametros_json: String,
    val ultima_actualizacion: String
)
