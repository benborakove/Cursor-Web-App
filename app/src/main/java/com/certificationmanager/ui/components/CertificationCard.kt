package com.certificationmanager.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.certificationmanager.data.entity.Certification
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun CertificationCard(
    certification: Certification,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
    val daysUntilExpiration = calculateDaysUntilExpiration(certification.expirationDate)
    val isExpiringSoon = daysUntilExpiration <= 30

    Card(
        onClick = onClick,
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Column(
                    modifier = Modifier.weight(1f)
                ) {
                    Text(
                        text = certification.name,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = certification.issuingOrganization,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                
                if (isExpiringSoon) {
                    Surface(
                        color = if (daysUntilExpiration <= 7) Color.Red else Color.Orange,
                        shape = RoundedCornerShape(16.dp)
                    ) {
                        Text(
                            text = if (daysUntilExpiration <= 0) "EXPIRED" else "$daysUntilExpiration days",
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                            style = MaterialTheme.typography.labelSmall,
                            color = Color.White
                        )
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "Expires: ${dateFormat.format(certification.expirationDate)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = if (isExpiringSoon) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurfaceVariant
                )
                
                Text(
                    text = "Issued: ${dateFormat.format(certification.issueDate)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

private fun calculateDaysUntilExpiration(expirationDate: Date): Int {
    val currentDate = Date()
    val diffInMilliseconds = expirationDate.time - currentDate.time
    return (diffInMilliseconds / (24 * 60 * 60 * 1000)).toInt()
}