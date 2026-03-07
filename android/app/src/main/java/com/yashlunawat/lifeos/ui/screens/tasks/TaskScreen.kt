package com.yashlunawat.lifeos.ui.screens.tasks

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CapsuleShape
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.horizontalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddCircle
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.Warning
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.models.Project
import com.yashlunawat.lifeos.data.models.TaskItem
import com.yashlunawat.lifeos.ui.components.GlassCard
import com.yashlunawat.lifeos.ui.theme.*
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

enum class TaskSegment(val title: String) {
    Today("Today"),
    Upcoming("Upcoming"),
    Projects("Projects"),
    Matrix("Matrix")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TaskScreen(viewModel: LifeOSViewModel, onNavigateToDetail: (TaskItem?) -> Unit) {
    val tasks by viewModel.tasks.collectAsState()
    val projects by viewModel.projects.collectAsState()
    var selectedSegment by remember { mutableStateOf(TaskSegment.Today) }

    val todayTasks = remember(tasks) {
        val now = System.currentTimeMillis()
        val todayStart = java.util.Calendar.getInstance().apply {
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 0)
        }.timeInMillis
        val todayEnd = todayStart + 24 * 60 * 60 * 1000

        tasks.filter { task ->
            if (task.isCompleted) return@filter false
            val due = task.dueDate ?: return@filter true
            due in todayStart..todayEnd || due < now
        }.sortedByDescending { it.priority }
    }

    val upcomingTasks = remember(tasks) {
        val now = System.currentTimeMillis()
        val todayStart = java.util.Calendar.getInstance().apply {
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 0)
        }.timeInMillis
        val todayEnd = todayStart + 24 * 60 * 60 * 1000

        tasks.filter { task ->
            if (task.isCompleted) return@filter false
            val due = task.dueDate ?: return@filter false
            due > todayEnd
        }.sortedBy { it.dueDate ?: Long.MAX_VALUE }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Tasks") },
                actions = {
                    IconButton(onClick = { onNavigateToDetail(null) }) {
                        Icon(Icons.Default.AddCircle, contentDescription = "Add Task", tint = DSAccent)
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
        ) {
            // NLP Input
            Box(modifier = Modifier.padding(horizontal = 16.dp)) {
                TaskNLPInputView(viewModel)
            }

            // Segment Picker
            ScrollableTabRow(
                selectedTabIndex = selectedSegment.ordinal,
                containerColor = Color.Transparent,
                divider = {},
                indicator = {},
                edgePadding = 16.dp,
                modifier = Modifier.padding(vertical = 12.dp)
            ) {
                TaskSegment.values().forEach { segment ->
                    val isSelected = selectedSegment == segment
                    Tab(
                        selected = isSelected,
                        onClick = { selectedSegment = segment },
                        modifier = Modifier.padding(end = 8.dp)
                    ) {
                        Text(
                            text = segment.title,
                            color = if (isSelected) Color.White else DSTextSecondary,
                            modifier = Modifier
                                .background(if (isSelected) DSAccent else DSSurfaceLight, CapsuleShape)
                                .padding(horizontal = 16.dp, vertical = 8.dp)
                        )
                    }
                }
            }

            // Content
            Box(modifier = Modifier.padding(horizontal = 16.dp).weight(1f)) {
                when (selectedSegment) {
                    TaskSegment.Today -> TaskList(todayTasks, "No tasks for today. Enjoy!", viewModel, onNavigateToDetail)
                    TaskSegment.Upcoming -> TaskList(upcomingTasks, "Nothing upcoming", viewModel, onNavigateToDetail)
                    TaskSegment.Projects -> ProjectsList(projects, tasks) // Stub tasks mapping
                    TaskSegment.Matrix -> EisenhowerMatrixScreen(tasks)
                }
            }
        }
    }
}

@Composable
fun TaskList(tasks: List<TaskItem>, emptyMessage: String, viewModel: LifeOSViewModel, onNavigateToDetail: (TaskItem) -> Unit) {
    if (tasks.isEmpty()) {
        GlassCard(padding = 16.dp) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                Icon(Icons.Default.CheckCircle, contentDescription = null, tint = DSTextTertiary, modifier = Modifier.size(18.dp))
                Text(emptyMessage, color = DSTextTertiary)
            }
        }
    } else {
        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp), contentPadding = PaddingValues(bottom = 120.dp)) {
            items(tasks) { task ->
                TaskCard(task, onClick = { onNavigateToDetail(task) }, onToggle = {
                    viewModel.updateTask(task.copy(isCompleted = !task.isCompleted))
                })
            }
        }
    }
}

