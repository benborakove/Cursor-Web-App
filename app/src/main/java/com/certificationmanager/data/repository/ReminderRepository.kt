package com.certificationmanager.data.repository

import com.certificationmanager.data.dao.ReminderDao
import com.certificationmanager.data.entity.Reminder
import kotlinx.coroutines.flow.Flow
import java.util.Date
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ReminderRepository @Inject constructor(
    private val reminderDao: ReminderDao
) {
    fun getRemindersByCertification(certificationId: String): Flow<List<Reminder>> {
        return reminderDao.getRemindersByCertification(certificationId)
    }

    suspend fun getPendingReminders(currentDate: Date): List<Reminder> {
        return reminderDao.getPendingReminders(currentDate)
    }

    suspend fun insertReminder(reminder: Reminder) {
        reminderDao.insertReminder(reminder)
    }

    suspend fun updateReminder(reminder: Reminder) {
        reminderDao.updateReminder(reminder)
    }

    suspend fun deleteReminder(reminder: Reminder) {
        reminderDao.deleteReminder(reminder)
    }

    suspend fun deleteRemindersByCertification(certificationId: String) {
        reminderDao.deleteRemindersByCertification(certificationId)
    }

    suspend fun markReminderAsSent(reminderId: String) {
        reminderDao.markReminderAsSent(reminderId)
    }
}