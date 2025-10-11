package com.example.mi_app.database

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "Usuario",
    indices = [Index(value = ["correo"], unique = true)]
)
data class Usuario(
    @PrimaryKey(autoGenerate = true)
    val usuario_id: Int = 0,
    val nombre: String,
    val correo: String,
    val contrasena: String, // En una app real, esto debería ser un hash
    val rol: String, // "Paciente", "Médico", "Investigador"
    val fecha_creacion: String,
    val activo: Boolean = true
)
