package com.certificationmanager.data.dao

import androidx.room.*
import com.certificationmanager.data.entity.Certification
import kotlinx.coroutines.flow.Flow

@Dao
interface CertificationDao {
    @Query("SELECT * FROM certifications WHERE userId = :userId AND isActive = 1 ORDER BY expirationDate ASC")
    fun getCertificationsByUser(userId: String): Flow<List<Certification>>

    @Query("SELECT * FROM certifications WHERE id = :id")
    suspend fun getCertificationById(id: String): Certification?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCertification(certification: Certification)

    @Update
    suspend fun updateCertification(certification: Certification)

    @Delete
    suspend fun deleteCertification(certification: Certification)

    @Query("UPDATE certifications SET isActive = 0 WHERE id = :id")
    suspend fun deactivateCertification(id: String)

    @Query("SELECT * FROM certifications WHERE expirationDate BETWEEN :startDate AND :endDate AND isActive = 1")
    suspend fun getCertificationsExpiringBetween(startDate: java.util.Date, endDate: java.util.Date): List<Certification>
}