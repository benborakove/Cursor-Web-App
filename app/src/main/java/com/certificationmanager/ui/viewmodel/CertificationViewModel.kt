package com.certificationmanager.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.certificationmanager.data.entity.Certification
import com.certificationmanager.data.entity.CertificationTemplate
import com.certificationmanager.data.repository.CertificationRepository
import com.certificationmanager.data.repository.CertificationTemplateRepository
import com.certificationmanager.data.repository.ReminderRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.*
import javax.inject.Inject

@HiltViewModel
class CertificationViewModel @Inject constructor(
    private val certificationRepository: CertificationRepository,
    private val templateRepository: CertificationTemplateRepository,
    private val reminderRepository: ReminderRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CertificationUiState())
    val uiState: StateFlow<CertificationUiState> = _uiState.asStateFlow()

    private val userId = "user_1" // In a real app, this would come from authentication

    init {
        loadCertifications()
        loadTemplates()
    }

    private fun loadCertifications() {
        viewModelScope.launch {
            certificationRepository.getCertificationsByUser(userId)
                .collect { certifications ->
                    _uiState.value = _uiState.value.copy(
                        certifications = certifications,
                        isLoading = false
                    )
                }
        }
    }

    private fun loadTemplates() {
        viewModelScope.launch {
            templateRepository.getAllTemplates()
                .collect { templates ->
                    _uiState.value = _uiState.value.copy(
                        templates = templates
                    )
                }
        }
    }

    fun addCertification(certification: Certification) {
        viewModelScope.launch {
            certificationRepository.insertCertification(certification)
            scheduleReminders(certification)
        }
    }

    fun updateCertification(certification: Certification) {
        viewModelScope.launch {
            certificationRepository.updateCertification(certification)
            // Reschedule reminders
            reminderRepository.deleteRemindersByCertification(certification.id)
            scheduleReminders(certification)
        }
    }

    fun deleteCertification(certification: Certification) {
        viewModelScope.launch {
            certificationRepository.deleteCertification(certification)
            reminderRepository.deleteRemindersByCertification(certification.id)
        }
    }

    private suspend fun scheduleReminders(certification: Certification) {
        val calendar = Calendar.getInstance()
        calendar.time = certification.expirationDate
        
        certification.reminderIntervals.forEach { daysBefore ->
            calendar.time = certification.expirationDate
            calendar.add(Calendar.DAY_OF_MONTH, -daysBefore)
            
            val reminderDate = calendar.time
            if (reminderDate.after(Date())) {
                val reminder = com.certificationmanager.data.entity.Reminder(
                    id = UUID.randomUUID().toString(),
                    certificationId = certification.id,
                    reminderType = com.certificationmanager.data.entity.ReminderType.PUSH_NOTIFICATION,
                    scheduledDate = reminderDate
                )
                reminderRepository.insertReminder(reminder)
            }
        }
    }

    fun filterByCategory(category: String) {
        viewModelScope.launch {
            if (category == "All") {
                templateRepository.getAllTemplates().collect { templates ->
                    _uiState.value = _uiState.value.copy(
                        filteredTemplates = templates,
                        selectedCategory = category
                    )
                }
            } else {
                templateRepository.getTemplatesByCategory(category).collect { templates ->
                    _uiState.value = _uiState.value.copy(
                        filteredTemplates = templates,
                        selectedCategory = category
                    )
                }
            }
        }
    }
}

data class CertificationUiState(
    val certifications: List<Certification> = emptyList(),
    val templates: List<CertificationTemplate> = emptyList(),
    val filteredTemplates: List<CertificationTemplate> = emptyList(),
    val selectedCategory: String = "All",
    val isLoading: Boolean = true,
    val error: String? = null
)