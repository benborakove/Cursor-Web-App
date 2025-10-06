package com.certificationmanager.data.dao

import androidx.room.*
import com.certificationmanager.data.entity.CertificationTemplate
import kotlinx.coroutines.flow.Flow

@Dao
interface CertificationTemplateDao {
    @Query("SELECT * FROM certification_templates ORDER BY isPopular DESC, name ASC")
    fun getAllTemplates(): Flow<List<CertificationTemplate>>

    @Query("SELECT * FROM certification_templates WHERE category = :category ORDER BY isPopular DESC, name ASC")
    fun getTemplatesByCategory(category: String): Flow<List<CertificationTemplate>>

    @Query("SELECT * FROM certification_templates WHERE isPopular = 1 ORDER BY name ASC")
    fun getPopularTemplates(): Flow<List<CertificationTemplate>>

    @Query("SELECT DISTINCT category FROM certification_templates ORDER BY category ASC")
    fun getCategories(): Flow<List<String>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTemplate(template: CertificationTemplate)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTemplates(templates: List<CertificationTemplate>)

    @Query("SELECT * FROM certification_templates WHERE id = :id")
    suspend fun getTemplateById(id: String): CertificationTemplate?
}