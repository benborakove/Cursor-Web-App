package com.certificationmanager.data.dao

import androidx.room.*
import com.certificationmanager.data.entity.Reminder
import kotlinx.coroutines.flow.Flow

@Dao
interface ReminderDao {
    @Query("SELECT * FROM reminders WHERE certificationId = :certificationId ORDER BY scheduledDate ASC")
    fun getRemindersByCertification(certificationId: String): Flow<List<Reminder>>

    @Query("SELECT * FROM reminders WHERE scheduledDate <= :currentDate AND isSent = 0")
    suspend fun getPendingReminders(currentDate: java.util.Date): List<Reminder>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertReminder(reminder: Reminder)

    @Update
    suspend fun updateReminder(reminder: Reminder)

    @Delete
    suspend fun deleteReminder(reminder: Reminder)

    @Query("DELETE FROM reminders WHERE certificationId = :certificationId")
    suspend fun deleteRemindersByCertification(certificationId: String)

    @Query("UPDATE reminders SET isSent = 1 WHERE id = :reminderId")
    suspend fun markReminderAsSent(reminderId: String)
}