@Composable
fun TaskCard(task: TaskItem, onClick: () -> Unit, onToggle: () -> Unit) {
    Surface(
        onClick = onClick,
        color = Color.Transparent
    ) {
        GlassCard(padding = 12.dp) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onToggle) {
                    Icon(
                        Icons.Default.CheckCircle,
                        contentDescription = null,
                        tint = if (task.isCompleted) DSSuccess else DSTextTertiary
                    )
                }

                Column(verticalArrangement = Arrangement.spacedBy(2.dp), modifier = Modifier.weight(1f)) {
                    Text(
                        text = task.title,
                        color = if (task.isCompleted) DSTextTertiary else DSTextPrimary,
                        maxLines = 1,
                        style = MaterialTheme.typography.bodyLarge,
                        textDecoration = if (task.isCompleted) androidx.compose.ui.text.style.TextDecoration.LineThrough else null
                    )

                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        if (task.dueDate != null) {
                            val format = SimpleDateFormat("MMM d", Locale.getDefault())
                            Row(horizontalArrangement = Arrangement.spacedBy(2.dp), verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.CalendarMonth, contentDescription = null, tint = DSTextTertiary, modifier = Modifier.size(10.dp))
                                Text(format.format(Date(task.dueDate)), color = DSTextTertiary, fontSize = 11.sp)
                            }
                        }

                        Row(horizontalArrangement = Arrangement.spacedBy(2.dp), verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Schedule, contentDescription = null, tint = DSTextTertiary, modifier = Modifier.size(10.dp))
                            Text(task.formattedTimeEstimate, color = DSTextTertiary, fontSize = 11.sp)
                        }
                    }
                }

                Row(horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                    val energyColor = when (task.energyLevel) {
                        1 -> DSEnergyLow
                        3 -> DSEnergyHigh
                        else -> DSEnergyMedium
                    }
                    for (i in 1..3) {
                        Box(
                            modifier = Modifier
                                .size(5.dp)
                                .background(
                                    if (i <= task.energyLevel) energyColor else DSTextTertiary.copy(alpha = 0.2f),
                                    CircleShape
                                )
                        )
                    }
                }

                if (task.priority == 2) {
                    Icon(Icons.Default.Warning, contentDescription = null, tint = DSError, modifier = Modifier.size(12.dp))
                }
            }
        }
    }
}

@Composable
fun ProjectsList(projects: List<Project>, allTasks: List<TaskItem>) {
    if (projects.isEmpty()) {
        GlassCard(padding = 16.dp) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                Icon(Icons.Default.CheckCircle, contentDescription = null, tint = DSTextTertiary, modifier = Modifier.size(18.dp))
                Text("No projects yet", color = DSTextTertiary)
            }
        }
    } else {
        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(projects) { project ->
                val projectTasks = allTasks.filter { it.projectId == project.id }
                val completed = projectTasks.count { it.isCompleted }
                val color = try { Color(android.graphics.Color.parseColor(project.colorHex)) } catch (e: Exception) { DSAccent }
                
                GlassCard(padding = 16.dp) {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(modifier = Modifier.size(10.dp).background(color, CircleShape))
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(project.name, style = MaterialTheme.typography.headlineMedium, color = DSTextPrimary)
                            Spacer(modifier = Modifier.weight(1f))
                            Text("$completed/${projectTasks.size}", fontSize = 11.sp, color = DSTextTertiary)
                        }

                        // Progress bar
                        val progress = if (projectTasks.isEmpty()) 0f else completed.toFloat() / projectTasks.size
                        Box(modifier = Modifier.fillMaxWidth().height(4.dp).background(DSSurfaceLight, CapsuleShape)) {
                            Box(modifier = Modifier.fillMaxWidth(progress).height(4.dp).background(color, CapsuleShape))
                        }
                    }
                }
            }
        }
    }
}
