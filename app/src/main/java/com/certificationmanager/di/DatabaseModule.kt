package com.certificationmanager.di

import android.content.Context
import androidx.room.Room
import com.certificationmanager.data.dao.CertificationDao
import com.certificationmanager.data.dao.CertificationTemplateDao
import com.certificationmanager.data.dao.ReminderDao
import com.certificationmanager.data.database.CertificationDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideCertificationDatabase(@ApplicationContext context: Context): CertificationDatabase {
        return Room.databaseBuilder(
            context.applicationContext,
            CertificationDatabase::class.java,
            "certification_database"
        ).build()
    }

    @Provides
    fun provideCertificationDao(database: CertificationDatabase): CertificationDao {
        return database.certificationDao()
    }

    @Provides
    fun provideReminderDao(database: CertificationDatabase): ReminderDao {
        return database.reminderDao()
    }

    @Provides
    fun provideCertificationTemplateDao(database: CertificationDatabase): CertificationTemplateDao {
        return database.certificationTemplateDao()
    }
}