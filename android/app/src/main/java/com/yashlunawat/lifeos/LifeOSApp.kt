package com.yashlunawat.lifeos

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.compose.*
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.ui.screens.dashboard.DashboardScreen
import com.yashlunawat.lifeos.ui.screens.finance.FinanceScreen
import com.yashlunawat.lifeos.ui.screens.finance.TransactionEntryScreen
import com.yashlunawat.lifeos.ui.screens.knowledge.NoteEditorScreen
import com.yashlunawat.lifeos.ui.screens.knowledge.NotesScreen
import com.yashlunawat.lifeos.ui.screens.settings.SettingsScreen
import com.yashlunawat.lifeos.ui.screens.tasks.TaskDetailScreen
import com.yashlunawat.lifeos.ui.screens.tasks.TaskScreen
import com.yashlunawat.lifeos.ui.screens.time.EventEntryScreen
import com.yashlunawat.lifeos.ui.screens.time.TimeScreen
import com.yashlunawat.lifeos.ui.theme.DSBackground
import com.yashlunawat.lifeos.ui.theme.DSSurfaceLight
import com.yashlunawat.lifeos.ui.theme.DSTextSecondary
import com.yashlunawat.lifeos.ui.theme.DSTextPrimary
import com.yashlunawat.lifeos.ui.theme.DSAccent

sealed class Screen(val route: String, val title: String, val icon: ImageVector) {
    object Dashboard : Screen("dashboard", "Dashboard", Icons.Default.SpaceDashboard)
    object Time : Screen("time", "Time", Icons.Default.Schedule)
    object Tasks : Screen("tasks", "Tasks", Icons.Default.CheckCircle)
    object Finance : Screen("finance", "Finance", Icons.Default.AttachMoney)
    object Knowledge : Screen("knowledge", "Knowledge", Icons.Default.Lightbulb)
}

@Composable
fun LifeOSApp(viewModel: LifeOSViewModel) {
    val navController = rememberNavController()
    
    val items = listOf(
        Screen.Dashboard,
        Screen.Time,
        Screen.Tasks,
        Screen.Finance,
        Screen.Knowledge
    )

    Scaffold(
        bottomBar = {
            val navBackStackEntry by navController.currentBackStackEntryAsState()
            val currentRoute = navBackStackEntry?.destination?.route
            
            val showBottomBar = currentRoute in items.map { it.route }
            
            if (showBottomBar) {
                NavigationBar(
                    containerColor = DSBackground,
                    contentColor = DSTextSecondary
                ) {
                    items.forEach { screen ->
                        NavigationBarItem(
                            icon = { Icon(screen.icon, contentDescription = screen.title) },
                            label = { Text(screen.title) },
                            selected = currentRoute == screen.route,
                            onClick = {
                                navController.navigate(screen.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = DSAccent,
                                unselectedIconColor = DSTextSecondary,
                                selectedTextColor = DSAccent,
                                unselectedTextColor = DSTextSecondary,
                                indicatorColor = DSSurfaceLight
                            )
                        )
                    }
                }
            }
        },
        containerColor = DSBackground
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Dashboard.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Dashboard.route) {
                DashboardScreen(viewModel, onNavigateToSettings = { navController.navigate("settings") })
            }
            composable(Screen.Time.route) {
                TimeScreen(viewModel, onNavigateToEventEntry = { navController.navigate("eventEntry") })
            }
            composable(Screen.Tasks.route) {
                TaskScreen(
                    viewModel,
                    onNavigateToDetail = { task ->
                        navController.navigate(if (task != null) "taskDetail/${task.id}" else "taskDetail/new")
                    }
                )
            }
            composable(Screen.Finance.route) {
                FinanceScreen(viewModel, onNavigateToEntry = { navController.navigate("transactionEntry") })
            }
            composable(Screen.Knowledge.route) {
                NotesScreen(
                    viewModel,
                    onNavigateToEditor = { noteId ->
                        navController.navigate(if (noteId != null) "noteEditor/$noteId" else "noteEditor/new")
                    }
                )
            }
            
            // Sub-screens
            composable("settings") {
                SettingsScreen(onNavigateBack = { navController.popBackStack() })
            }
            composable("eventEntry") {
                EventEntryScreen(viewModel, onNavigateBack = { navController.popBackStack() })
            }
            composable("taskDetail/{taskId}") { backStackEntry ->
                val taskIdStr = backStackEntry.arguments?.getString("taskId")
                val taskId = if (taskIdStr == "new") null else taskIdStr?.toLongOrNull()
                TaskDetailScreen(taskId, viewModel, onNavigateBack = { navController.popBackStack() })
            }
            composable("transactionEntry") {
                TransactionEntryScreen(viewModel, onNavigateBack = { navController.popBackStack() })
            }
            composable("noteEditor/{noteId}") { backStackEntry ->
                val noteIdStr = backStackEntry.arguments?.getString("noteId")
                val noteId = if (noteIdStr == "new") null else noteIdStr?.toLongOrNull()
                NoteEditorScreen(noteId, viewModel, onNavigateBack = { navController.popBackStack() })
            }
        }
    }
}
