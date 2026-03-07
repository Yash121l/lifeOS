package com.yashlunawat.lifeos.ui.screens.tasks

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CapsuleShape
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.models.TaskItem
import com.yashlunawat.lifeos.ui.components.GlassCard
import com.yashlunawat.lifeos.ui.components.PrimaryButton
import com.yashlunawat.lifeos.ui.components.PrimaryButtonStyle
import com.yashlunawat.lifeos.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TaskDetailScreen(
    taskId: Long?,
    viewModel: LifeOSViewModel,
    onNavigateBack: () -> Unit
) {
    val tasks by viewModel.tasks.collectAsState()
    val initialTask = tasks.find { it.id == taskId } ?: TaskItem(title = "")
    var task by remember { mutableStateOf(initialTask) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (taskId == null) "New Task" else "Task Details") },
                actions = {
                    TextButton(onClick = {
                        if (taskId == null) {
                            viewModel.addTask(task)
                        } else {
                            viewModel.updateTask(task)
                        }
                        onNavigateBack()
                    }, enabled = task.title.isNotBlank()) {
                        Text("Save", color = if (task.title.isNotBlank()) DSAccent else DSTextTertiary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = DSBackground,
                    titleContentColor = DSTextPrimary
                )
            )
        },
        containerColor = DSBackground
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(bottom = 32.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // Title
            Column(modifier = Modifier.padding(horizontal = 16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Title", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                TextField(
                    value = task.title,
                    onValueChange = { task = task.copy(title = it) },
                    placeholder = { Text("What needs to be done?", color = DSTextSecondary) },
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color.Transparent,
                        unfocusedContainerColor = Color.Transparent,
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent,
                        focusedTextColor = DSTextPrimary
                    ),
                    textStyle = MaterialTheme.typography.titleLarge,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            HorizontalDivider(color = DSCardBorder)

            // Priority & Energy
            Row(modifier = Modifier.padding(horizontal = 16.dp)) {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text("Priority", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        val labels = listOf("Low", "Med", "High")
                        val colors = listOf(DSEnergyLow, DSAccent, DSError)
                        labels.forEachIndexed { level, label ->
                            val isSelected = task.priority == level
                            Button(
                                onClick = { task = task.copy(priority = level) },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = if (isSelected) colors[level] else DSSurfaceLight,
                                    contentColor = if (isSelected) Color.White else DSTextSecondary
                                ),
                                shape = CapsuleShape,
                                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp),
                                modifier = Modifier.height(32.dp)
                            ) {
                                Text(label, style = MaterialTheme.typography.labelSmall)
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.weight(1f))

                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text("Energy", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        val colors = listOf(DSEnergyLow, DSEnergyMedium, DSEnergyHigh)
                        for (level in 1..3) {
                            val isSelected = task.energyLevel == level
                            IconButton(
                                onClick = { task = task.copy(energyLevel = level) },
                                modifier = Modifier
                                    .size(36.dp)
                                    .background(
                                        if (isSelected) colors[level - 1].copy(alpha = 0.15f) else DSSurfaceLight,
                                        CircleShape
                                    )
                            ) {
                                Icon(Icons.Default.Bolt, contentDescription = null, tint = if (isSelected) colors[level - 1] else DSTextTertiary)
                            }
                        }
                    }
                }
            }

            HorizontalDivider(color = DSCardBorder)

            // Time Estimate
            Column(modifier = Modifier.padding(horizontal = 16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Time Estimate", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    listOf(15, 30, 60, 120).forEach { minutes ->
                        val label = if (minutes < 60) "${minutes}m" else "${minutes / 60}h"
                        val isSelected = task.timeEstimateMinutes == minutes
                        Button(
                            onClick = { task = task.copy(timeEstimateMinutes = minutes) },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = if (isSelected) DSAccent else DSSurfaceLight,
                                contentColor = if (isSelected) Color.White else DSTextSecondary
                            ),
                            shape = CapsuleShape,
                            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
                            modifier = Modifier.height(32.dp)
                        ) {
                            Text(label, style = MaterialTheme.typography.labelSmall)
                        }
                    }
                }
            }

            HorizontalDivider(color = DSCardBorder)

            // Notes
            Column(modifier = Modifier.padding(horizontal = 16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Notes", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                TextField(
                    value = task.notes,
                    onValueChange = { task = task.copy(notes = it) },
                    placeholder = { Text("Add notes...", color = DSTextSecondary) },
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color.Transparent,
                        unfocusedContainerColor = Color.Transparent,
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent,
                        focusedTextColor = DSTextPrimary
                    ),
                    modifier = Modifier.fillMaxWidth().height(150.dp)
                )
            }

            // Completed Toggle
            Box(modifier = Modifier.padding(horizontal = 16.dp)) {
                GlassCard(padding = 16.dp) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = if (task.isCompleted) DSSuccess else DSTextTertiary,
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        Text("Mark as completed", style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary)
                        Spacer(modifier = Modifier.weight(1f))
                        Switch(
                            checked = task.isCompleted,
                            onCheckedChange = { task = task.copy(isCompleted = it) },
                            colors = SwitchDefaults.colors(checkedTrackColor = DSSuccess)
                        )
                    }
                }
            }
        }
    }
}
