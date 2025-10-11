package com.example.mi_app.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(
    entities = [
        Usuario::class,
        Paciente::class,
        Medico::class,
        RelacionMedicoPaciente::class,
        ResultadoPrueba::class,
        PruebaConfiguracion::class,
        Consentimiento::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {

    abstract fun usuarioDao(): UsuarioDao
    abstract fun pacienteDao(): PacienteDao
    abstract fun medicoDao(): MedicoDao
    abstract fun relacionMedicoPacienteDao(): RelacionMedicoPacienteDao
    abstract fun resultadoPruebaDao(): ResultadoPruebaDao
    abstract fun consentimientoDao(): ConsentimientoDao
    // abstract fun pruebaConfiguracionDao(): PruebaConfiguracionDao // Descomentar si se crea el DAO

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "parkinson_app_database"
                )
                .fallbackToDestructiveMigration() // Usar con cuidado en producción
                .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
