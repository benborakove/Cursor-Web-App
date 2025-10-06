package com.certificationmanager.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.certificationmanager.data.entity.Certification
import com.certificationmanager.ui.components.CertificationCard
import com.certificationmanager.ui.components.CategoryFilter
import com.certificationmanager.ui.viewmodel.CertificationViewModel
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CertificationListScreen(
    onNavigateToAdd: () -> Unit,
    onNavigateToDetail: (String) -> Unit,
    viewModel: CertificationViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("My Certifications") }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onNavigateToAdd
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add Certification")
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Category Filter
            CategoryFilter(
                categories = listOf("All", "IT", "Project Management", "Security", "Cloud", "Other"),
                selectedCategory = uiState.selectedCategory,
                onCategorySelected = viewModel::filterByCategory
            )

            // Certifications List
            if (uiState.isLoading) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            } else if (uiState.certifications.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "No certifications yet",
                            style = MaterialTheme.typography.headlineSmall
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "Add your first certification to get started",
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(uiState.certifications) { certification ->
                        CertificationCard(
                            certification = certification,
                            onClick = { onNavigateToDetail(certification.id) }
                        )
                    }
                }
            }
        }
    }
}