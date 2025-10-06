package com.certificationmanager.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.certificationmanager.MainActivity
import com.certificationmanager.R
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class NotificationService @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Certification Reminders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for certification renewals"
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun showCertificationReminder(
        certificationName: String,
        daysUntilExpiration: Int,
        certificationId: String
    ) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("certification_id", certificationId)
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            certificationId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val message = if (daysUntilExpiration <= 0) {
            "Your $certificationName certification has expired!"
        } else {
            "Your $certificationName certification expires in $daysUntilExpiration days"
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("Certification Reminder")
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(certificationId.hashCode(), notification)
    }

    companion object {
        private const val CHANNEL_ID = "certification_reminders"
    }
}