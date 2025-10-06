package com.certificationmanager.data.repository

import com.certificationmanager.data.dao.CertificationTemplateDao
import com.certificationmanager.data.entity.CertificationTemplate
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CertificationTemplateRepository @Inject constructor(
    private val certificationTemplateDao: CertificationTemplateDao
) {
    fun getAllTemplates(): Flow<List<CertificationTemplate>> {
        return certificationTemplateDao.getAllTemplates()
    }

    fun getTemplatesByCategory(category: String): Flow<List<CertificationTemplate>> {
        return certificationTemplateDao.getTemplatesByCategory(category)
    }

    fun getPopularTemplates(): Flow<List<CertificationTemplate>> {
        return certificationTemplateDao.getPopularTemplates()
    }

    fun getCategories(): Flow<List<String>> {
        return certificationTemplateDao.getCategories()
    }

    suspend fun insertTemplate(template: CertificationTemplate) {
        certificationTemplateDao.insertTemplate(template)
    }

    suspend fun insertTemplates(templates: List<CertificationTemplate>) {
        certificationTemplateDao.insertTemplates(templates)
    }

    suspend fun getTemplateById(id: String): CertificationTemplate? {
        return certificationTemplateDao.getTemplateById(id)
    }
}