package com.certificationmanager.data.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "certification_templates")
data class CertificationTemplate(
    @PrimaryKey
    val id: String,
    val name: String,
    val issuingOrganization: String,
    val category: String,
    val validityPeriodYears: Int,
    val renewalUrl: String? = null,
    val pduUrl: String? = null,
    val description: String? = null,
    val isPopular: Boolean = false
)