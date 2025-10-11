package com.example.mi_app.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update

@Dao
interface UsuarioDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(usuario: Usuario): Long

    @Update
    suspend fun update(usuario: Usuario)

    @Query("SELECT * FROM Usuario WHERE correo = :correo")
    suspend fun getByCorreo(correo: String): Usuario?

    @Query("SELECT * FROM Usuario WHERE usuario_id = :id")
    suspend fun getById(id: Int): Usuario?
}
