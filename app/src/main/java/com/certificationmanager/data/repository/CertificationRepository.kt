package com.certificationmanager.data.repository

import com.certificationmanager.data.dao.CertificationDao
import com.certificationmanager.data.entity.Certification
import kotlinx.coroutines.flow.Flow
import java.util.Date
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CertificationRepository @Inject constructor(
    private val certificationDao: CertificationDao
) {
    fun getCertificationsByUser(userId: String): Flow<List<Certification>> {
        return certificationDao.getCertificationsByUser(userId)
    }

    suspend fun getCertificationById(id: String): Certification? {
        return certificationDao.getCertificationById(id)
    }

    suspend fun insertCertification(certification: Certification) {
        certificationDao.insertCertification(certification)
    }

    suspend fun updateCertification(certification: Certification) {
        certificationDao.updateCertification(certification)
    }

    suspend fun deleteCertification(certification: Certification) {
        certificationDao.deleteCertification(certification)
    }

    suspend fun deactivateCertification(id: String) {
        certificationDao.deactivateCertification(id)
    }

    suspend fun getCertificationsExpiringBetween(startDate: Date, endDate: Date): List<Certification> {
        return certificationDao.getCertificationsExpiringBetween(startDate, endDate)
    }
}