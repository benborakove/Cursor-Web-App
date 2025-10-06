package com.certificationmanager.data.database

import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import android.content.Context
import com.certificationmanager.data.converter.Converters
import com.certificationmanager.data.dao.CertificationDao
import com.certificationmanager.data.dao.CertificationTemplateDao
import com.certificationmanager.data.dao.ReminderDao
import com.certificationmanager.data.entity.Certification
import com.certificationmanager.data.entity.CertificationTemplate
import com.certificationmanager.data.entity.Reminder

@Database(
    entities = [Certification::class, Reminder::class, CertificationTemplate::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class CertificationDatabase : RoomDatabase() {
    abstract fun certificationDao(): CertificationDao
    abstract fun reminderDao(): ReminderDao
    abstract fun certificationTemplateDao(): CertificationTemplateDao

    companion object {
        @Volatile
        private var INSTANCE: CertificationDatabase? = null

        fun getDatabase(context: Context): CertificationDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    CertificationDatabase::class.java,
                    "certification_database"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}