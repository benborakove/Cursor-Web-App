package com.certificationmanager.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.certificationmanager.data.entity.Certification
import com.certificationmanager.data.entity.CertificationTemplate
import java.util.*

@Composable
fun CustomCertificationForm(
    template: CertificationTemplate?,
    onSave: (Certification) -> Unit,
    onCancel: () -> Unit
) {
    var name by remember { mutableStateOf(template?.name ?: "") }
    var organization by remember { mutableStateOf(template?.issuingOrganization ?: "") }
    var issueDate by remember { mutableStateOf(Date()) }
    var expirationDate by remember { mutableStateOf(Date()) }
    var renewalUrl by remember { mutableStateOf(template?.renewalUrl ?: "") }
    var pduUrl by remember { mutableStateOf(template?.pduUrl ?: "") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Certification Details",
            style = MaterialTheme.typography.headlineSmall
        )

        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Certification Name") },
            modifier = Modifier.fillMaxWidth()
        )

        OutlinedTextField(
            value = organization,
            onValueChange = { organization = it },
            label = { Text("Issuing Organization") },
            modifier = Modifier.fillMaxWidth()
        )

        OutlinedTextField(
            value = renewalUrl,
            onValueChange = { renewalUrl = it },
            label = { Text("Renewal URL (Optional)") },
            modifier = Modifier.fillMaxWidth()
        )

        OutlinedTextField(
            value = pduUrl,
            onValueChange = { pduUrl = it },
            label = { Text("PDU Resource URL (Optional)") },
            modifier = Modifier.fillMaxWidth()
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedButton(
                onClick = onCancel,
                modifier = Modifier.weight(1f)
            ) {
                Text("Cancel")
            }

            Button(
                onClick = {
                    val certification = Certification(
                        id = UUID.randomUUID().toString(),
                        userId = "user_1", // In a real app, this would come from authentication
                        name = name,
                        issuingOrganization = organization,
                        issueDate = issueDate,
                        expirationDate = expirationDate,
                        renewalUrl = renewalUrl.takeIf { it.isNotEmpty() },
                        pduUrl = pduUrl.takeIf { it.isNotEmpty() }
                    )
                    onSave(certification)
                },
                modifier = Modifier.weight(1f),
                enabled = name.isNotEmpty() && organization.isNotEmpty()
            ) {
                Text("Save")
            }
        }
    }
}