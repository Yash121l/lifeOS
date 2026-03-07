package com.yashlunawat.lifeos.ui.screens.settings

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.IosShare
import com.yashlunawat.lifeos.data.services.SettingsManager
import com.yashlunawat.lifeos.ui.components.GlassCard
import com.yashlunawat.lifeos.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(onNavigateBack: () -> Unit) {
    var currency by remember { mutableStateOf(SettingsManager.currencyCode) }
    var syncCalendar by remember { mutableStateOf(SettingsManager.isCalendarSyncEnabled) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                actions = {
                    TextButton(onClick = onNavigateBack) {
                        Text("Done", color = DSAccent)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = DSBackground, titleContentColor = DSTextPrimary)
            )
        },
        containerColor = DSBackground
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 24.dp),
            verticalArrangement = Arrangement.spacedBy(32.dp)
        ) {
            // Preferences
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("PREFERENCES", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, modifier = Modifier.padding(start = 8.dp))
                GlassCard(padding = 0.dp) {
                    Column {
                        Row(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text("Currency", style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary)
                            Spacer(modifier = Modifier.weight(1f))
                            var expanded by remember { mutableStateOf(false) }
                            Box {
                                TextButton(onClick = { expanded = true }) {
                                    Text(currency, color = DSAccent)
                                }
                                DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                                    SettingsManager.availableCurrencies.forEach { code ->
                                        DropdownMenuItem(text = { Text(code) }, onClick = {
                                            currency = code
                                            SettingsManager.currencyCode = code
                                            expanded = false
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Integrations
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("INTEGRATIONS", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, modifier = Modifier.padding(start = 8.dp))
                GlassCard(padding = 0.dp) {
                    Row(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.CalendarMonth, contentDescription = null, tint = DSAccent, modifier = Modifier.size(24.dp))
                        Spacer(modifier = Modifier.width(16.dp))
                        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text("Calendar Sync", style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary)
                            Text("Sync tasks and blocks with device Calendar", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                        }
                        Switch(
                            checked = syncCalendar,
                            onCheckedChange = {
                                syncCalendar = it
                                SettingsManager.isCalendarSyncEnabled = it
                            },
                            colors = SwitchDefaults.colors(checkedTrackColor = DSSuccess)
                        )
                    }
                }
            }

            // Account
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("ACCOUNT & ACCESS", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, modifier = Modifier.padding(start = 8.dp))
                GlassCard(padding = 0.dp) {
                    Column {
                        SettingsActionRow("Manage Subscription", Icons.Default.ChevronRight, DSTextPrimary, DSTextTertiary) { }
                        HorizontalDivider(color = DSCardBorder)
                        SettingsActionRow("Export Data", Icons.Default.IosShare, DSTextPrimary, DSTextTertiary) { }
                        HorizontalDivider(color = DSCardBorder)
                        SettingsActionRow("Sign Out", null, DSError, DSError) { }
                    }
                }
            }

            Text("LifeOS Version 1.0.0", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, modifier = Modifier.align(Alignment.CenterHorizontally).padding(top = 32.dp))
        }
    }
}

@Composable
fun SettingsActionRow(title: String, icon: androidx.compose.ui.graphics.vector.ImageVector?, textColor: Color, iconColor: Color, onClick: () -> Unit) {
    Surface(onClick = onClick, color = Color.Transparent) {
        Row(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(title, style = MaterialTheme.typography.bodyLarge, color = textColor)
            Spacer(modifier = Modifier.weight(1f))
            if (icon != null) {
                Icon(icon, contentDescription = null, tint = iconColor, modifier = Modifier.size(16.dp))
            }
        }
    }
}
