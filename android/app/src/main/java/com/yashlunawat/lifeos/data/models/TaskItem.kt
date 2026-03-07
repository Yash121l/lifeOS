package com.yashlunawat.lifeos.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "tasks")
data class TaskItem(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val title: String,
    val priority: Int = 1, // 0: Low, 1: Medium, 2: High
    val dueDate: Long? = null, // Stored as timestamp
    val isCompleted: Boolean = false,
    val energyLevel: Int = 2, // 1: Low, 2: Medium, 3: High
    val timeEstimateMinutes: Int = 30,
    val notes: String = "",
    val urgency: Int = 0, // 0: Not urgent, 1: Urgent
    val projectId: Long? = null // FK to Project
) {
    val energyColor: String
        get() = when (energyLevel) {
            1 -> "low"
            3 -> "high"
            else -> "medium"
        }

    val priorityLabel: String
        get() = when (priority) {
            0 -> "Low"
            2 -> "High"
            else -> "Medium"
        }

    val formattedTimeEstimate: String
        get() = if (timeEstimateMinutes < 60) {
            "${timeEstimateMinutes}m"
        } else {
            val hours = timeEstimateMinutes / 60
            val mins = timeEstimateMinutes % 60
            if (mins > 0) "${hours}h ${mins}m" else "${hours}h"
        }
}
