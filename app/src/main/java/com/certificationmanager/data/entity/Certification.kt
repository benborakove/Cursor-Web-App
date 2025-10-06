package com.certificationmanager.data.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date

@Entity(tableName = "certifications")
data class Certification(
    @PrimaryKey
    val id: String,
    val userId: String,
    val name: String,
    val issuingOrganization: String,
    val issueDate: Date,
    val expirationDate: Date,
    val certificateImagePath: String? = null,
    val documentPath: String? = null,
    val renewalUrl: String? = null,
    val pduUrl: String? = null,
    val reminderIntervals: List<Int> = listOf(90, 60, 30, 7), // days before expiration
    val isActive: Boolean = true,
    val createdAt: Date = Date(),
    val updatedAt: Date = Date()
)