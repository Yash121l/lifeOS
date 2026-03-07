package com.yashlunawat.lifeos.ui.screens.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.ui.graphics.vector.ImageVector
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.models.*
import com.yashlunawat.lifeos.data.services.SettingsManager
import com.yashlunawat.lifeos.ui.components.GlassCard
import com.yashlunawat.lifeos.ui.theme.*
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(viewModel: LifeOSViewModel, onNavigateToSettings: () -> Unit) {
    val tasks by viewModel.tasks.collectAsState()
    val blocks by viewModel.timeBlocks.collectAsState()
    val transactions by viewModel.transactions.collectAsState()

    // Filter Logic
    val calendar = Calendar.getInstance()
    val todayStart = calendar.apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
    }.timeInMillis
    val todayEnd = todayStart + 24 * 60 * 60 * 1000

    val todaysBlocks = blocks
        .filter { it.startTime in todayStart..todayEnd }
        .sortedBy { it.startTime }

    val now = System.currentTimeMillis()
    val currentBlock = todaysBlocks.firstOrNull { now in it.startTime..it.endTime }

    val pendingTasks = tasks.filter { !it.isCompleted }
        .sortedWith(compareByDescending<TaskItem> { it.priority }.thenByDescending { it.energyLevel })
        .take(3)

    val todaySpend = transactions
        .filter { it.isExpense && it.date in todayStart..todayEnd }
        .sumOf { it.amount }

    val totalPendingTasks = tasks.count { !it.isCompleted }

    val energyScore = if (tasks.none { !it.isCompleted }) 1 else {
        val pending = tasks.filter { !it.isCompleted }
        val avg = pending.sumOf { it.energyLevel }.toDouble() / pending.size
        avg.roundToInt().coerceIn(1, 3)
    }

    val greeting = remember {
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        when (hour) {
            in 5..11 -> "Good Morning"
            in 12..16 -> "Good Afternoon"
            in 17..20 -> "Good Evening"
            else -> "Good Night"
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Dashboard") },
                actions = {
                    IconButton(onClick = onNavigateToSettings) {
                        Icon(Icons.Default.Settings, contentDescription = "Settings", tint = DSTextSecondary)
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
                .padding(horizontal = 16.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // Header
            HeaderSection(greeting, energyScore)

            // Timeline
            TimelineSection(todaysBlocks, currentBlock)

            // Up Next Tasks
            UpNextSection(totalPendingTasks, pendingTasks)

            // Finance Snapshot
            FinanceSection(todaySpend)

            Spacer(modifier = Modifier.height(100.dp))
        }
    }
}

private fun Double.roundToInt() = kotlin.math.round(this).toInt()

@Composable
private fun HeaderSection(greeting: String, energyScore: Int) {
    val energyLabel = when (energyScore) {
        1 -> "Light"
        3 -> "Intense"
        else -> "Moderate"
    }
    val energyColor = when (energyScore) {
        1 -> DSEnergyLow
        3 -> DSEnergyHigh
        else -> DSEnergyMedium
    }

    val dateFormat = SimpleDateFormat("EEEE, MMMM d", Locale.getDefault())
    val todayDate = dateFormat.format(Date())

    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = "$greeting, Yash",
            style = MaterialTheme.typography.displayLarge,
            color = DSTextPrimary
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = todayDate,
                style = MaterialTheme.typography.labelSmall,
                color = DSTextSecondary
            )

            Spacer(modifier = Modifier.weight(1f))

            Row(
                modifier = Modifier
                    .background(energyColor.copy(alpha = 0.15f), shape = RoundedCornerShape(percent = 50))
                    .padding(horizontal = 12.dp, vertical = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Bolt,
                    contentDescription = null,
                    tint = energyColor,
                    modifier = Modifier.size(11.dp)
                )
                Text(
                    text = energyLabel,
                    style = MaterialTheme.typography.labelSmall,
                    color = energyColor
                )
            }
        }
    }
}

@Composable
private fun TimelineSection(todaysBlocks: List<TimeBlock>, currentBlock: TimeBlock?) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        SectionHeader("Today's Schedule", todaysBlocks.size)

        if (todaysBlocks.isEmpty()) {
            EmptyState(Icons.Default.CalendarMonth, "No events scheduled today")
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                todaysBlocks.forEach { block ->
                    TimeBlockRow(block, isCurrent = block.id == currentBlock?.id)
                }
            }
        }
    }
}

