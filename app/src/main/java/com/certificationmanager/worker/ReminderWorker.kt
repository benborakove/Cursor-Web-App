package com.certificationmanager.worker

import android.content.Context
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.certificationmanager.data.repository.CertificationRepository
import com.certificationmanager.data.repository.ReminderRepository
import com.certificationmanager.service.NotificationService
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject
import java.util.*

@HiltWorker
class ReminderWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted workerParams: WorkerParameters,
    private val certificationRepository: CertificationRepository,
    private val reminderRepository: ReminderRepository,
    private val notificationService: NotificationService
) : CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): Result {
        return try {
            val currentDate = Date()
            val pendingReminders = reminderRepository.getPendingReminders(currentDate)

            for (reminder in pendingReminders) {
                val certification = certificationRepository.getCertificationById(reminder.certificationId)
                
                if (certification != null) {
                    val daysUntilExpiration = calculateDaysUntilExpiration(certification.expirationDate)
                    
                    notificationService.showCertificationReminder(
                        certificationName = certification.name,
                        daysUntilExpiration = daysUntilExpiration,
                        certificationId = certification.id
                    )
                    
                    reminderRepository.markReminderAsSent(reminder.id)
                }
            }
            
            Result.success()
        } catch (e: Exception) {
            Result.failure()
        }
    }

    private fun calculateDaysUntilExpiration(expirationDate: Date): Int {
        val currentDate = Date()
        val diffInMilliseconds = expirationDate.time - currentDate.time
        return (diffInMilliseconds / (24 * 60 * 60 * 1000)).toInt()
    }
}