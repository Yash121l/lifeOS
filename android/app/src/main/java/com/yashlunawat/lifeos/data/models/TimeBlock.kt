package com.yashlunawat.lifeos.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "time_blocks")
data class TimeBlock(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val title: String,
    val startTime: Long,
    val endTime: Long,
    val linkedTaskId: Long? = null,
    val colorHex: String = "007AFF",
    val isCompleted: Boolean = false,
    val blockType: String = "deepWork" // deepWork, meeting, personal, routine
) {
    val durationMinutes: Int
        get() = ((endTime - startTime) / (1000 * 60)).toInt()

    val formattedDuration: String
        get() {
            val mins = durationMinutes
            return if (mins < 60) {
                "${mins}m"
            } else {
                val hours = mins / 60
                val remaining = mins % 60
                if (remaining > 0) "${hours}h ${remaining}m" else "${hours}h"
            }
        }
}