@Composable
private fun TimeBlockRow(block: TimeBlock, isCurrent: Boolean) {
    val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
    val startStr = timeFormat.format(Date(block.startTime))
    val endStr = timeFormat.format(Date(block.endTime))
    
    // Convert hex string to Color
    val blockColor = try {
        Color(android.graphics.Color.parseColor(block.colorHex))
    } catch (e: Exception) {
        DSAccent
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Color(0xFF141414).copy(alpha = 0.5f))
            .background(blockColor.copy(alpha = if (isCurrent) 0.08f else 0.03f))
            .border(
                width = if (isCurrent) 1.dp else 0.5.dp,
                color = if (isCurrent) blockColor.copy(alpha = 0.3f) else DSCardBorder,
                shape = RoundedCornerShape(12.dp)
            )
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Time Column
        Column(
            modifier = Modifier.width(52.dp),
            horizontalAlignment = Alignment.End,
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(startStr, style = MaterialTheme.typography.labelSmall, color = DSTextSecondary)
            Text(endStr, style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, fontSize = 11.sp)
        }

        // Accent Bar
        Box(
            modifier = Modifier
                .width(3.dp)
                .height(32.dp)
                .background(blockColor, RoundedCornerShape(2.dp))
        )

        // Content
        Column(verticalArrangement = Arrangement.spacedBy(2.dp), modifier = Modifier.weight(1f)) {
            Text(block.title, style = MaterialTheme.typography.headlineMedium, color = DSTextPrimary)
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(block.formattedDuration, style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, fontSize = 11.sp)
                if (isCurrent) {
                    Text(
                        text = "NOW",
                        color = DSAccent,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier
                            .background(DSAccent.copy(alpha = 0.15f), RoundedCornerShape(percent = 50))
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun UpNextSection(totalPending: Int, pendingTasks: List<TaskItem>) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        SectionHeader("Up Next", totalPending)

        if (pendingTasks.isEmpty()) {
            EmptyState(Icons.Default.CheckCircle, "All caught up!")
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                pendingTasks.forEach { task ->
                    TaskRow(task)
                }
            }
        }
    }
}

@Composable
private fun TaskRow(task: TaskItem) {
    val priorityColor = when (task.priority) {
        0 -> DSEnergyLow
        2 -> DSError
        else -> DSAccent
    }

    GlassCard(padding = 12.dp) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Priority
            Box(
                modifier = Modifier
                    .size(8.dp)
                    .background(priorityColor, CircleShape)
            )

            // Content
            Column(verticalArrangement = Arrangement.spacedBy(2.dp), modifier = Modifier.weight(1f)) {
                Text(task.title, style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary, maxLines = 1)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    if (task.dueDate != null) {
                        val format = SimpleDateFormat("MMM d", Locale.getDefault())
                        Row(horizontalArrangement = Arrangement.spacedBy(2.dp), verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.CalendarMonth, contentDescription = null, tint = DSTextTertiary, modifier = Modifier.size(10.dp))
                            Text(format.format(Date(task.dueDate)), style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, fontSize = 11.sp)
                        }
                    }
                    Text(task.formattedTimeEstimate, style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, fontSize = 11.sp)
                }
            }

            // Energy Dots
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
                                if (i <= task.energyLevel) energyColor else DSTextTertiary.copy(alpha = 0.3f),
                                CircleShape
                            )
                    )
                }
            }
        }
    }
}

@Composable
private fun FinanceSection(todaySpend: Double) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        SectionHeader("Finance")

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            // Today Spend
            Box(modifier = Modifier.weight(1f)) {
                GlassCard(tint = DSError, padding = 16.dp) {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("Today", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, fontSize = 11.sp)
                        Text(
                            text = "${SettingsManager.currencySymbol}${String.format(Locale.getDefault(), "%.2f", todaySpend)}",
                            style = MaterialTheme.typography.titleLarge,
                            color = if (todaySpend > 0) DSError else DSTextSecondary
                        )
                    }
                }
            }

            // Net Worth
            Box(modifier = Modifier.weight(1f)) {
                GlassCard(tint = DSSuccess, padding = 16.dp) {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("Net Worth", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, fontSize = 11.sp)
                        Text(
                            text = "${SettingsManager.currencySymbol}10,400",
                            style = MaterialTheme.typography.titleLarge,
                            color = DSSuccess
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun SectionHeader(title: String, count: Int? = null) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(title, style = MaterialTheme.typography.headlineMedium, color = DSTextPrimary)
        if (count != null && count > 0) {
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = count.toString(),
                style = MaterialTheme.typography.labelSmall,
                color = DSTextTertiary,
                modifier = Modifier
                    .background(DSSurfaceLight, RoundedCornerShape(percent = 50))
                    .padding(horizontal = 6.dp, vertical = 2.dp)
            )
        }
    }
}

@Composable
private fun EmptyState(icon: ImageVector, message: String) {
    GlassCard(padding = 16.dp) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(imageVector = icon, contentDescription = null, tint = DSTextTertiary, modifier = Modifier.size(18.dp))
            Text(message, style = MaterialTheme.typography.bodyLarge, color = DSTextTertiary)
        }
    }
}
