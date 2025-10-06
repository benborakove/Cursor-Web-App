package com.certificationmanager.data.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date

@Entity(tableName = "reminders")
data class Reminder(
    @PrimaryKey
    val id: String,
    val certificationId: String,
    val reminderType: ReminderType,
    val scheduledDate: Date,
    val isSent: Boolean = false,
    val createdAt: Date = Date()
)

enum class ReminderType {
    PUSH_NOTIFICATION,
    EMAIL
}