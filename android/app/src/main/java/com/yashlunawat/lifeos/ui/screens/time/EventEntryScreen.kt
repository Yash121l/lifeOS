package com.yashlunawat.lifeos.ui.screens.time

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.models.TimeBlock
import com.yashlunawat.lifeos.data.services.SettingsManager
import com.yashlunawat.lifeos.ui.components.GlassCard
import com.yashlunawat.lifeos.ui.theme.*

enum class BlockCategory(val title: String, val colorHex: String, val identifier: String) {
    DeepWork("Deep Work", "5E5CE6", "deepWork"),
    Meeting("Meeting", "FF9F0A", "meeting"),
    Personal("Personal", "30D158", "personal"),
    Routine("Routine", "636366", "routine")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventEntryScreen(viewModel: LifeOSViewModel, onNavigateBack: () -> Unit) {
    var title by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf(BlockCategory.DeepWork) }
    var syncToCalendar by remember { mutableStateOf(SettingsManager.isCalendarSyncEnabled) }

    // Start UI
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("New Event") },
                navigationIcon = {
                    TextButton(onClick = onNavigateBack) {
                        Text("Cancel", color = DSTextSecondary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = DSBackground, titleContentColor = DSTextPrimary)
            )
        },
        containerColor = DSBackground
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).padding(horizontal = 16.dp, vertical = 24.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // Title
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Event Title", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                TextField(
                    value = title,
                    onValueChange = { title = it },
                    placeholder = { Text("What's happening?", color = DSTextSecondary) },
                    textStyle = MaterialTheme.typography.displaySmall,
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color.Transparent, unfocusedContainerColor = Color.Transparent,
                        focusedIndicatorColor = Color.Transparent, unfocusedIndicatorColor = Color.Transparent,
                        focusedTextColor = DSTextPrimary
                    ),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            // Category Picker
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Text("Category", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                LazyVerticalGrid(columns = GridCells.Fixed(2), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(BlockCategory.values()) { category ->
                        val isSelected = category == selectedCategory
                        val color = try { Color(android.graphics.Color.parseColor("#" + category.colorHex)) } catch (e: Exception) { DSAccent }
                        
                        Button(
                            onClick = { selectedCategory = category },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = if (isSelected) color.copy(alpha = 0.2f) else DSSurfaceLight,
                                contentColor = if (isSelected) color else DSTextSecondary
                            ),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.fillMaxWidth().height(48.dp).border(1.5.dp, if (isSelected) color else Color.Transparent, RoundedCornerShape(8.dp))
                        ) {
                            Text(category.title, fontSize = 12.sp, fontWeight = FontWeight.Medium)
                        }
                    }
                }
            }

            // Sync Configuration
            if (SettingsManager.isCalendarSyncEnabled) {
                GlassCard(padding = 0.dp) {
                    Row(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text("Sync to iOS Calendar", style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary)
                        Spacer(modifier = Modifier.weight(1f))
                        Switch(
                            checked = syncToCalendar,
                            onCheckedChange = { syncToCalendar = it },
                            colors = SwitchDefaults.colors(checkedTrackColor = try { Color(android.graphics.Color.parseColor("#" + selectedCategory.colorHex)) } catch (e: Exception) { DSAccent })
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.weight(1f))

            // Save Action
            val btnColor = try { Color(android.graphics.Color.parseColor("#" + selectedCategory.colorHex)) } catch (e: Exception) { DSAccent }
            Button(
                onClick = {
                    if (title.isNotBlank()) {
                        val now = System.currentTimeMillis()
                        viewModel.addTimeBlock(
                            TimeBlock(
                                title = title,
                                startTime = now,
                                endTime = now + 3600 * 1000L,
                                colorHex = selectedCategory.colorHex,
                                blockType = selectedCategory.identifier
                            )
                        )
                        onNavigateBack()
                    }
                },
                enabled = title.isNotBlank(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (title.isNotBlank()) btnColor else DSSurfaceLight,
                    contentColor = if (title.isNotBlank()) Color.White else DSTextTertiary
                ),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth().height(56.dp)
            ) {
                Text("Add Event", style = MaterialTheme.typography.titleMedium)
            }
        }
    }
}
