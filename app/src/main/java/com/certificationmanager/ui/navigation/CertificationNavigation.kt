package com.certificationmanager.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.certificationmanager.ui.screens.CertificationListScreen
import com.certificationmanager.ui.screens.AddCertificationScreen
import com.certificationmanager.ui.screens.CertificationDetailScreen

@Composable
fun CertificationNavigation(
    navController: NavHostController = rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = "certification_list"
    ) {
        composable("certification_list") {
            CertificationListScreen(
                onNavigateToAdd = { navController.navigate("add_certification") },
                onNavigateToDetail = { id -> navController.navigate("certification_detail/$id") }
            )
        }
        composable("add_certification") {
            AddCertificationScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }
        composable("certification_detail/{id}") { backStackEntry ->
            val certificationId = backStackEntry.arguments?.getString("id") ?: ""
            CertificationDetailScreen(
                certificationId = certificationId,
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}