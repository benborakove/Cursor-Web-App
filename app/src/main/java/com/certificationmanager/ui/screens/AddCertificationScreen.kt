package com.certificationmanager.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.certificationmanager.data.entity.Certification
import com.certificationmanager.data.entity.CertificationTemplate
import com.certificationmanager.ui.components.CertificationTemplateCard
import com.certificationmanager.ui.components.CustomCertificationForm
import com.certificationmanager.ui.viewmodel.CertificationViewModel
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddCertificationScreen(
    onNavigateBack: () -> Unit,
    viewModel: CertificationViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var showCustomForm by remember { mutableStateOf(false) }
    var selectedTemplate by remember { mutableStateOf<CertificationTemplate?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Add Certification") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            if (showCustomForm) {
                CustomCertificationForm(
                    template = selectedTemplate,
                    onSave = { certification ->
                        viewModel.addCertification(certification)
                        onNavigateBack()
                    },
                    onCancel = { 
                        showCustomForm = false
                        selectedTemplate = null
                    }
                )
            } else {
                // Template Selection
                Text(
                    text = "Choose a certification template or add custom",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(16.dp)
                )

                // Category Filter
                CategoryFilter(
                    categories = listOf("All", "IT", "Project Management", "Security", "Cloud", "Other"),
                    selectedCategory = uiState.selectedCategory,
                    onCategorySelected = viewModel::filterByCategory
                )

                // Templates List
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    val templatesToShow = if (uiState.filteredTemplates.isNotEmpty()) {
                        uiState.filteredTemplates
                    } else {
                        uiState.templates
                    }

                    items(templatesToShow) { template ->
                        CertificationTemplateCard(
                            template = template,
                            onClick = {
                                selectedTemplate = template
                                showCustomForm = true
                            }
                        )
                    }

                    // Custom option
                    item {
                        Card(
                            onClick = { showCustomForm = true },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "+ Add Custom Certification",
                                    style = MaterialTheme.typography.titleMedium,
                                    color = MaterialTheme.colorScheme.primary
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}