package com.certificationmanager.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.certificationmanager.data.entity.Certification
import com.certificationmanager.ui.viewmodel.CertificationViewModel
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CertificationDetailScreen(
    certificationId: String,
    onNavigateBack: () -> Unit,
    viewModel: CertificationViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var showDeleteDialog by remember { mutableStateOf(false) }
    
    val certification = uiState.certifications.find { it.id == certificationId }
    val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
    val daysUntilExpiration = certification?.let { calculateDaysUntilExpiration(it.expirationDate) } ?: 0
    val isExpiringSoon = daysUntilExpiration <= 30

    if (certification == null) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator()
        }
        return
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Certification Details") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { /* TODO: Edit functionality */ }) {
                        Icon(Icons.Default.Edit, contentDescription = "Edit")
                    }
                    IconButton(onClick = { showDeleteDialog = true }) {
                        Icon(Icons.Default.Delete, contentDescription = "Delete")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Status Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = if (isExpiringSoon) Color.Red.copy(alpha = 0.1f) else MaterialTheme.colorScheme.primaryContainer
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = if (daysUntilExpiration <= 0) "EXPIRED" else "$daysUntilExpiration days remaining",
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        color = if (isExpiringSoon) Color.Red else MaterialTheme.colorScheme.onPrimaryContainer
                    )
                    Text(
                        text = "Expires: ${dateFormat.format(certification.expirationDate)}",
                        style = MaterialTheme.typography.bodyLarge
                    )
                }
            }

            // Basic Information
            Card(
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text(
                        text = "Basic Information",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    
                    InfoRow("Name", certification.name)
                    InfoRow("Organization", certification.issuingOrganization)
                    InfoRow("Issue Date", dateFormat.format(certification.issueDate))
                    InfoRow("Expiration Date", dateFormat.format(certification.expirationDate))
                }
            }

            // Renewal Information
            if (certification.renewalUrl != null || certification.pduUrl != null) {
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(
                            text = "Renewal Resources",
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        
                        if (certification.renewalUrl != null) {
                            Button(
                                onClick = { /* TODO: Open URL */ },
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Text("Renew Certification")
                            }
                            Spacer(modifier = Modifier.height(8.dp))
                        }
                        
                        if (certification.pduUrl != null) {
                            OutlinedButton(
                                onClick = { /* TODO: Open URL */ },
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Text("Get PDUs")
                            }
                        }
                    }
                }
            }

            // Reminder Settings
            Card(
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text(
                        text = "Reminder Settings",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    
                    Text(
                        text = "Reminders will be sent at:",
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    
                    certification.reminderIntervals.forEach { days ->
                        Text(
                            text = "• $days days before expiration",
                            style = MaterialTheme.typography.bodyMedium,
                            modifier = Modifier.padding(start = 16.dp)
                        )
                    }
                }
            }
        }
    }

    // Delete Confirmation Dialog
    if (showDeleteDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteDialog = false },
            title = { Text("Delete Certification") },
            text = { Text("Are you sure you want to delete this certification? This action cannot be undone.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        viewModel.deleteCertification(certification)
                        onNavigateBack()
                    }
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }
}

@Composable
private fun InfoRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
    ) {
        Text(
            text = "$label:",
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.width(120.dp)
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium
        )
    }
}

private fun calculateDaysUntilExpiration(expirationDate: Date): Int {
    val currentDate = Date()
    val diffInMilliseconds = expirationDate.time - currentDate.time
    return (diffInMilliseconds / (24 * 60 * 60 * 1000)).toInt()
}