package com.yashlunawat.lifeos.ui.screens.tasks

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.People
import androidx.compose.ui.graphics.vector.ImageVector
import com.yashlunawat.lifeos.data.models.TaskItem
import com.yashlunawat.lifeos.ui.theme.*

@Composable
fun EisenhowerMatrixScreen(tasks: List<TaskItem>) {
    val now = System.currentTimeMillis()
    fun isUrgent(task: TaskItem): Boolean {
        val due = task.dueDate ?: return false
        return (due - now) < 172800000 // 48 hours
    }

    val urgentImportant = tasks.filter { it.priority == 2 && isUrgent(it) && !it.isCompleted }
    val notUrgentImportant = tasks.filter { it.priority == 2 && !isUrgent(it) && !it.isCompleted }
    val urgentNotImportant = tasks.filter { it.priority < 2 && isUrgent(it) && !it.isCompleted }
    val notUrgentNotImportant = tasks.filter { it.priority < 2 && !isUrgent(it) && !it.isCompleted }

    Column(modifier = Modifier.fillMaxSize().padding(top = 12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        // Top Labels
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Spacer(modifier = Modifier.width(30.dp))
            Text("URGENT", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = DSTextTertiary, letterSpacing = 1.2.sp, modifier = Modifier.weight(1f))
            Text("NOT URGENT", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = DSTextTertiary, letterSpacing = 1.2.sp, modifier = Modifier.weight(1f))
        }

        Row(modifier = Modifier.weight(1f), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            // Side Labels
            Column(modifier = Modifier.width(30.dp)) {
                Box(contentAlignment = Alignment.Center, modifier = Modifier.weight(1f).fillMaxWidth()) {
                    Text("IMPORTANT", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = DSTextTertiary, letterSpacing = 1.2.sp, modifier = Modifier.rotate(270f))
                }
                Box(contentAlignment = Alignment.Center, modifier = Modifier.weight(1f).fillMaxWidth()) {
                    Text("LESS", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = DSTextTertiary, letterSpacing = 1.2.sp, modifier = Modifier.rotate(270f))
                }
            }

            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(modifier = Modifier.weight(1f), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    MatrixQuadrant("Do First", Icons.Default.LocalFireDepartment, DSError, urgentImportant, Modifier.weight(1f))
                    MatrixQuadrant("Schedule", Icons.Default.CalendarMonth, DSAccent, notUrgentImportant, Modifier.weight(1f))
                }
                Row(modifier = Modifier.weight(1f), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    MatrixQuadrant("Delegate", Icons.Default.People, DSWarning, urgentNotImportant, Modifier.weight(1f))
                    MatrixQuadrant("Eliminate", Icons.Default.Cancel, DSTextTertiary, notUrgentNotImportant, Modifier.weight(1f))
                }
            }
        }
    }
}

@Composable
private fun MatrixQuadrant(title: String, icon: ImageVector, color: Color, tasks: List<TaskItem>, modifier: Modifier) {
    Column(
        modifier = modifier
            .fillMaxHeight()
            .background(color.copy(alpha = 0.05f), RoundedCornerShape(12.dp))
            .border(0.5.dp, color.copy(alpha = 0.15f), RoundedCornerShape(12.dp))
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(imageVector = icon, contentDescription = null, tint = color, modifier = Modifier.size(11.dp))
            Spacer(modifier = Modifier.width(4.dp))
            Text(title, style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.SemiBold, color = color)
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = "${tasks.size}",
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                color = color,
                modifier = Modifier
                    .background(color.copy(alpha = 0.15f), RoundedCornerShape(percent = 50))
                    .padding(horizontal = 6.dp, vertical = 2.dp)
            )
        }

        if (tasks.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("Empty", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
            }
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                tasks.take(4).forEach { task ->
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        Box(modifier = Modifier.size(4.dp).background(color.copy(alpha = 0.5f), androidx.compose.foundation.shape.CircleShape))
                        Text(task.title, fontSize = 11.sp, color = DSTextSecondary, maxLines = 1)
                    }
                }
                if (tasks.size > 4) {
                    Text("+${tasks.size - 4} more", fontSize = 10.sp, color = DSTextTertiary)
                }
            }
        }
    }
}
